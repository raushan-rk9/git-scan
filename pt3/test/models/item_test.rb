require 'test_helper'

class ItemTest < ActiveSupport::TestCase
  def setup
    @project       = Project.find_by(identifier: 'TEST')
    @hardware_item = Item.find_by(identifier: 'HARDWARE_ITEM')
    @software_item = Item.find_by(identifier: 'SOFTWARE_ITEM')

    user_pm
  end

  test 'item record should be valid' do
    STDERR.puts('    Check to see that a Item Record with required fields filled in is valid.')
    assert_equals(true, @hardware_item.valid?, 'Item Record',
                  '    Expect Item Record to be valid. It was valid.')
    STDERR.puts('    The Item Record was valid.')
  end

  test 'project id shall be present for Item' do
    STDERR.puts('    Check to see that a Item Record without a Project ID is invalid.')

    @hardware_item.project_id = nil

    assert_equals(false, @hardware_item.valid?,
                  'Item Record', '    Expect Item without project_id not to be valid. It was not valid.')
    STDERR.puts('    The Item Record was invalid.')
  end

  test 'name shall be present for Item' do
    STDERR.puts('    Check to see that a item Record without a Name is invalid.')

    @hardware_item.name = nil

    assert_equals(false, @hardware_item.valid?,
                  'Item Record',
                  '    Expect Item without name not to be valid. It was not valid.')
    STDERR.puts('    The Item Record was invalid.')
  end

  test 'identifier shall be present for Item' do
    STDERR.puts('    Check to see that a item Record without an Identifier is invalid.')

    @hardware_item.identifier = nil

    assert_equals(false, @hardware_item.valid?, 'Item Record', '    Expect Item without identifier not to be valid. It was not valid.')
    STDERR.puts('    The Item Record was invalid.')
  end

