require 'test_helper'

class ItemsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @project          = Project.find_by(identifier: 'TEST')
    @hardware_item    = Item.find_by(identifier: 'HARDWARE_ITEM')
    @software_item    = Item.find_by(identifier: 'SOFTWARE_ITEM')

    user_pm
  end

  test "should get index" do
    STDERR.puts('    Check to see that the Items List Page can be loaded.')
    get project_items_url(@project)
    assert_response :success
    STDERR.puts('    The Items List Page loaded successfully.')
  end

  test "should show item" do
    STDERR.puts('    Check to see that the Item Show Page can be loaded.')
    get project_item_url(@project, @hardware_item)
    assert_response :success
    STDERR.puts('    The Item Show Page loaded successfully.')
  end

  test "should get new" do
    STDERR.puts('    Check to see that the New Item Page can be loaded.')
    get new_project_item_url(@project)
    assert_response :success
    STDERR.puts('    The New Item Page loaded successfully.')
  end

  test "should get edit" do
    STDERR.puts('    Check to see that the Edit Item Page can be loaded.')
    get edit_project_item_url(@project, @hardware_item)
    assert_response :success
    STDERR.puts('    The Edit Item Page loaded successfully.')
  end

  test "should create item" do
    STDERR.puts('    Check to see that an Item can be created.')
    assert_difference('Item.count') do
      post project_items_url(@project),
        params:
                {
                   item:
                         {
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
                            high_level_requirements_prefix: @hardware_item.high_level_requirements_prefix,
                            low_level_requirements_prefix:  @hardware_item.low_level_requirements_prefix,
                            source_code_prefix:             @hardware_item.source_code_prefix,
                            test_case_prefix:               @hardware_item.test_case_prefix,
                            test_procedure_prefix:          @hardware_item.test_procedure_prefix,
                            tp_count:                       @hardware_item.tp_count,
                            model_file_prefix:              @hardware_item.model_file_prefix
                         }
                }
    end

    assert_redirected_to project_item_url(@project, Item.last)
    STDERR.puts('    An Item was successfully created.')
  end

  test "should update item" do
    STDERR.puts('    Check to see that an Item can be updated.')

    patch project_item_url(@project, @hardware_item),
      params:
              {
                 item:
                       {
                          name:                           @hardware_item.name       + '_001',
                          itemtype:                       @hardware_item.itemtype,
                          identifier:                     @hardware_item.identifier + '_001',
                          level:                          @hardware_item.level,
                          project_id:                     @hardware_item.project_id,
                          hlr_count:                      @hardware_item.hlr_count + 3,
                          llr_count:                      @hardware_item.llr_count + 3,
                          review_count:                   @hardware_item.review_count + 1,
                          tc_count:                       @hardware_item.tc_count + 3,
                          sc_count:                       @hardware_item.sc_count + 3,
                          high_level_requirements_prefix: @hardware_item.high_level_requirements_prefix,
                          low_level_requirements_prefix:  @hardware_item.low_level_requirements_prefix,
                          source_code_prefix:             @hardware_item.source_code_prefix,
                          test_case_prefix:               @hardware_item.test_case_prefix,
                          test_procedure_prefix:          @hardware_item.test_procedure_prefix,
                          model_file_prefix:              @hardware_item.model_file_prefix
                       }
              }

    assert_redirected_to project_item_url(@project, @hardware_item)
    STDERR.puts('    An Item was successfully updated.')
  end

  test "should destroy item" do
    STDERR.puts('    Check to see that an Item can be deleted.')

    assert_difference('Item.count', -1) do
      delete project_item_url(@project, @hardware_item)
    end

    assert_redirected_to project_items_url(@project)
    STDERR.puts('    The Item was successfully deleted.')
  end

  test "get_checklists" do
    STDERR.puts('    Check to see that checklists can be retrieved.')

    url = item_reviews_url(@hardware_item).sub('reviews', 'template_checklists') +
          '/peer.json'

    get url
    assert_response :success

    result     = JSON.parse(response.body)
    checklists = JSON.parse(result["template_checklists"])

    assert_equals('Plan for Hardware Aspects of Certification', checklists[0]['title'],
                  'Checklist Title',
                  '    Expect first checklist title to be "Plan for Hardware Aspects of Certification. It was.')
    STDERR.puts('    Checklists were successfully retrieved.')
  end
end
