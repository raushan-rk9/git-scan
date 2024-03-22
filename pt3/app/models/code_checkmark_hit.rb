class CodeCheckmarkHit < OrganizationRecord
  belongs_to :code_checkmark
  validates  :code_checkmark_id, presence: true

  CMARK_REGEX_INTEGER_HIT_AT  = /^\s*(\d+)\s*,\s*(\d+).*$/i
  CMARK_REGEX_DATETIME_HIT_AT = /^\s*(\d+)\s*,\s*(\d{4}\-\d{2}\-\d{2}T\d{2}:\d{2}:\d{2}).*$/i
  CMARK_SECONDS_NANOSECONDS_HIT_AT = /^\s*(\d+)\s*,\s*(\d+\.\d+)\s*$/i
  CMARK_REGEX                 = /^(\d+)$/i
  MAX_CHECKMARKS              = 32767

  def self.find_code_checkmarks(checkmark_id, source_code_ids = nil)
    result = if source_code_ids.present?
      CodeCheckmark.find_by(checkmark_id:   checkmark_id,
                            organization:   User.current.organization,
                            source_code_id: source_code_ids)
    else
      CodeCheckmark.find_by(checkmark_id: checkmark_id,
                            organization: User.current.organization)
    end

    return result
  end

  def self.record_hits(argument, source_code_ids = nil)
    result                                       = false
    session_id                                   = nil

    if User.current.present? &&
      !(argument =~ /^\d+$/) &&
      !(argument =~ /^0x[0-9a-f]+$/i)
      old_checkmarks                             = CodeCheckmark.where(organization: User.current.organization, filename: argument)

      old_checkmarks.each do |old_checkmark|
        old_hits                                 = CodeCheckmarkHit.where(code_checkmark_id: old_checkmark.id)

        old_hits.each do |old_hit|
          data_change                            = DataChange.save_or_destroy_with_undo_session(old_hit,
                                                                                                'delete',
                                                                                                old_hit.id,
                                                                                                'code_checkmark_hits',
                                                                                                session_id)
          session_id                             = data_change.session_id if data_change.present?
        end unless old_hits.empty?
      end unless old_checkmarks.empty?
    end

    if argument.instance_of?(String)
      if (argument =~ /^[0-1]+$/)
        for i in (argument.length - 1).downto(0)
          if argument[i] == '1'
            checkmark_id                         = 2 ** ((argument.length - 1) - i)
            checkmark                            = find_code_checkmarks(checkmark_id,
                                                                        source_code_ids)

            next unless checkmark.present?

            code_checkmark_hit                   = CodeCheckmarkHit.new
            code_checkmark_hit.code_checkmark_id = checkmark.id
            code_checkmark_hit.organization      = User.current.organization if User.current.present?
            data_change                          = DataChange.save_or_destroy_with_undo_session(code_checkmark_hit,
                                                                                                'create',
                                                                                                nil,
                                                                                                'code_checkmark_hits',
                                                                                                session_id)
    
            if data_change.present?
              result                             = true
              session_id                         = data_change.session_id
            else
              return false
            end
          end
        end
      elsif (argument =~ /^\d+$/)
        for i in 0..MAX_CHECKMARKS
          if (argument.to_i & (2 ** i)) != 0
            checkmark_id                         = i
            checkmark                            = find_code_checkmarks(checkmark_id,
                                                                        source_code_ids)

            next unless checkmark.present?

            code_checkmark_hit                   = CodeCheckmarkHit.new
            code_checkmark_hit.code_checkmark_id = checkmark.id
            code_checkmark_hit.organization      = User.current.organization if User.current.present?
            data_change                          = DataChange.save_or_destroy_with_undo_session(code_checkmark_hit,
                                                                                                'create',
                                                                                                nil,
                                                                                                'code_checkmark_hits',
                                                                                               session_id)

            if data_change.present?
              result                             = true
              session_id                         = data_change.session_id
            else
              return false
            end
          end
        end
      elsif argument =~ /^0x[0-9a-f]+$/i
        for i in 0..MAX_CHECKMARKS
          if (argument.to_i(16) & (2 ** i)) != 0
            checkmark_id                         = i
            checkmark                            = find_code_checkmarks(checkmark_id,
                                                                        source_code_ids)

            next unless checkmark.present?

            code_checkmark_hit                   = CodeCheckmarkHit.new
            code_checkmark_hit.code_checkmark_id = checkmark.id
            code_checkmark_hit.organization      = User.current.organization if User.current.present?
            data_change                          = DataChange.save_or_destroy_with_undo_session(code_checkmark_hit,
                                                                                                'create',
                                                                                                nil,
                                                                                                'code_checkmark_hits',
                                                                                               session_id)

            if data_change.present?
              result                             = true
              session_id                         = data_change.session_id
            else
              return false
            end
          end
        end
      else
        filename                                 = argument

        return result unless File.exist?(filename)

        File.open(filename) do |file|
          while (line = file.gets)
            line.gsub!("\n", '')
            line.gsub!("\r", '')

            checkmark_id                         = nil
            hit_at                               = nil

            if line =~ CMARK_REGEX_DATETIME_HIT_AT
              checkmark_id                       = Regexp.last_match[1].to_i
              hit_at                             = DateTime.parse(Regexp.last_match[2])
            elsif line =~ CMARK_SECONDS_NANOSECONDS_HIT_AT
              checkmark_id                       = Regexp.last_match[1].to_i
              fields                             = Regexp.last_match[2].split('.')
              seconds                            = fields[0].to_i
              nanoseconds                        = fields[1].to_i
              hit_at                             = Time.at(seconds, nanoseconds, :nsec).to_datetime
            elsif line =~ CMARK_REGEX_INTEGER_HIT_AT
              checkmark_id                       = Regexp.last_match[1].to_i
              hit_at                             = Time.at(Regexp.last_match[2].to_i, 0, :nsec).to_datetime
            elsif line =~ CMARK_REGEX
              checkmark_id                       =  Regexp.last_match[1].to_i
            end

            next unless checkmark_id.present?

            checkmark                            = find_code_checkmarks(checkmark_id,
                                                                        source_code_ids)

            next unless checkmark.present?

            code_checkmark_hit                   = CodeCheckmarkHit.new
            code_checkmark_hit.code_checkmark_id = checkmark.id
            code_checkmark_hit.hit_at            = hit_at
            code_checkmark_hit.organization      = User.current.organization if User.current.present?
            data_change                          = DataChange.save_or_destroy_with_undo_session(code_checkmark_hit,
                                                                                                'create',
                                                                                                nil,
                                                                                                'code_checkmark_hits',
                                                                                                session_id)

            if data_change.present?
              result                             = true
              session_id                         = data_change.session_id
            else
              result                             = false

              break
            end
          end
        end
      end
    end

    return result
  end
end