# We implement CRUD Testing by default. The Read Action is implicit in setup.

  test 'should create Item' do
    STDERR.puts('    Check to see that an Item can be created.')

    item = Item.new({
                       name:                           @hardware_item.name       + '_001',
                       itemtype:                       @hardware_item.itemtype,
                       identifier:                     @hardware_item.identifier + '_001',
                       level:                          @hardware_item.level,
                       project_id:                     @hardware_item.project_id,
                       hlr_count:                      @hardware_item.hlr_count,
                       llr_count:                      @hardware_item.llr_count,
                       review_count:                   @hardware_item.review_count,
                       tc_count:                       @hardware_item.tc_count,
                       sc_count:                       @hardware_item.sc_count,
                       created_at:                     @hardware_item.created_at,
                       updated_at:                     @hardware_item.updated_at,
                       organization:                   @hardware_item.organization,
                       archive_id:                     @hardware_item.archive_id,
                       high_level_requirements_prefix: @hardware_item.high_level_requirements_prefix,
                       low_level_requirements_prefix:  @hardware_item.low_level_requirements_prefix,
                       source_code_prefix:             @hardware_item.source_code_prefix,
                       test_case_prefix:               @hardware_item.test_case_prefix,
                       test_procedure_prefix:          @hardware_item.test_procedure_prefix,
                       tp_count:                       @hardware_item.tp_count,
                       model_file_prefix:              @hardware_item.model_file_prefix
                    })

    assert_not_equals_nil(item.save, 'Item Record', '    Expect Item Record to be created. It was.')
    STDERR.puts('    An Item was successfully created.')
  end

  test 'should update Item' do
    STDERR.puts('    Check to see that an Item can be updated.')

    identifier                 = @hardware_item.identifier.dup
    @hardware_item.identifier += '_001'

    assert_not_equals_nil(@hardware_item.save, 'Item Record', '    Expect Item Record to be updated. It was.')

    @hardware_item.identifier  = identifier
    STDERR.puts('    An Item was successfully updated.')
  end

  test 'should delete Item' do
    STDERR.puts('    Check to see that an Item can be deleted.')
    assert(@hardware_item.destroy)
    STDERR.puts('    An Item was successfully deleted.')
  end

  test 'should create Item with undo/redo' do
    STDERR.puts('    Check to see that an Item can be created, then undone and then redone.')

    item        = Item.new({
                              name:                           @hardware_item.name       + '_001',
                              itemtype:                       @hardware_item.itemtype,
                              identifier:                     @hardware_item.identifier + '_001',
                              level:                          @hardware_item.level,
                              project_id:                     @hardware_item.project_id,
                              hlr_count:                      @hardware_item.hlr_count,
                              llr_count:                      @hardware_item.llr_count,
                              review_count:                   @hardware_item.review_count,
                              tc_count:                       @hardware_item.tc_count,
                              sc_count:                       @hardware_item.sc_count,
                              created_at:                     @hardware_item.created_at,
                              updated_at:                     @hardware_item.updated_at,
                              organization:                   @hardware_item.organization,
                              archive_id:                     @hardware_item.archive_id,
                              high_level_requirements_prefix: @hardware_item.high_level_requirements_prefix,
                              low_level_requirements_prefix:  @hardware_item.low_level_requirements_prefix,
                              source_code_prefix:             @hardware_item.source_code_prefix,
                              test_case_prefix:               @hardware_item.test_case_prefix,
                              test_procedure_prefix:          @hardware_item.test_procedure_prefix,
                              tp_count:                       @hardware_item.tp_count,
                              model_file_prefix:              @hardware_item.model_file_prefix
                           })
    data_change = DataChange.save_or_destroy_with_undo_session(item, 'create')

    assert_not_equals_nil(data_change, 'Item Record', '    Expect Item Record to be created. It was.')

    assert_difference('Item.count', -1) do
      ChangeSession.undo(data_change.session_id)
    end

    assert_difference('Item.count', +1) do
      ChangeSession.redo(data_change.session_id)
    end

    STDERR.puts('    An Item was successfully created, then undone and then redone.')
  end

  test 'should update Item with undo/redo' do
    STDERR.puts('    Check to see that an Item can be updated, then undone and then redone.')

    identifier                 = @hardware_item.identifier.dup
    @hardware_item.identifier += '_001'
    data_change                = DataChange.save_or_destroy_with_undo_session(@hardware_item, 'update')
    @hardware_item.identifier  = identifier

    assert_not_equals_nil(data_change, 'Item Record',
                          '    Expect Item Record to be updated. It was')
    assert_not_equals_nil(Item.find_by(identifier: @hardware_item.identifier + '_001'),
                          'Item Record',
                          "    Expect Item Record's ID to be #{@hardware_item.identifier + '_001'}. It was.")
    assert_equals(nil, Item.find_by(identifier: @hardware_item.identifier),
                  'Item Record',
                  '    Expect original Item Record not to be found. It was not found.')

    ChangeSession.undo(data_change.session_id)
    assert_equals(nil, Item.find_by(identifier: @hardware_item.identifier + '_001'),
                  'Item Record',
                  "    Expect updated Item's Record not to found. It was not found.")
    assert_not_equals_nil(Item.find_by(identifier: @hardware_item.identifier),
                          'Item Record',
                          '    Expect Orginal Record to be found. it was found.')
    ChangeSession.redo(data_change.session_id)
    assert_not_equals_nil(Item.find_by(identifier: @hardware_item.identifier + '_001'),
                          'Item Record',
                          "    Expect updated Item's Record to be found. It was found.")
    assert_equals(nil, Item.find_by(identifier: @hardware_item.identifier),
                  'Item Record',
                  '    Expect Orginal Record not to be found. It was not found.')

    STDERR.puts('    An Item was successfully updated, then undone and then redone.')
  end

  test 'should delete Item with undo/redo' do
    STDERR.puts('    Check to see that an Item can be deleted, then undone and then redone.')

    data_change = DataChange.save_or_destroy_with_undo_session(@hardware_item, 'delete')

    assert_not_equals_nil(data_change, 'Item Record', '    Expect that the delete succeded. It did.')
    assert_equals(nil, Item.find_by(identifier: @hardware_item.identifier), 'Item Record', '    Verify that the Item Record was actually deleted. It was.')

    ChangeSession.undo(data_change.session_id)
    assert_not_equals_nil(Item.find_by(identifier: @hardware_item.identifier), 'Item Record', '    Verify that the Item Record was restored after undo. It was.')

    ChangeSession.redo(data_change.session_id)
    assert_equals(nil, Item.find_by(identifier: @hardware_item.identifier), 'Item Record', '    Verify that the Item Record was deleted again after redo. It was.')
    STDERR.puts('    An Item was successfully deleted, then undone and then redone.')
  end

  test 'identifier_from_id' do
    STDERR.puts('    Check to see that an Item returns the Identifier from an ID.')

    Item.identifier_from_id(@hardware_item.id)

    assert_equals(@hardware_item.identifier,
                  Item.identifier_from_id(@hardware_item.id),
                  'Item Record',
                  "    Expect identifier_from_id to return #{@hardware_item.identifier} It did.")
    STDERR.puts('    The Item returned the Identifier from an ID successfully.')
  end

  test 'id_from_identifier' do
    STDERR.puts('    Check to see that an Item returns the ID from an Identifier.')
    Item.id_from_identifier(@hardware_item.identifier)

    assert_equals(@hardware_item.id,
                  Item.id_from_identifier(@hardware_item.identifier),
                  'Item Record',
                  "    Expect id_from_identifier to return #{@hardware_item.id} It did.")
    STDERR.puts('    The Item returned the ID from an Identifier successfully.')
  end

  test 'should duplicate documents' do
    assert_nothing_raised do
      @hardware_item.duplicate_documents
      @software_item.duplicate_documents
    end

    assert_not_equals_nil(Document.find_by(docid: 'PHAC',
                                           item_id: @hardware_item.id),
                          'Document Record',
                          '    Expect PHAC Document to exist. It did.')
    assert_not_equals_nil(Document.find_by(docid: 'PSAC',
                                           item_id: @software_item.id),
                          'Document Record',
                          '    Expect PSAC Document to exist. It did.')
  end

  test 'should duplicate document' do
    STDERR.puts('    Check to see that an Item can be duplcate documents from templates.')

    template_document = TemplateDocument.find_by(title:  'PHAC-A',
                                                 source: Constants::AWC)

    assert_not_equals_nil(@hardware_item.duplicate_document(template_document,
                                                            nil),
                          'Document Record',
                          '    Expect Duplicate Document to Duplicate Document. It did.')
    STDERR.puts('    The Item duplcated documents from templates successfully.')
  end

  test 'to_csv' do
    STDERR.puts('    Check to see that the Item can generate CSV properly.')
    csv        = Item.to_csv(@project.id)
    lines      = csv.split("\n")

    assert_equals('SYS-001,The System SHALL maintain proper pump pressure.,HLR-001,The System SHALL monitor the check value to prevent over-pressure.,LLR-001,The System SHALL keep the pump pressure below 4700 psia.',
                  lines[0],
                  'First Line',
                  '    Expect First Line to be "SYS-001,The System SHALL maintain proper pump pressure.,HLR-001,The System SHALL monitor the check value to prevent over-pressure.,LLR-001,The System SHALL keep the pump pressure below 4700 psia.". It was.')
    STDERR.puts('    The Item generated CSV successfully.')
  end

  test 'to_xls' do
    STDERR.puts('    Check to see that the Item can generate XLS properly.')
    xls = Item.to_xls(@project.id)

    assert_between(4000, 5000, xls.length,
                   'XLS Length',
                   '    Expect XLS Length to be between 4000 and 5000". It was.')
    STDERR.puts('    The Item generated XLS successfully.')
  end

  test 'get_item_title' do
    STDERR.puts('    Check to see that the Item can generate titles properly.')
    assert_equals(I18n.t('misc.requirement'),
                  @hardware_item.get_item_title(:high_level, :singular),
                  'High Level Item - Singular',
                  "    Expect Hardware High Level Item - Singular to be #{I18n.t('misc.requirement')}. It was.")
    assert_equals(I18n.t('requirements.id'),
                  @hardware_item.get_item_title(:high_level, :singular_shortened),
                  'High Level Item - Singular Shortened',
                  "    Expect Hardware High Level Item - Singular Shortened to be #{I18n.t('requirements.id')}. It was.")
    assert_equals(I18n.t('misc.requirements'),
                  @hardware_item.get_item_title(:high_level, :plural),
                  'High Level Item - Plural',
                  "    Expect Hardware High Level Item - Plural to be #{I18n.t('misc.requirements')}. It was.")
    assert_equals(I18n.t('misc.requirement'),
                  @hardware_item.get_item_title(:high_level, :type),
                  'High Level Item - Type',
                  "    Expect Hardware High Level Item - Type to be #{I18n.t('misc.requirement')}. It was.")
    assert_equals(I18n.t('requirements.ids'),
                  @hardware_item.get_item_title(:high_level, :plural_shortened),
                  'High Level Item - Plural Shortened',
                  "    Expect Hardware High Level Item - Plural Shortened to be #{I18n.t('requirements.ids')}. It was.")
    assert_equals(I18n.t('misc.design'),
                  @hardware_item.get_item_title(:low_level, :singular),
                  'Low Level Item - Singular',
                  "    Expect Hardware Low Level Item - Singular to be #{I18n.t('misc.design')}. It was.")
    assert_equals(I18n.t('requirements.design_id'),
                  @hardware_item.get_item_title(:low_level, :singular_shortened),
                  'Low Level Item - Singular Shortened',
                  "    Expect Hardware Low Level Item - Singular Shortened to be #{I18n.t('requirements.design_id')}. It was.")
    assert_equals(I18n.t('misc.design'),
                  @hardware_item.get_item_title(:low_level, :plural),
                  'Low Level Item - Plural',
                  "    Expect Hardware Low Level Item - Plural to be #{I18n.t('misc.design')}. It was.")
    assert_equals(I18n.t('misc.design'),
                  @hardware_item.get_item_title(:low_level, :type),
                  'Low Level Item - Type',
                  "    Expect Hardware Low Level Item - Type to be #{I18n.t('misc.design')}. It was.")
    assert_equals(I18n.t('requirements.design_ids'),
                  @hardware_item.get_item_title(:low_level, :plural_shortened),
                  'Low Level Item - Plural Shortened',
                  "    Expect Hardware Low Level Item - Plural Shortened to be #{I18n.t('requirements.design_ids')}. It was.")
    assert_equals(I18n.t('misc.high_level_requirement'),
                  @software_item.get_item_title(:high_level, :singular),
                  'High Level Item - Singular',
                  "    Expect Software High Level Item - Singular to be #{I18n.t('misc.high_level_requirement')}. It was.")
    assert_equals(I18n.t('requirements.id'),
                  @software_item.get_item_title(:high_level, :singular_shortened),
                  'High Level Item - Singular Shortened',
                  "    Expect Software High Level Item - Singular Shortened to be #{I18n.t('requirements.id')}. It was.")
    assert_equals(I18n.t('misc.high_level_requirements'),
                  @software_item.get_item_title(:high_level, :plural),
                  'High Level Item - Plural',
                  "    Expect Software High Level Item - Plural to be #{I18n.t('misc.high_level_requirements')}. It was.")
    assert_equals(I18n.t('misc.high_level'),
                  @software_item.get_item_title(:high_level, :type),
                  'High Level Item - Type',
                  "    Expect Software High Level Item - Type to be #{I18n.t('misc.high_level')}. It was.")
    assert_equals(I18n.t('misc.high_level_requirements'),
                  @software_item.get_item_title(:high_level, :plural_shortened),
                  'High Level Item - Plural Shortened',
                  "    Expect Software High Level Item - Plural Shortened to be #{I18n.t('misc.high_level_requirements')}. It was.")
    assert_equals(I18n.t('misc.low_level_requirement'),
                  @software_item.get_item_title(:low_level, :singular),
                  'Low Level Item - Singular',
                  "    Expect Software Low Level Item - Singular to be #{I18n.t('misc.low_level_requirement')}. It was.")
    assert_equals(I18n.t('requirements.id'),
                  @software_item.get_item_title(:low_level, :singular_shortened),
                  'Low Level Item - Singular Shortened',
                  "    Expect Software Low Level Item - Singular Shortened to be #{I18n.t('requirements.id')}. It was.")
    assert_equals(I18n.t('misc.low_level_requirements'),
                  @software_item.get_item_title(:low_level, :plural),
                  'Low Level Item - Plural',
                  "    Expect Software Low Level Item - Plural to be #{I18n.t('misc.low_level_requirements')}. It was.")
    assert_equals(I18n.t('misc.low_level'),
                  @software_item.get_item_title(:low_level, :type),
                  'Low Level Item - Type',
                  "    Expect Software Low Level Item - Type to be #{I18n.t('misc.low_level')}. It was.")
    assert_equals(I18n.t('requirements.ids'),
                  @software_item.get_item_title(:low_level, :plural_shortened),
                  'Low Level Item - Plural Shortened',
                  "    Expect Software Low Level Item - Plural Shortened to be #{I18n.t('requirements.ids')}. It was.")
    STDERR.puts('    The Item generated titles successfully.')
  end

  test 'item_type_title' do
    STDERR.puts('    Check to see that the Item can generate item type titles properly.')
    assert_equals(I18n.t('misc.hlr'),
                  Item.item_type_title(nil, :high_level, :singular),
                  'High Level Item - Singular',
                  "    Expect Hardware High Level Item - Singular to be #{I18n.t('misc.hlr')}. It was.")
    assert_equals(I18n.t('misc.hlrs'),
                  Item.item_type_title(nil, :high_level, :plural),
                  'High Level Item - Plural',
                  "    Expect Hardware High Level Item - Plural to be #{I18n.t('misc.hlrs')}. It was.")
    assert_equals(I18n.t('misc.hlr'),
                  Item.item_type_title(nil, :high_level, :type),
                  'High Level Item - Type',
                  "    Expect Hardware High Level Item - Type to be #{I18n.t('misc.hlr')}. It was.")
    assert_equals(I18n.t('misc.llr'),
                  Item.item_type_title(nil, :low_level, :singular),
                  'Low Level Item - Singular',
                  "    Expect Hardware Low Level Item - Singular to be #{I18n.t('misc.llr')}. It was.")
    assert_equals(I18n.t('misc.llrs'),
                  Item.item_type_title(nil, :low_level, :plural),
                  'Low Level Item - Plural',
                  "    Expect Hardware Low Level Item - Plural to be #{I18n.t('misc.llrs')}. It was.")
    assert_equals(I18n.t('misc.llr'),
                  Item.item_type_title(nil, :low_level, :type),
                  'Low Level Item - Type',
                  "    Expect Hardware Low Level Item - Type to be #{I18n.t('misc.llr')}. It was.")
    STDERR.puts('    The Item generated item type titles successfully.')
  end
end
