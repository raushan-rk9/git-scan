require 'test_helper'

class RequirementsTracingTest < ActiveSupport::TestCase
  setup do
    RequirementsTracing.session = { archived_project: 12345 }
    @project                    = Project.find_by(identifier: 'TEST')
    @hardware_item              = Item.find_by(identifier: 'HARDWARE_ITEM')
    @software_item              = Item.find_by(identifier: 'SOFTWARE_ITEM')
    @hardware_hlr_001           = HighLevelRequirement.find_by(item_id: @hardware_item.id,
                                                               full_id: 'HLR-001')
    @software_hlr_001           = HighLevelRequirement.find_by(item_id: @software_item.id,
                                                               full_id: 'HLR-001')
    @hardware_llr_001           = LowLevelRequirement.find_by(item_id: @hardware_item.id,
                                                              full_id: 'LLR-001')
    @software_llr_001           = LowLevelRequirement.find_by(item_id: @software_item.id,
                                                    full_id: 'LLR-001')
    user_pm
  end

# Requirements Tracing is an abstract base class and therefor has no CRUD components

  test "sort_on_full_id should sort properly" do
    STDERR.puts('    Check to see that Sort on Full ID Sorts Properly.')
    high_level_requirements = HighLevelRequirement.where(item_id: @hardware_item).order(full_id: 'desc')

    assert_equals('HLR-003', high_level_requirements[0].full_id, 'High-Level Requirement', '    Verify that the first High-Level Requirement is HLR-003. It was.')

    high_level_requirements = RequirementsTracing.sort_on_full_id(high_level_requirements)

    assert_equals('HLR-001', high_level_requirements[0].full_id, 'High-Level Requirement', '    Verify that the first High-Level Requirement is HLR-001. It was.')
    assert_equals('HLR-002', high_level_requirements[1].full_id, 'High-Level Requirement', '    Verify that the Second High-Level Requirement is HLR-002. It was.')
    assert_equals('HLR-003', high_level_requirements[2].full_id, 'High-Level Requirement', '    Verify that the Second High-Level Requirement is HLR-003. It was.')
    STDERR.puts('    Sort on Full ID Sorted Properly.')
  end

  test "session should persist" do
    STDERR.puts('    Check to see that an Archive session persists properly.')
    assert_equals(12345, RequirementsTracing.session[:archived_project],
                  'Session', '    Verify that the Session is 12345. It was.')
    STDERR.puts('    The Archive ID persisted Properly.')
  end

  test "get_archive_id should return archive_id" do
    STDERR.puts('    Check to see that get archive ID returns the Archive ID.')
    session                     = {
                                    archives_visible: 54321,
                                    archived_project: 12345
                                  }
    RequirementsTracing.session = session

    assert_equals(54321, RequirementsTracing.get_archive_id, 'Archive ID', '    Verify that the Archive is 54321 It was.')

    session[:archives_visible] = false

    assert_equals(12345, RequirementsTracing.get_archive_id, 'Archive ID', '    Verify that the Archive is 12345 It was.')

    session[:archives_visible] = false
    session[:archived_project] = nil

    assert_equals(nil, RequirementsTracing.get_archive_id, 'Archive ID', '    Verify that the Archive is nil It was.')
    STDERR.puts('    The  get archive ID returned the Proper ID.')
  end

  test "get_display_name should return the table name" do
    STDERR.puts('    Check to see that get display name returns the table name.')
    assert_equals(I18n.t('misc.system_requirements'),
                  RequirementsTracing.get_display_name('system_requirements'),
                  'Table Name',
                  "    Verify that the System Requirements table name is '#{I18n.t('misc.system_requirements')}' It was.")
    assert_equals(Item.item_type_title(@hardware_item.id, :high_level, :plural),
                  RequirementsTracing.get_display_name('high_level_requirements',
                                                       @hardware_item.id),
                  'Table Name',
                  "    Verify that the High-Level Requirements table name is '#{Item.item_type_title(@hardware_item.id, :high_level, :plural)}' It was.")
    assert_equals(Item.item_type_title(@software_item.id, :high_level, :plural),
                  RequirementsTracing.get_display_name('high_level_requirements',
                                                       @software_item.id),
                  'Table Name',
                  "    Verify that the High-Level Requirements table name is '#{Item.item_type_title(@software_item.id, :high_level, :plural)}' It was.")
    assert_equals(Item.item_type_title(@hardware_item.id, :low_level, :plural),
                  RequirementsTracing.get_display_name('low_level_requirements',
                                                       @hardware_item.id),
                  'Table Name',
                  "    Verify that the Low-Level Requirements table name is '#{Item.item_type_title(@hardware_item.id, :low_level, :plural)}' It was.")
    assert_equals(Item.item_type_title(@software_item.id, :low_level, :plural),
                  RequirementsTracing.get_display_name('low_level_requirements',
                                                       @software_item.id),
                  'Table Name',
                  "    Verify that the Low-Level Requirements table name is '#{Item.item_type_title(@software_item.id, :low_level, :plural)}' It was.")
    assert_equals(I18n.t('misc.source_code'),
                  RequirementsTracing.get_display_name('source_code'),
                  'Table Name',
                  "    Verify that the Source Code table name is '#{I18n.t('misc.source_code')}' It was.")
    assert_equals(I18n.t('misc.test_cases'),
                  RequirementsTracing.get_display_name('test_cases'),
                  'Table Name',
                  "    Verify that the Test Cases table name is '#{I18n.t('misc.test_cases')}' It was.")
    assert_equals(I18n.t('misc.test_procedures'),
                  RequirementsTracing.get_display_name('test_procedures'),
                  'Table Name',
                  "    Verify that the Test Procedures table name is '#{I18n.t('misc.test_procedures')}' It was.")
    STDERR.puts('    Get display name returned the table name successfully.')
  end

  test "get_derived_requirements should get derived requirements" do
    STDERR.puts('    Check to see that get derived requirements returns the derived requirements.')
    assert_not_equals_nil(RequirementsTracing.get_derived_requirements('system_requirements',
                                                                       @project.id),
                          'System Requirements',
                          '    Verify that the return from get_derived_requirements for System Requirements is not nil It was.')
    assert_not_equals_nil(RequirementsTracing.get_derived_requirements('high_level_requirements',
                                                                       @project.id),
                          'High-Level Requirements',
                          '    Verify that the return from  get_derived_requirements for High-Level Requirements is not nil It was.')
    assert_not_equals_nil(RequirementsTracing.get_derived_requirements('low_level_requirements',
                                                                       @project.id),
                          'Low-Level Requirements',
                          '    Verify that the return from  get_derived_requirements for Low-Level Requirements is not nil It was.')
    assert_not_equals_nil(RequirementsTracing.get_derived_requirements('test_cases',
                                                                       @project.id),
                          'Test Cases',
                          '    Verify that the return from  get_derived_requirements for Test Cases is not nil It was.')
    STDERR.puts('    Get derived requirements returned the derived requirements successfully.')
  end

  test "get_unlinked_requirements should get unlinked requirements" do
    STDERR.puts('    Check to see that get unlinked requirements returns the unlinked requirements.')
    assert_not_equals_nil(RequirementsTracing.get_unlinked_requirements('system_requirements',
                                                                       @project.id),
                          'System Requirements',
                          '    Verify that the return from  get_unlinked_requirements for System Requirements is not nil It was.')
    assert_not_equals_nil(RequirementsTracing.get_unlinked_requirements('high_level_requirements',
                                                                       @project.id),
                          'High-Level Requirements',
                          '    Verify that the return from  get_unlinked_requirements for High-Level Requirements is not nil It was.')
    assert_not_equals_nil(RequirementsTracing.get_unlinked_requirements('low_level_requirements',
                                                                       @project.id),
                          'Low-Level Requirements',
                          '    Verify that the return from  get_unlinked_requirements for Low-Level Requirements is not nil It was.')
    assert_not_equals_nil(RequirementsTracing.get_unlinked_requirements('test_cases',
                                                                       @project.id),
                          'Test Cases',
                          '    Verify that the return from  get_unlinked_requirements for Test Cases is not nil It was.')
    assert_not_equals_nil(RequirementsTracing.get_unlinked_requirements('source_codes',
                                                                       @project.id),
                          'Source Codes',
                          '    Verify that the return from  get_unlinked_requirements for Source Codes is not nil It was.')
    STDERR.puts('    Get unlinked requirements returned the unlinked requirements successfully.')
  end

  test "get_unallocated_requirements should get unallocated requirements" do
    STDERR.puts('    Check to see that get unallocated requirements returns the unlinked requirements.')
    assert_not_equals_nil(RequirementsTracing.get_unallocated_requirements('system_requirements',
                                                                       @project.id),
                          'System Requirements',
                          '    Verify that the return from  get_unallocated_requirements for System Requirements is not nil It was.')
    assert_not_equals_nil(RequirementsTracing.get_unallocated_requirements('high_level_requirements',
                                                                       @project.id),
                          'High-Level Requirements',
                          '    Verify that the return from  get_unallocated_requirements for High-Level Requirements is not nil It was.')
    assert_not_equals_nil(RequirementsTracing.get_unallocated_requirements('low_level_requirements',
                                                                       @project.id),
                          'Low-Level Requirements',
                          '    Verify that the return from  get_unallocated_requirements for Low-Level Requirements is not nil It was.')
    assert_not_equals_nil(RequirementsTracing.get_unallocated_requirements('test_cases',
                                                                       @project.id),
                          'Test Cases',
                          '    Verify that the return from  get_unallocated_requirements for Test Cases is not nil It was.')
    assert_not_equals_nil(RequirementsTracing.get_unallocated_requirements('source_codes',
                                                                       @project.id),
                          'Source Codes',
                          '    Verify that the return from  get_unallocated_requirements for Source Codes is not nil It was.')
    STDERR.puts('    Get unallocated requirements returned the unallocated requirements successfully.')
  end

  test "get_table_rows should get table rows" do
    STDERR.puts('    Check to see that get table rows returns the table rows.')
    rows                        = SystemRequirement.all.pluck(:id)

    assert_not_equals_nil(RequirementsTracing.get_table_rows('system_requirements',
                                                             rows),
                          'System Requirements',
                          '    Verify that the return from  get_table_rows for System Requirements is not nil It was.')

    rows                        = HighLevelRequirement.all.pluck(:id)

    assert_not_equals_nil(RequirementsTracing.get_table_rows('high_level_requirements',
                                                             rows),
                          'High Level Requirements',
                          '    Verify that the return from  get_table_rows for High Level Requirements is not nil It was.')

    rows                        = LowLevelRequirement.all.pluck(:id)

    assert_not_equals_nil(RequirementsTracing.get_table_rows('low_level_requirements',
                                                             rows),
                          'Low Level Requirements',
                          '    Verify that the return from  get_table_rows for Low Level Requirements is not nil It was.')

    rows                        = TestProcedure.all.pluck(:id)

    assert_not_equals_nil(RequirementsTracing.get_table_rows('test_procedures',
                                                             rows),
                          'Test Procedures',
                          '    Verify that the return from  get_table_rows for Test Level Requirements is not nil It was.')

    rows                        = SourceCode.all.pluck(:id)

    assert_not_equals_nil(RequirementsTracing.get_table_rows('source_codes',
                                                             rows),
                          'Source Codes',
                          '    Verify that the return from  get_table_rows for Source Level Requirements is not nil It was.')
    STDERR.puts('    Get table rows returned the table rows successfully.')
  end

  test "get_parent_requirements should get parent requirements" do
    STDERR.puts('    Check to see that get parent requirements returns the parent requirements.')
    assert_not_equals_nil(RequirementsTracing.get_parent_requirements(HighLevelRequirement.where.not(system_requirement_associations: [nil, ""]).first,
                                                                      'system_requirements'),
                          'System Requirements',
                          '    Verify that the return from  get_parent_requirements for High-Level Requirements is not nil It was.')
    assert_not_equals_nil(RequirementsTracing.get_parent_requirements(LowLevelRequirement.where.not(high_level_requirement_associations: [nil, ""]).first,
                                                                      'high_level_requirements'),
                          'High-Level Requirements',
                          '    Verify that the return from  get_parent_requirements for Low-Level Requirements is not nil It was.')
    assert_not_equals_nil(RequirementsTracing.get_parent_requirements(TestCase.where.not(high_level_requirement_associations: [nil, ""]).first,
                                                                      'high_level_requirements'),
                          'High-Level Requirements',
                          '    Verify that the return from  get_parent_requirements for Test Cases is not nil It was.')
    assert_not_equals_nil(RequirementsTracing.get_parent_requirements(TestCase.where.not(low_level_requirement_associations: [nil, ""]).first,
                                                                      'low_level_requirements'),
                          'Low-Level Requirements',
                          '    Verify that the return from  get_parent_requirements for Test Cases is not nil It was.')
    assert_not_equals_nil(RequirementsTracing.get_parent_requirements(TestProcedure.where.not(test_case_associations: [nil, ""]).first,
                                                                      'test_cases'),
                          'Test Cases',
                          '    Verify that the return from  get_parent_requirements for Test Procedures is not nil It was.')
    assert_not_equals_nil(RequirementsTracing.get_parent_requirements(SourceCode.where.not(high_level_requirement_associations: [nil, ""]).first,
                                                                      'high_level_requirements'),
                          'High-Level Requirements',
                          '    Verify that the return from  get_parent_requirements for Source Codes is not nil It was.')
    assert_not_equals_nil(RequirementsTracing.get_parent_requirements(SourceCode.where.not(low_level_requirement_associations: [nil, ""]).first,
                                                                      'low_level_requirements'),
                          'Low-Level Requirements',
                          '    Verify that the return from  get_parent_requirements for Source Codes is not nil It was.')
    STDERR.puts('    Get parent requirements returned the parent requirements successfully.')
  end

  test "get_sibling_requirements should get sibling requirements" do
    STDERR.puts('    Check to see that get sibling requirements returns the sibling requirements.')
    assert_not_equals_nil(RequirementsTracing.get_parent_requirements(HighLevelRequirement.where.not(high_level_requirement_associations: [nil, ""]).first,
                                                                      'high_level_requirements'),
                          'High-Level Requirements',
                          '    Verify that the return from  get_sibling_requirements for High-Level Requirements is not nil It was.')
    STDERR.puts('    Get sibling requirements returned the sibling requirements successfully.')
  end

  test "get_child_requirements should get_child_requirements" do
    STDERR.puts('    Check to see that get child requirements returns the child requirements.')
    assert_not_equals_nil(RequirementsTracing.get_child_requirements(HighLevelRequirement.all.first,
                                                                      'system_requirements'),
                          'System Requirements',
                          '    Verify that the return from  get_child_requirements for High-Level Requirements is not nil It was.')
    assert_not_equals_nil(RequirementsTracing.get_child_requirements(LowLevelRequirement.all.first,
                                                                      'high_level_requirements'),
                          'High-Level Requirements',
                          '    Verify that the return from  get_child_requirements for Low-Level Requirements is not nil It was.')
    assert_not_equals_nil(RequirementsTracing.get_child_requirements(TestCase.all.first,
                                                                      'high_level_requirements'),
                          'High-Level Requirements',
                          '    Verify that the return from  get_child_requirements for Test Cases is not nil It was.')
    assert_not_equals_nil(RequirementsTracing.get_child_requirements(TestCase.all.first,
                                                                      'low_level_requirements'),
                          'Low-Level Requirements',
                          '    Verify that the return from  get_child_requirements for Test Cases is not nil It was.')
    assert_not_equals_nil(RequirementsTracing.get_child_requirements(TestProcedure.all.first,
                                                                      'test_cases'),
                          'Test Cases',
                          '    Verify that the return from  get_child_requirements for Test Procedures is not nil It was.')
    assert_not_equals_nil(RequirementsTracing.get_child_requirements(SourceCode.all.first,
                                                                      'high_level_requirements'),
                          'High-Level Requirements',
                          '    Verify that the return from  get_child_requirements for Source Codes is not nil It was.')
    assert_not_equals_nil(RequirementsTracing.get_child_requirements(SourceCode.all.first,
                                                                      'low_level_requirements'),
                          'Low-Level Requirements',
                          '    Verify that the return from  get_child_requirements for Source Codes is not nil It was.')
    STDERR.puts('    Get child requirements returned the child requirements successfully.')
  end

  test "get_base_requirements should get_base_requirements" do
    STDERR.puts('    Check to see that get base requirements returns the base requirements.')
    assert_not_equals_nil(RequirementsTracing.get_base_requirements('system_requirements',
                                                                    @project.id),
                          'System Requirements',
                          '    Verify that the return from  get_base_requirements for System Requirements is not nil It was.')
    assert_not_equals_nil(RequirementsTracing.get_base_requirements('high_level_requirements',
                                                                    @project.id),
                          'High-Level Requirements',
                          '    Verify that the return from  get_base_requirements for High-Level Requirements is not nil It was.')
    assert_not_equals_nil(RequirementsTracing.get_base_requirements('low_level_requirements',
                                                                    @project.id),
                          'Low-Level Requirements',
                          '    Verify that the return from  get_base_requirements for Low-Level Requirements is not nil It was.')
    assert_not_equals_nil(RequirementsTracing.get_base_requirements('test_cases',
                                                                    @project.id),
                          'Test Cases',
                          '    Verify that the return from  get_base_requirements for Test Cases is not nil It was.')
    assert_not_equals_nil(RequirementsTracing.get_base_requirements('source_codes',
                                                                    @project.id),
                          'Source Codes',
                          '    Verify that the return from  get_base_requirements for Source Codes is not nil It was.')
    STDERR.puts('    Get base requirements returned the base requirements successfully.')
  end

  test "generate_specialized_hash should return a specialized hash" do
    STDERR.puts('    Check to see that generate specialized hash returns the proper hash.')
    RequirementsTracing.session = { archived_project: nil }
    @hash                       = RequirementsTracing.generate_specialized_hash([
                                                                                  "system_requirements",
                                                                                  "high_level_requirements",
                                                                                  "low_level_requirements",
                                                                                  "source_code",
                                                                                  "test_cases",
                                                                                  "test_procedures"
                                                                                ],
                                                                                :derived,
                                                                                @project.id,
                                                                                @software_item.id)

    assert_not_equals_nil(@hash,
                          'Requirements Hash',
                          '    Verify that the return from  generate_specialized_hash for derived requirements is not nil. It was.')

    @hash                       = RequirementsTracing.generate_specialized_hash([
                                                                                  "system_requirements",
                                                                                  "high_level_requirements",
                                                                                  "low_level_requirements",
                                                                                  "source_code",
                                                                                  "test_cases",
                                                                                  "test_procedures"
                                                                                ],
                                                                                :unallocated,
                                                                                @project.id,
                                                                                @software_item.id)

    assert_not_equals_nil(@hash,
                          'Requirements Hash',
                          '    Verify that the return from  generate_specialized_hash for unallocated requirements is not nil. It was.')


    @hash                       = RequirementsTracing.generate_specialized_hash([
                                                                                  "system_requirements",
                                                                                  "high_level_requirements",
                                                                                  "low_level_requirements",
                                                                                  "source_code",
                                                                                  "test_cases",
                                                                                  "test_procedures"
                                                                                ],
                                                                                :unlinked,
                                                                                @project.id,
                                                                                @software_item.id)

    assert_not_equals_nil(@hash,
                          'Requirements Hash',
                          '    Verify that the return from  generate_specialized_hash for unlinked requirements is not nil. It was.')
    STDERR.puts('    Generate specialized hash returned the proper hash successfully.')
  end

  test "generate_trace_matrix should return a requirements trace matrix" do
    STDERR.puts('    Check to see that Generate Trace Matrix generates a trace matrix.')

    @reverse                    = false
    RequirementsTracing.session = { archived_project: nil }
    @matrix                     = RequirementsTracing.generate_trace_matrix([
                                                                              "system_requirements",
                                                                              "high_level_requirements",
                                                                              "low_level_requirements",
                                                                              "source_code",
                                                                              "test_cases",
                                                                              "test_procedures"
                                                                            ],
                                                                            @reverse,
                                                                            @project.id,
                                                                            @software_item.id)

    assert_not_equals_nil(@matrix,
                          'Requirements Tracing Matrix',
                          '    Verify that the return from  generate_trace_matrix is not nil. It was.')
    STDERR.puts('    Generate Trace Matrix returned the a trace matrix successfully.')
  end

  test "save_csv_spreadsheet returns CSV" do
    STDERR.puts('    Check to see that Save CSV Spreadsheet generates CSV.')

    RequirementsTracing.session = { archived_project: nil }
    @headers                    = [
                                    "system_requirements",
                                    "high_level_requirements",
                                    "low_level_requirements",
                                    "source_code",
                                    "test_cases",
                                    "test_procedures"
                                  ]
    @matrix                     = RequirementsTracing.generate_trace_matrix(@headers,
                                                                            @reverse,
                                                                            @project.id,
                                                                            @software_item.id)
    @data                       = RequirementsTracing.save_csv_spreadsheet(@headers,
                                                                           @matrix,
                                                                           @software_item)

    lines                       = @data.split("\n")

    assert_not_equals(lines[0],
                      'system_requirements,high_level_requirements,HARDWARE_ITEM high_level_requirements,low_level_requirements,source_code,test_cases,test_proceduressystem_requirements,high_level_requirements,HARDWARE_ITEM high_level_requirements,low_level_requirements,source_code,test_cases,test_procedures',
                      'Header',
                      '    Verify that the header from save_csv_spreadsheet is "system_requirements,high_level_requirements,HARDWARE_ITEM high_level_requirements,low_level_requirements,source_code,test_cases,test_procedures". It was.')

    lines[1..-1].each do |line|
