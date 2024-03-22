class CodeCheckmark < OrganizationRecord
  belongs_to :source_code
  has_many   :code_checkmark_hits, dependent: :destroy

  validates  :checkmark_id,        presence: true
  validates  :source_code,         presence: true
  validates  :filename,            presence: true
  validates  :line_number,         presence: true

  BEGIN_OFFSET_BLOCK_REGEX = /^.*\s+(if|while|for|switch|else|do)\s+(.+)\s*({){0,1}$/i
  BEGIN_INLINE_BLOCK_REGEX = /^.*{.*$/i
  STATEMENT_INDICATOR      = /^.*;.*$/i
  END_BLOCK_REGEX          = /^.*}.*$/i
  END_BRACE                = /^.*{\s*.$/
  IF_NO_BRACE              = /^.*if.*[^{]$/
  CMARK_REGEX              = /^.*CMARK.*\(\s*(\d+)\s*\).*$/i
  IN_FUNCTION              = /^\s*([a-z0-9_]+\s+)+[a-z0-9_]+\s*\(.*\)\s*\{{0,1}\s*$/i
  FUNCTION_CALL            = /([_a-zA-Z0-9]+)\s*(\(.*\))/i
  ASSIGNMENT               = /^\s*([_a-zA-Z0-9]+).*=.*$/

  def self.instrument_code_file(filename,
                                source_code,
                                session_id      = nil,
                                autoinstrument  = false,
                                cmark_indicator = 'CMARK',
                                resetnumbering  = false,
                                starting_number = -1)
    result                                         = nil
    checkmark_id                                   = if resetnumbering && (!starting_number.present? || starting_number < 0)
                                                       0
                                                     else
                                                       starting_number
                                                     end
    temp_file                                      = Tempfile.new(filename) if autoinstrument

    logger.info("Instrumenting File: #{filename}")

    return result unless File.exist?(filename)

    if autoinstrument
      case(cmark_indicator)
        when 'CMARK'
          temp_file.puts('#include "cmark.h"')

        when 'CMARK_BITFIELD'
          temp_file.puts('#include "cmark_bitfield.h"')

        when 'CMARK_BITSET'
          temp_file.puts('#include "cmark_bitset.h"')

        when 'CMARK_SECONDS'
          temp_file.puts('#include "cmark_seconds.h"')

        when 'CMARK_NANOSECONDS'
          temp_file.puts('#include "cmark_nanoseconds.h"')

        when 'CMARK_STRFTIME'
          temp_file.puts('#include "cmark_strftime.h"')
      end
    end

    File.open(filename) do |file|
      brace_count                                  = 0
      paren_count                                  = 0
      line_number                                  = 0
      in_function                                  = false
      cmarked_previous_line                        = false
      skipped_previous                             = false
      previous_comment                             = false 
      current_conditions                           = []
      previous_line                                = nil
      old_checkmarks                               = CodeCheckmark.where(filename: filename)

      old_checkmarks.each do |old_checkmark|
        data_change                                = DataChange.save_or_destroy_with_undo_session(old_checkmark,
                                                                                                 'delete',
                                                                                                 old_checkmark.id,
                                                                                                 'code_checkmarks',
                                                                                                 session_id)
        session_id                                 = data_change.session_id if data_change.present?
      end unless old_checkmarks.empty?

      code_conditional_blocks                      = CodeConditionalBlock.where(filename: filename)

      code_conditional_blocks.each do |old_code_conditional_block|
        data_change                                = DataChange.save_or_destroy_with_undo_session(old_code_conditional_block,
                                                                                                 'delete',
                                                                                                 old_code_conditional_block.id,
                                                                                                 'code_conditional_blocks',
                                                                                                 session_id)
        session_id                                 = data_change.session_id if data_change.present?
      end unless code_conditional_blocks.empty?

      while (line = file.gets)
        line                                       = line.encode("UTF-8", invalid: :replace)
        line_number                               += 1

        if line =~ /^\s*\/\// || line =~ /^\s*\/\*.*$/
          temp_file.puts(line) if autoinstrument

          previous_line         = line
          cmarked_previous_line = false
          skipped_previous      = true
          previous_comment      = true

          next
        end

        if line =~ IN_FUNCTION
          in_function                              = true
          brace_count                              = 0
          paren_count                              = 0
        end

        if in_function
          if (line.count('{') > 0) || (line.count('}') > 0)
            brace_count                           += line.count('{')
            brace_count                           -= line.count('}')
            in_function                            = false if brace_count <= 0
          end

          if (line.count('(') > 0) || (line.count(')') > 0)
            paren_count                           += line.count('(')
            paren_count                           -= line.count(')')
          end
        end

        if line =~ CMARK_REGEX
          checkmark_id                             = Regexp.last_match[1].to_i
          code_checkmark                           = CodeCheckmark.new
          code_checkmark.checkmark_id              = checkmark_id
          code_checkmark.filename                  = filename
          code_checkmark.source_code_id            = source_code.id
          code_checkmark.line_number               = line_number
          code_checkmark.code_statement            = line
          code_checkmark.organization              = User.current.organization if User.current.present?
          data_change                              = DataChange.save_or_destroy_with_undo_session(code_checkmark,
                                                                                                  'create',
                                                                                                  nil,
                                                                                                  'code_checkmarks',
                                                                                                  session_id)

          if data_change.present?
            session_id                             = data_change.session_id
            result                                 = true
          else
            result                                 = false

            break
          end

          cmarked_previous_line = false
          previous_comment      = false

          temp_file.puts(line) if autoinstrument
        elsif (((line =~ STATEMENT_INDICATOR) || (line =~ FUNCTION_CALL) || line =~ ASSIGNMENT) && autoinstrument && in_function)
          if !previous_comment && (previous_line.present? && ((cmarked_previous_line || skipped_previous) && !(previous_line =~ STATEMENT_INDICATOR) && !(previous_line =~ END_BRACE) && !(previous_line =~ IF_NO_BRACE) && !(line =~ FUNCTION_CALL)))
            temp_file.puts(line) if autoinstrument

            previous_line         = line
            cmarked_previous_line = false
            skipped_previous      = true
            previous_comment      = false


            next
          end

          if !previous_comment && (previous_line.present? && !(cmarked_previous_line || skipped_previous) && !(previous_line =~ STATEMENT_INDICATOR)) && !(previous_line =~ END_BRACE)
            temp_file.puts(line) if autoinstrument
            previous_line         = line
            cmarked_previous_line = false
            skipped_previous      = true
            previous_comment      = false

            next
          end
            
          checkmark_id                             = if checkmark_id.present?
                                                      checkmark_id + 1
                                                    else
                                                      1
                                                    end
          code_checkmark                           = CodeCheckmark.new
          code_checkmark.checkmark_id              = checkmark_id
          code_checkmark.filename                  = filename
          code_checkmark.source_code_id            = source_code.id
          code_checkmark.line_number               = line_number
          code_checkmark.code_statement            = line
          code_checkmark.organization              = User.current.organization if User.current.present?
          data_change                              = DataChange.save_or_destroy_with_undo_session(code_checkmark,
                                                                                                  'create',
                                                                                                  nil,
                                                                                                  'code_checkmarks',
                                                                                                  session_id)

          if data_change.present?
            session_id                             = data_change.session_id
            result                                 = true
          else
            result                                 = false

            break
          end

          if line =~ IN_FUNCTION
            temp_file.puts(line)
          else
            temp_file.puts("#{cmark_indicator}(#{checkmark_id}); #{line}")

            cmarked_previous_line = true
          end

          skipped_previous      = false
          previous_comment      = false
        elsif line =~ BEGIN_OFFSET_BLOCK_REGEX
          code_conditional_block                   = CodeConditionalBlock.new
          code_conditional_block.filename          = filename
          code_conditional_block.source_code_id    = source_code.id
          code_conditional_block.start_line_number = line_number
          code_conditional_block.end_line_number   = line_number
          code_conditional_block.offset            = (Regexp.last_match[3] == '{')
          code_conditional_block.condition         = Regexp.last_match[1]
          code_conditional_block.condition        += " #{Regexp.last_match[2]}" if Regexp.last_match[2].present?
          code_conditional_block.condition        += " #{Regexp.last_match[3]}" if Regexp.last_match[3].present?
          code_conditional_block.organization      = User.current.organization if User.current.present?
          data_change                              = DataChange.save_or_destroy_with_undo_session(code_conditional_block,
                                                                                                  'create',
                                                                                                  nil,
                                                                                                  'code_conditional_blocks',
                                                                                                  session_id)

          if data_change.present?
            session_id                             = data_change.session_id
            result                                 = true

            current_conditions.push(code_conditional_block)
          else
            result                                 = false

            break
          end

          cmarked_previous_line = false
          previous_comment      = false

          temp_file.puts(line) if autoinstrument
        elsif line =~ BEGIN_INLINE_BLOCK_REGEX
          if current_conditions.length > 0
            code_conditional_block                   = current_conditions[current_conditions.length - 1]
            code_conditional_block.offset            = false
            code_conditional_block.start_line_number = line_number
          end

          cmarked_previous_line = false
          previous_comment      = false

          temp_file.puts(line) if autoinstrument
        elsif line =~ END_BLOCK_REGEX
          code_conditional_block                   = current_conditions.pop

          if code_conditional_block.present?
            code_conditional_block.end_line_number = line_number
            data_change                            = DataChange.save_or_destroy_with_undo_session(code_conditional_block,
                                                                                                  'update',
                                                                                                  code_conditional_block.id,
                                                                                                  'code_conditional_blocks',
                                                                                                  session_id)

            if data_change.present?
              session_id                             = data_change.session_id
              result                                 = true
            else
              result                                 = false
  
              break
            end
          end

          cmarked_previous_line = false
          previous_comment      = false

          temp_file.puts(line) if autoinstrument
        elsif autoinstrument
          cmarked_previous_line = false
          previous_comment      = false

          temp_file.puts(line)
        end

        previous_line = line
      end
    end

    logger.info("Ready to Create Document for #{filename}")

    if autoinstrument && result
      logger.info("Creating Document for #{filename}")

      temp_file.rewind

      File.open(filename, 'wb') { |f| f.write(temp_file.read) }

      folder                     = Document.get_or_create_folder(Constants::INSTRUMENTED_CODE,
                                                                 source_code.project_id,
                                                                 source_code.item_id,
                                                                 nil,
                                                                 session_id)

      new_document               = Document.new()
      new_document.docid         = File.basename(filename)
      new_document.name          = File.basename(filename)
      new_document.category      = Constants::INSTRUMENTED_CODE
      new_document.document_type = 'Code'
      new_document.file_type     = 'text/plain'
      new_document.file_path     = filename
      new_document.parent_id     = folder.id
      new_document.item_id       = source_code.item_id
      new_document.project_id    = source_code.project_id
      last_documents             = Document.where(docid:        File.basename(filename),
                                                  parent_id:    folder.id,
                                                  organization: User.current.organization).order(:version)
      version                    = 0

      if last_documents.present? && (last_documents.length >= 1)
        last_document            = last_documents.last

        if last_document.version.present?
          version                = last_document.version + 1
        else
          version                = 1
        end
      else
        version                  = 1
      end

      new_document.version       = if new_document.version.present?
                                     new_document.version + 1
                                   else
                                     1
                                   end
      pg_results                 = ActiveRecord::Base.connection.execute("SELECT nextval('documents_document_id_seq')")

      pg_results.each { |row| new_document.document_id = row["nextval"] } if pg_results.present?

      result                     = DataChange.save_or_destroy_with_undo_session(new_document,
                                                                                'create',
                                                                                nil,
                                                                                'documents',
                                                                                session_id)
    end

    if result
      result                     = checkmark_id
      logger.info("File: #{filename} Instrumented successfully.")
    else
      logger.info("File: #{filename} Instrumenting failed.")
    end

    return result
  end
end
