require 'test_helper'

class SystemRequirementTest < ActiveSupport::TestCase
  def compare_sysreqs(x, y,
                   attributes = [
                                  'reqid',
                                  'full_id',
                                  'description',
                                  'source',
                                  'safety',
                                  'implementation',
                                  'version',
                                  'project_id',
                                  'organization',
                                  'category',
                                  'verification_method',
                                  'derived',
                                  'derived_justification',
                                  'archive_id',
                                  'soft_delete',
                                  'document_id',
                                  'model_file_id'
                               ])

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
        puts "#{attribute}: #{x.attributes[attribute]}, #{y.attributes[attribute]}"

        break
      end
    end

    return result
  end

  setup do
    @project            = Project.find_by(identifier: 'TEST')
    @hardware_item      = Item.find_by(identifier: 'HARDWARE_ITEM')
    @software_item      = Item.find_by(identifier: 'SOFTWARE_ITEM')
    @system_requirement = SystemRequirement.find_by(full_id: 'SYS-001')
    @model_file         = ModelFile.find_by(full_id: 'MF-001')
    @file_data          = Rack::Test::UploadedFile.new('test/fixtures/files/flowchart.png',
                                                       'image/png',
                                                       true)

    user_pm
  end

  test "system requirement record should be valid" do
    STDERR.puts('    Check to see that a System Requirement Record with required fields filled in is valid.')
    assert_equals(true, @system_requirement.valid?, 'System Requirement Record', '    Expect System Requirement Record to be valid. It was valid.')
    STDERR.puts('    The System Requirement Record was valid.')
  end

  test "reqid should be present" do
    STDERR.puts('    Check to see that a System Requirement Record without a Requirement ID is invalid.')

    @system_requirement.reqid = nil

    assert_equals(false, @system_requirement.valid?, 'System Requirement Record', '    Expect System Requirement without reqid not to be valid. It was not valid.')
    STDERR.puts('    The System Requirement Record was invalid.')
  end

  test "project_id should be present" do
    STDERR.puts('    Check to see that a System Requirement Record without a Project ID is invalid.')
    @system_requirement.project_id = nil

    assert_equals(false, @system_requirement.valid?, 'System Requirement Record', '    Expect System Requirement without project_id not to be valid. It was not valid.')
    STDERR.puts('    The System Requirement Record was invalid.')
  end

  test "fullreqid should be correct" do
    STDERR.puts('    Check to see that a System Requirement can generate a Full ID correctly.')
    @system_requirement.fullreqid

    assert_equals('SYS-001', @system_requirement.fullreqid, 'System Requirement Record', '    Expect fullreqid with full_id to be "SYS-001". It was.')

    @system_requirement.full_id = nil

    assert_equals('TEST-SYS-1', @system_requirement.fullreqid, 'System Requirement Record', '    Expect fullreqid without full_id to be "TEST-SYS-1". It was.')
    STDERR.puts('    The System Requirement generated a Full ID correctly.')
  end

  test "Create SystemRequirement" do
    STDERR.puts('    Check to see that a System Requirement can be created.')

    system_requirement = SystemRequirement.new({
                                                reqid:                 @system_requirement.reqid + 1,
                                                full_id:               @system_requirement.full_id.sub(/\-001$/, '-002'),
                                                description:           @system_requirement.description,
                                                source:                @system_requirement.source,
                                                safety:                @system_requirement.safety,
                                                implementation:        @system_requirement.implementation,
                                                version:               @system_requirement.version,
                                                project_id:            @system_requirement.project_id,
                                                organization:          @system_requirement.organization,
                                                category:              @system_requirement.category,
                                                verification_method:   @system_requirement.verification_method,
                                                derived:               @system_requirement.derived,
                                                derived_justification: @system_requirement.derived_justification,
                                                archive_id:            @system_requirement.archive_id,
                                                soft_delete:           @system_requirement.soft_delete,
                                                document_id:           @system_requirement.document_id,
                                                model_file_id:         @system_requirement.model_file_id
                                              })

    assert(system_requirement.save)
    STDERR.puts('    A System Requirement was successfully created.')
  end

  test "Update SystemRequirement" do
    STDERR.puts('    Check to see that a System Requirement can be updated.')

    full_id                     = @system_requirement.full_id.dup

    @system_requirement.full_id.sub(/\-001$/, '-002')
    assert(@system_requirement.save)

    @system_requirement.full_id = full_id

    STDERR.puts('    A System Requirement was successfully updated.')
  end

  test "Delete SystemRequirement" do
    STDERR.puts('    Check to see that a System Requirement can be deleted.')
    assert(@system_requirement.destroy)
    STDERR.puts('    A System Requirement was successfully deleted.')
  end

  test "Undo/Redo Create SystemRequirement" do
    STDERR.puts('    Check to see that a System Requirement can be created, then undone and then redone.')

    system_requirement = SystemRequirement.new({
                                                reqid:                 @system_requirement.reqid + 1,
                                                full_id:               @system_requirement.full_id.sub(/\-001$/, '-002'),
                                                description:           @system_requirement.description,
                                                source:                @system_requirement.source,
                                                safety:                @system_requirement.safety,
                                                implementation:        @system_requirement.implementation,
                                                version:               @system_requirement.version,
                                                project_id:            @system_requirement.project_id,
                                                organization:          @system_requirement.organization,
                                                category:              @system_requirement.category,
                                                verification_method:   @system_requirement.verification_method,
                                                derived:               @system_requirement.derived,
                                                derived_justification: @system_requirement.derived_justification,
                                                archive_id:            @system_requirement.archive_id,
                                                soft_delete:           @system_requirement.soft_delete,
                                                document_id:           @system_requirement.document_id,
                                                model_file_id:         @system_requirement.model_file_id
                                              })

    data_change = DataChange.save_or_destroy_with_undo_session(system_requirement, 'create')

    assert_not_nil(data_change)

    assert_difference('SystemRequirement.count', -1) do
      ChangeSession.undo(data_change.session_id)
    end

    assert_difference('SystemRequirement.count', +1) do
      ChangeSession.redo(data_change.session_id)
    end

    STDERR.puts('    A System Requirement was successfully created, then undone and then redone.')
  end

  test "Undo/Redo Update SystemRequirement" do
    STDERR.puts('    Check to see that a System Requirement can be updated, then undone and then redone.')

    full_id           = @system_requirement.full_id.dup
    @system_requirement.full_id += '_001'

    data_change = DataChange.save_or_destroy_with_undo_session(@system_requirement, 'update')

    @system_requirement.full_id = full_id

    assert_not_nil(data_change)
    assert_not_nil(SystemRequirement.find_by(full_id: @system_requirement.full_id + '_001'))
    assert_nil(SystemRequirement.find_by(full_id: @system_requirement.full_id))

    ChangeSession.undo(data_change.session_id)
    assert_nil(SystemRequirement.find_by(full_id: @system_requirement.full_id + '_001'))
    assert_not_nil(SystemRequirement.find_by(full_id: @system_requirement.full_id))

    ChangeSession.redo(data_change.session_id)
    assert_not_nil(SystemRequirement.find_by(full_id: @system_requirement.full_id + '_001'))
    assert_nil(SystemRequirement.find_by(full_id: @system_requirement.full_id))
    STDERR.puts('    A System Requirement was successfully updated, then undone and then redone.')
  end

  test "Undo/Redo Delete SystemRequirement" do
    STDERR.puts('    Check to see that a System Requirement can be deleted, then undone and then redone.')
    data_change = DataChange.save_or_destroy_with_undo_session(@system_requirement, 'delete')

    assert_not_nil(data_change)
    assert_nil(SystemRequirement.find_by(full_id: @system_requirement.full_id))

    ChangeSession.undo(data_change.session_id)
    assert_not_nil(SystemRequirement.find_by(full_id: @system_requirement.full_id))

    ChangeSession.redo(data_change.session_id)
    assert_nil(SystemRequirement.find_by(full_id: @system_requirement.full_id))
    STDERR.puts('    A System Requirement was successfully deleted, then undone and then redone.')
  end

  test 'traced_to_hlrs returns correct response'do
    STDERR.puts('    Check to see that a System Requirement can return the HLRs it is traced to.')
    assert(@system_requirement.traced_to_hlrs)
    STDERR.puts('    The System Requirement can returned the HLRs it is traced to correcly.')
  end

  test 'should add model' do
    STDERR.puts('    Check to see that the System Requirement can attach a model file.')

    @system_requirement.model_file_id = nil

    assert_not_equals_nil(@system_requirement.add_model_document(@file_data, @hardware_item.id, nil), 'System Requirement Record', '    Expect add_model_document to add a model document to a System Requirement. It did.')
    STDERR.puts('    The System Requirement attached a model file successfully.')
  end

  test 'should rename prefix' do
    STDERR.puts('    Check to see that the System Requirement can rename its prefix.')
    original_sysreqs  = SystemRequirement.where(project_id: @project.id)
    original_sysreqs  = original_sysreqs.to_a.sort { |x, y| x.full_id <=> y.full_id}

    SystemRequirement.rename_prefix(@project.id, 'SYS', 'System Requirement')

    renamed_sysreqs   = SystemRequirement.where(project_id: @project.id)
    renamed_sysreqs   = renamed_sysreqs.to_a.sort { |x, y| x.full_id <=> y.full_id}

    original_sysreqs.each_with_index do |sysreq, index|
      expected_id    = sysreq.full_id.sub('SYS', 'System Requirement')
      renamed_sysreq = renamed_sysreqs[index]

      assert_equals(expected_id, renamed_sysreq.full_id, 'System Requirement Full ID', "    Expect full_id to be #{expected_id}. It was.")
    end

    STDERR.puts('    The System Requirement renamed its prefix successfully.')
  end

  test 'should renumber' do
    STDERR.puts('    Check to see that the System Requirement can renumber the Sysreqs.')

    original_sysreqs            = SystemRequirement.where(project_id: @project.id)
    original_sysreqs            = original_sysreqs.to_a.sort { |x, y| x.full_id <=> y.full_id}

    SystemRequirement.renumber(@project.id, 10, 10, 'System Requirement')

    renumberd_sysreqs           = SystemRequirement.where(project_id: @project.id)
    renumberd_sysreqs           = renumberd_sysreqs.to_a.sort { |x, y| x.full_id <=> y.full_id}
    number                      = 10

    original_sysreqs.each_with_index do |sysreq, index|
      expected_id               = sysreq.full_id.sub('SYS', 'System Requirement').sub(/\-\d{3}/, sprintf('-%03d', number))
      renumberd_sysreq          = renumberd_sysreqs[index]

      assert_equals(expected_id, renumberd_sysreq.full_id, 'System Requirement Full ID', "    Expect full_id to be #{expected_id}. It was.")

      number                   += 10
    end

    STDERR.puts('    The System Requirement renumbered the SysReqs successfully.')
  end

  test 'should get columns' do
    STDERR.puts('    Check to see that the System Requirement can return the columns.')

    columns = @system_requirement.get_columns
    columns = columns[1..8] + columns[11..19]

    assert_equals([
                     1, "SYS-001",
                     "The System SHALL maintain proper pump pressure.",
                     "Client Requirements", true, "Hardware", 0, "Test", "test",
                     "Safety", "Test", nil, nil, nil, nil, "", "MF-001"
                  ],
                  columns, 'Columns',
                  '    Expect columns to be [1, "SYS-001", "The System SHALL maintain proper pump pressure.", "Client Requirements", true, "Hardware", 0, "Test", "test", "Safety", "Test", nil, nil, nil, nil, "", "MF-001"]. It was.')
    STDERR.puts('    The System Requirement returned the columns successfully.')
  end

  test 'should generate CSV' do
    STDERR.puts('    Check to see that the System Requirement can generate CSV properly.')

    csv   = SystemRequirement.to_csv(@project.id)
    lines = csv.split("\n")

    assert_equals('id,reqid,full_id,description,source,safety,implementation,version,project_id,created_at,updated_at,organization,category,verification_method,derived,derived_justification,archive_id,soft_delete,document_id,model_file_id',
                  lines[0], 'Header',
                  '    Expect header to be "id,reqid,full_id,description,source,safety,implementation,version,project_id,created_at,updated_at,organization,category,verification_method,derived,derived_justification,archive_id,soft_delete,document_id,model_file_id". It was.')

    lines[1..-1].each do |line|
      assert_not_equals_nil((line =~ /^\d+,\d,SYS-\d{3},.+$/),
                            '    Expect line to be /^\d+,\d,SYS-\d{3},.+$/. It was.')
    end

    STDERR.puts('    The System Requirement generated CSV successfully.')
  end

  test 'should generate XLS' do
    STDERR.puts('    Check to see that the System Requirement can generate XLS properly.')

    assert_nothing_raised do
      xls = SystemRequirement.to_xls(@project.id)

      assert_not_equals_nil(xls, 'XLS Data', '    Expect XLS Data to not be nil. It was.')
    end

    STDERR.puts('    The System Requirement generated XLS successfully.')
  end

  test 'should assign columns' do
    STDERR.puts('    Check to see that the System Requirement can assign columns properly.')

    sysreq = SystemRequirement.new()

    assert(sysreq.assign_column('id', '1', @project.id))
    assert(sysreq.assign_column('reqid', @system_requirement.reqid.to_s,
                                @project.id))
    assert_equals(@system_requirement.reqid, sysreq.reqid, 'Requirement ID',
                  "    Expect Requirement ID to be #{@system_requirement.reqid}. It was.")
    assert(sysreq.assign_column('full_id', @system_requirement.full_id,
                                @project.id))
    assert_equals(@system_requirement.full_id, sysreq.full_id, 'Full ID',
                  "    Expect Full ID to be #{@system_requirement.full_id}. It was.")
    assert(sysreq.assign_column('description', @system_requirement.description,
                                @project.id))
    assert_equals(@system_requirement.description, sysreq.description, 'Description',
                  "    Expect Description to be #{@system_requirement.description}. It was.")
    assert(sysreq.assign_column('source', @system_requirement.source,
                                @project.id))
    assert_equals(@system_requirement.source, sysreq.source, 'Source',
                  "    Expect Source to be #{@system_requirement.source}. It was.")
    assert(sysreq.assign_column('safety', 'true', @project.id))
    assert_equals(true, sysreq.safety, 'Safety',
                  "    Expect Safety from 'true' to be true. It was.")
    assert(sysreq.assign_column('safety', 'false', @project.id))
    assert_equals(false, sysreq.safety, 'Safety',
                  "    Expect Safety from 'false' to be false. It was.")
    assert(sysreq.assign_column('safety', 'yes', @project.id))
    assert_equals(true, sysreq.safety, 'Safety',
                  "    Expect Safety from 'yes' to be true. It was.")
    assert(sysreq.assign_column('implementation', @system_requirement.implementation,
                                @project.id))
    assert_equals(@system_requirement.implementation, sysreq.implementation, 'Implementation',
                  "    Expect Implementation to be #{@system_requirement.implementation}. It was.")
    assert(sysreq.assign_column('version', @system_requirement.version.to_s, @project.id))
    assert_equals(@system_requirement.version, sysreq.version, 'Version',
                  "    Expect Version to be #{@system_requirement.version}. It was.")
    assert(sysreq.assign_column('project_id', 'Test', @project.id))
    assert_equals(@project.id, sysreq.project_id, 'Project ID',
                  "    Expect Project ID to be #{@project.id}. It was.")
    assert(sysreq.assign_column('category', @system_requirement.category,
                                @project.id))
    assert_equals(@system_requirement.category, sysreq.category, 'Category',
                  "    Expect Category to be #{@system_requirement.category}. It was.")
    assert(sysreq.assign_column('verification_method',
                                @system_requirement.verification_method.join(','),
                                @project.id))
    assert_equals(@system_requirement.verification_method, sysreq.verification_method, 'Verification Method',
                  "    Expect Verification Method to be #{@system_requirement.verification_method.join(',')}. It was.")
    assert(sysreq.assign_column('derived', 'true', @project.id))
    assert_equals(true, sysreq.derived, 'Derived',
                  "    Expect Derived from 'true' to be true. It was.")
    assert(sysreq.assign_column('derived', 'false', @project.id))
    assert_equals(false, sysreq.derived, 'Derived',
                  "    Expect Derived from 'false' to be false. It was.")
    assert(sysreq.assign_column('derived', 'yes', @project.id))
    assert_equals(true, sysreq.derived, 'Derived',
                  "    Expect Derived from 'yes' to be true. It was.")
    assert(sysreq.assign_column('derived_justification', 'Because', @project.id))
    assert_equals('Because', sysreq.derived_justification, 'Derived Justification',
                  "    Expect Derived Justification to be 'Because'. It was.")
    assert(sysreq.assign_column('document_id', 'PHAC', @project.id))
    assert_equals(Document.find_by(docid: 'PHAC').try(:id),
                  sysreq.document_id,
                  'Document ID',
                  "    Expect Document ID to be #{Document.find_by(docid: 'PHAC').try(:id)}. It was.")
    assert(sysreq.assign_column('model_file_id', 'MF-001',
                                @project.id))
    assert_equals(@system_requirement.model_file_id, sysreq.model_file_id,
                  'Model File ID',
                  "    Expect Model File ID to be #{@system_requirement.model_file_id}. It was.")
    assert(sysreq.assign_column('created_at', @system_requirement.created_at.to_s,
                                @project.id))
    assert(sysreq.assign_column('updated_at', @system_requirement.updated_at.to_s,
                                @project.id))
    assert(sysreq.assign_column('organization', @system_requirement.organization,
                                @project.id))
    assert(sysreq.assign_column('soft_delete', 'true', @project.id))
    assert_equals(true, sysreq.soft_delete, 'Soft Delete',
                  "    Expect Soft Delete from 'true' to be true. It was.")
    assert(sysreq.assign_column('soft_delete', 'false', @project.id))
    assert_equals(false, sysreq.soft_delete, 'Soft Delete',
                  "    Expect Soft Delete from 'false' to be false. It was.")
    assert(sysreq.assign_column('soft_delete', 'yes', @project.id))
    assert_equals(true, sysreq.soft_delete, 'Soft Delete',
                  "    Expect Soft Delete from 'yes' to be true. It was.")
    assert(sysreq.assign_column('archive_revision', 'a', @project.id))
    assert(sysreq.assign_column('archive_version', '1.1', @project.id))
    STDERR.puts('    The System Requirement assigned the columns successfully.')
  end

  test 'should parse CSV string' do
    STDERR.puts('    Check to see that the System Requirement can parse CSV properly.')

    attributes = [
                   'description',
                   'source',
                   'safety',
                   'implementation',
                   'version',
                   'project_id',
                   'organization',
                   'category',
                   'verification_method',
                   'derived',
                   'derived_justification',
                   'archive_id',
                   'soft_delete',
                   'document_id',
                   'model_file_id'
                 ]
    csv        = SystemRequirement.to_csv(@project.id)
    lines      = csv.split("\n")

    assert_equals(:duplicate_system_requirement,
                  SystemRequirement.from_csv_string(lines[1],
                                                    @project,
                                                    [ :check_duplicates ]),
                  'System Requirement Records',
                  '    Expect Duplicate System Requirement Records to error. They did.')

    line       = lines[1].gsub('1,SYS-001', '3,SYS-003')

    assert(SystemRequirement.from_csv_string(line, @project))

    sysreq        = SystemRequirement.find_by(full_id: 'SYS-003')

    assert_equals(true, compare_sysreqs(@system_requirement, sysreq, attributes),
                  'System Requirement Records',
                  '    Expect System Requirement Records to match. They did.')
    STDERR.puts('    The System Requirement parsed CSV successfully.')
  end

  test 'should parse files' do
    STDERR.puts('    Check to see that the System Requirement can parse files properly.')

    assert_equals(:duplicate_system_requirement,
                  SystemRequirement.from_file('test/fixtures/files/Test-System_Requirements.csv',
                                              @project,
                                              [ :check_duplicates ]),
                  'System Requirement Records from Test-System_Requirements.csv',
                  '    Expect Duplicate System Requirement Records to error. They did.')
    assert_equals(true,
                  SystemRequirement.from_file('test/fixtures/files/Test-System_Requirements.csv',
                                              @project),
                  'System Requirement Records From Test-System_Requirements.csv',
                  '    Expect Changed System Requirement Associations Records  from Test-System_Requirements.csv to error. They did.')
    assert_equals(:duplicate_system_requirement,
                  SystemRequirement.from_file('test/fixtures/files/Test-System_Requirements.xls',
                                              @project,
                                              [ :check_duplicates ]),
                  'System Requirement Records from Test-System_Requirements.csv',
                  '    Expect Duplicate System Requirement Records to error. They did.')
    assert_equals(true,
                  SystemRequirement.from_file('test/fixtures/files/Test-System_Requirements.xls',
                                              @project),
                  'System Requirement Records From Test-System_Requirements.csv',
                  '    Expect Changed System Requirement Associations Records  from Test-System_Requirements.csv to error. They did.')
    assert_equals(:duplicate_system_requirement,
                  SystemRequirement.from_file('test/fixtures/files/Test-System_Requirements.xlsx',
                                              @project,
                                              [ :check_duplicates ]),
                  'System Requirement Records from Test-System_Requirements.csv',
                  '    Expect Duplicate System Requirement Records to error. They did.')
    assert_equals(true,
                  SystemRequirement.from_file('test/fixtures/files/Test-System_Requirements.xlsx',
                                              @project),
                  'System Requirement Records From Test-System_Requirements.csv',
                  '    Expect Changed System Requirement Associations Records  from Test-System_Requirements.csv to error. They did.')
    STDERR.puts('    The System Requirement parsed files successfully.')
  end
end