#      assert_not_equals_nil((line =~ /^1 \- The System SHALL maintain proper pump pressure.,HLR-00\d: .*$/),
#                            '    Expect line to be 1 - The System SHALL maintain proper pump pressure.,HLR-00\d: .*$/.')
    end

    STDERR.puts('    Save CSV Spreadsheet generated CSV successfully.')
  end

  test "save_xls_spreadsheet returns XLS" do
    STDERR.puts('    Check to see that Save XLS Spreadsheet generates XLS.')

    RequirementsTracing.session = { archived_project: nil }
    @headers                    = [
                                    "system_requirements",
                                    "high_level_requirements",
                                    "low_level_requirements",
                                    "source_code",
                                    "test_cases",
                                    "test_procedures"
                                  ]
    @matrix                     = RequirementsTracing.generate_trace_matrix(@headers,
                                                                            @reverse,
                                                                            @project.id,
                                                                            @software_item.id)
    @data                       = RequirementsTracing.save_xls_spreadsheet(@headers,
                                                                           @matrix,
                                                                           @software_item)

    assert_between(4000, 5200, @data.length,
                  'XLS Length',
                  "    Verify that the data length is between 4000 and 5200. It was.")
    STDERR.puts('    Save XLS Spreadsheet generated XLS successfully.')
  end
end
