require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/reporters"

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

module MiniTest::Assertions
  def assert_equals(exp, act, act_label = nil, msg = nil)
    self.assertions += 1
    message          = "Expected #{act_label} to be '#{exp}'" if !msg.present? && act_label.present?

    if exp == act
      if msg.present?
        STDERR.puts "    #{msg}"
      elsif message.present?
        STDERR.puts "    #{message}. It was. "
      else
        STDERR.puts "    '#{act}' equaled '#{exp}'."
      end
    else
      assert_equal(exp, act, message)
    end
  end

  def assert_not_equals(exp, act, act_label = nil, msg = nil)
    self.assertions += 1
    message          = "Expected #{act_label} not to be '#{exp}'" if !msg.present? && act_label.present?

    if exp != act
      if msg.present?
        STDERR.puts "    #{msg}"
      elsif message.present?
        STDERR.puts "    #{message}. It was not '#{exp}'. "
      else
        STDERR.puts "    '#{act}' did not equal '#{exp}'."
      end
    else
      STDERR.puts "      Expected: '#{exp}'"
      STDERR.puts "        Actual: '#{act}'"
      flunk(message)
    end
  end

  def assert_not_equals_nil(act, act_label = nil, msg = nil)
    assert_not_equals(nil, act, act_label, msg)
  end

  def assert_between(exp_1, exp_2, act, act_label = nil, msg = nil)
    self.assertions += 1
    message          = "Expected #{act_label} to be between '#{exp_1}' and '#{exp_2}'" if !msg.present? && act_label.present?

    if (act.nil?) || (act < exp_1) || (act > exp_2)
      STDERR.puts "      Expected: Between '#{exp_1}' and '#{exp_2}'"
      STDERR.puts "        Actual: '#{act}'"
      flunk(message)
    else
      if msg.present?
        STDERR.puts "    #{msg}"
      elsif message.present?
        STDERR.puts "    #{message}. It was not '#{exp}'. "
      else
        STDERR.puts "    '#{act}' did not equal '#{exp}'."
      end
    end
  end
end

Capybara.register_driver :chrome_headless do |app|
  options = ::Selenium::WebDriver::Chrome::Options.new

  options.add_argument('--headless')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--window-size=1400,1400')

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.javascript_driver = :chrome_headless

class ActiveSupport::TestCase
  include Devise::Test::IntegrationHelpers

  DEFAULT_TEMPLATES_FOLDER = Rails.root.join('test', 'templates')
  DEFAULT_EMAIL            = 'admin@faaconsultants.com'
  DEFAULT_ORGANIZATION     = 'test'
  PM_EMAIL                 = 'test_1@airworthinesscert.com'
  CM_EMAIL                 = 'test_2@airworthinesscert.com'
  QA_EMAIL                 = 'test_3@airworthinesscert.com'
  TM_EMAIL                 = 'test_4@airworthinesscert.com'

  fixtures %w[
                constants
                document_types
                users
                licensees
                projects
                items
                model_files
                system_requirements
                high_level_requirements
                low_level_requirements
                source_codes
                test_cases
                test_procedures
                problem_reports
                problem_report_histories
                problem_report_attachments
                documents
                document_comments
                reviews
                action_items
                checklist_items
                document_attachments
                review_attachments
                templates
                template_checklists
                template_checklist_items
                template_documents
                archives
             ]

  def clexec_fillallclitems(review_id, level, template_checklist_id)
    template_checklist_items          = []
    template_checklist                = TemplateChecklist.find_by(title:        template_checklist_id,
                                                                  organization: DEFAULT_ORGANIZATION)

    if template_checklist.present?
      template_checklist_items        = TemplateChecklistItem.where(template_checklist_id: template_checklist.id,
                                                                    organization:          DEFAULT_ORGANIZATION)
    end

    checklist_item_number             = 1

    # Add item for every checklist item constant defined.
    template_checklist_items.each do |template_checklist_item|
      skip                            = false
      checklist_item                  = ChecklistItem.new
      checklist_item.review_id        = review_id
      checklist_item.clitemid         = checklist_item_number
      checklist_item.description      = template_checklist_item.description
      checklist_item.reference        = template_checklist_item.reference
      checklist_item.supplements      = template_checklist_item.supplements

      if level.present?
        if template_checklist_item.minimumdal.present?
          if template_checklist_item.minimumdal.include?(level)
            checklist_item.minimumdal = level
          else
            skip                      = true
          end
        end
      end

      next if skip

      checklist_item.save

      checklist_item_number          += 1
    end
  end

  def copy_checklists_to_evaluators(review_id, evaluators)
    checklist_items                = ChecklistItem.where(review_id: review_id)

    if evaluators.present? && checklist_items.present?
      evaluators.each() do |evaluator|
        user                       = User.find_by(email: evaluator)

        next if user.nil?

        checklist_items.each() do |unassigned_checklist_item|
          checklist_item           = unassigned_checklist_item.dup
          checklist_item.id        = nil
          checklist_item.evaluator = user.email
          checklist_item.user_id   = user.id
          checklist_item.assigned  = true

          checklist_item.save
        end
      end
    end
  end

  def rebuild_associations(records)
    records.each do |record|
      Associations.clear_association(record)
      Associations.build_associations(record)
    end if records.present?
  end

  def finish_fixture_setup
    begin
      ActiveRecord::Base.connection.execute("CREATE SEQUENCE session_id_seq ")
    rescue
      nil
    end

    begin
      ActiveRecord::Base.connection.execute("CREATE SEQUENCE documents_document_id_seq ")
    rescue
      nil
    end

    user                         = User.find_by(email: DEFAULT_EMAIL)
    user.organization            = DEFAULT_ORGANIZATION

    user.save

    User.current                 = user

    fixtures_setup               = YAML::load(File.open('test/fixtures/files/fixtures_setup.yml'))

    fixtures_setup['link_records'].each do |link|
      source_record              = link['source_table'].constantize.find_by(link['source_find_field']           => link['source_find_value'])
      destination_record         = link['destination_table'].constantize.find_by(link['destination_find_field'] => link['destination_find_value'])

      next unless source_record.present? && destination_record.present?

      destination_record[link['destination_field']] = source_record.id

      destination_record.save
    end

    fixtures_setup['user_images'].each do |file|
      user_file = User.find_by(email: file['email'])

      next unless user_file.present?

      if file['field'] == 'signature_file'
        user_file.signature_file.attach(io:           File.open(file['path']),
                                        filename:     file['filename'],
                                        content_type: file['content_type'])
        user_file.save
      else
        user_file.profile_picture.attach(io:           File.open(file['path']),
                                         filename:     file['filename'],
                                         content_type: file['content_type'])
        user_file.save
      end
    end

    fixtures_setup['model_file_images'].each do |file|
      model_file                 = ModelFile.find_by(full_id: file['model_file_full_id'])

      next unless model_file.present?

      model_file.upload_file.attach(io:           File.open(file['path']),
                                    filename:     file['filename'],
                                    content_type: file['content_type'])
      model_file.save
    end

    fixtures_setup['test_procedure_files'].each do |file|
      test_procedure             = TestProcedure.find_by(item_id: Item.find_by(identifier: file['item_id']).try(:id), full_id: file['full_id'])

      next unless test_procedure.present?

      test_procedure.upload_file.attach(io:           File.open(file['path']),
                                        filename:     file['filename'],
                                        content_type: file['content_type'])
      test_procedure.save
    end

    fixtures_setup['source_code_files'].each do |file|
      source_code = SourceCode.find_by(full_id: file['full_id'])

      next unless source_code.present?

      source_code.upload_file.attach(io:           File.open(file['path']),
                                     filename:     file['filename'],
                                     content_type: file['content_type'])
      source_code.save
    end

    fixtures_setup['problem_report_attachment_files'].each do |file|
      problem_report_attachment  = ProblemReportAttachment.find_by(problem_report_id: ProblemReport.find_by(prid: file['prid']).try(:id))

      next unless problem_report_attachment.present?

      problem_report_attachment.file.attach(io:           File.open(file['path']),
                                            filename:     file['filename'],
                                            content_type: file['content_type'])
      problem_report_attachment.save
    end

    fixtures_setup['document_files'].each do |file|
      document  = Document.find_by(docid: file['docid'])

      next unless document.present?

      document.file.attach(io:           File.open(file['path']),
                           filename:     file['filename'],
                           content_type: file['content_type'])

      file_data                  = Rack::Test::UploadedFile.new(file['path'],
                                                                file['content_type'],
                                                                true)
      
      document.store_file(file_data)
      document.save
    end

    fixtures_setup['review_attachment_files'].each do |file|
      review_attachment  = ReviewAttachment.find_by(review_id: Review.find_by(reviewid: file['review_id']).try(:id))

      next unless review_attachment.present?

      review_attachment.file.attach(io:     File.open(file['path']),
                                            filename:     file['filename'],
                                            content_type: file['content_type'])
      review_attachment.save
    end

    rebuild_associations(SystemRequirement.all)
    rebuild_associations(HighLevelRequirement.all)
    rebuild_associations(LowLevelRequirement.all)
    rebuild_associations(TestCase.all)
    rebuild_associations(TestProcedure.all)
    rebuild_associations(ModelFile.all)
    rebuild_associations(SourceCode.all)
    PopulateTemplates.new.populate_templates(DEFAULT_TEMPLATES_FOLDER,
                                             DEFAULT_EMAIL,
                                             DEFAULT_ORGANIZATION) if Thread.current[:populate_templates]

    if Thread.current[:setup_reviews]
      ChecklistItem.destroy_all

      Review.all.each do |review|
        clexec_fillallclitems(review.id, Item.find(review.item_id).try(:level),
                              review.reviewtype)
        copy_checklists_to_evaluators(review.id,
                                      review.evaluators) if review.evaluators.present?

        review.checklists_assigned = true

        review.save
      end
    end

#    Item.all.each { |item| item.duplicate_documents }
  end

  def enlist_fixture_connections(*)
    result = super

    # your code here
    finish_fixture_setup

    result
  end

  # Sign in an admin user.
  def user_admin
    user_admin = User.find_by(email: DEFAULT_EMAIL)

    sign_in user_admin

    return user_admin
  end

  # Sign in the Project Manager user.
  def user_pm
    user_pm = User.find_by(email: PM_EMAIL)

    sign_in user_pm

    return user_pm
  end

  # Sign in the Configuration Manager user.
  def user_cm
    user_cm = User.find_by(email: CM_EMAIL)

    sign_in user_cm

    return user_cm
  end

  # Sign in the Quality Assurance user.
  def user_qa
    user_qa = User.find_by(email: QA_EMAIL)

    sign_in user_qa

    return user_qa
  end

  # Sign in the Team Member user.
  def user_tm
    user_tm = User.find_by(email: TM_EMAIL)

    sign_in user_tm

    return user_tm
  end

  def compare_records(x, y, attributes)
    result = false

    return result unless x.present? && y.present?

    attributes.each do |attribute|
      if x.attributes[attribute].present? && y.attributes[attribute].present?
        result = (x.attributes[attribute] == y.attributes[attribute])
      elsif !x.attributes[attribute].present? && !y.attributes[attribute].present?
        result = true
      else
        result = false
      end

      unless result
        puts "Attribute: #{attribute}, #{x.attributes[attribute]}, #{y.attributes[attribute]} "
        break
      end
    end

    return result
  end

  # Due to the linkage of Model Files we need to clear them for archive tests in Models.
  # They will be tested in the system tests.

  def clear_model_files
    sysreqs                = SystemRequirement.all

    sysreqs.each do |sysreq|
      sysreq.model_file_id = nil

      sysreq.save!
    end

    hlrs                   = HighLevelRequirement.all

    hlrs.each do |hlr|
      hlr.model_file_id    = nil
      hlr.save!
    end

    llrs                   = LowLevelRequirement.all

    llrs.each do |llr|
      llr.model_file_id    = nil
      llr.save!
    end

    tcs                    = TestCase.all

    tcs.each do |tc|
      tc.model_file_id     = nil
      tc.save!
    end
  end
end
