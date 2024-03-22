require 'test_helper'

class TemplateChecklistItemsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @template                     = Template.find_by(title: 'ACS DO-254 Templates')
    @template_checklist           = TemplateChecklist.find_by(title: 'Plan for Hardware Aspects of Certification')
    @template_checklist_item_001  = TemplateChecklistItem.find_by(clitemid: 1)

    user_pm
  end

  test "should get index" do
    STDERR.puts('    Check to see that the Template Checklist Items List Page can be loaded.')
    get template_template_checklist_template_checklist_items_url(@template,
                                                                 @template_checklist)
    assert_response :success
    STDERR.puts('    The Template Checklist Items List Page loaded successfully.')
  end

  test "should show template_checklist" do
    STDERR.puts('    Check to see that the Template Checklist Item Show Page can be loaded.')
    get template_template_checklist_template_checklist_item_url(@template,
                                                                @template_checklist,
                                                                @template_checklist_item_001)
    assert_response :success
    STDERR.puts('    The Template Checklist Item Show Page loaded successfully.')
  end

  test "should get new" do
    STDERR.puts('    Check to see that the Template Checklist Item New Page can be loaded.')
    get new_template_template_checklist_template_checklist_item_url(@template,
                                                                    @template_checklist)
    STDERR.puts('    The Template Checklist Item New Page loaded successfully.')
    assert_response :success
  end

  test "should get edit" do
    STDERR.puts('    Check to see that the Template Checklist Item Edit Page can be loaded.')
    get edit_template_template_checklist_template_checklist_item_url(@template,
                                                                     @template_checklist,
                                                                     @template_checklist_item_001)
    assert_response :success
    STDERR.puts('    The Template Checklist Item Edit Page loaded successfully.')
  end

  test "should create template_checklist" do
    STDERR.puts('    Check to see that the Template Checklist Item can be created.')

    assert_difference('TemplateChecklistItem.count') do
      post template_template_checklist_template_checklist_items_url(@template,
                                                                    @template_checklist),
        params:
        {
          template_checklist_item:
          {
             clitemid:              @template_checklist_item_001.clitemid + 20,
             title:                 @template_checklist_item_001.title,
             description:           @template_checklist_item_001.description,
             note:                  @template_checklist_item_001.note,
             template_checklist_id: @template_checklist_item_001.template_checklist_id,
             reference:             @template_checklist_item_001.reference,
             minimumdal:            @template_checklist_item_001.minimumdal,
             supplements:           @template_checklist_item_001.supplements,
             organization:          @template_checklist_item_001.organization
          }
        }
    end

    assert_redirected_to template_template_checklist_template_checklist_item_url(@template,
                                                                                 @template_checklist,
                                                                                 TemplateChecklistItem.last)
    STDERR.puts('    A Template Checklist Item was created successfully.')
  end

  test "should update template_checklist" do
    STDERR.puts('    Check to see that the Template Checklist Item can be updated.')

    patch template_template_checklist_template_checklist_item_url(@template,
                                                                  @template_checklist,
                                                                  @template_checklist_item_001),
      params:
      {
        template_checklist_item:
        {
           clitemid:              @template_checklist_item_001.clitemid,
           title:                 @template_checklist_item_001.title,
           description:           @template_checklist_item_001.description,
           note:                  @template_checklist_item_001.note,
           template_checklist_id: @template_checklist_item_001.template_checklist_id,
           reference:             @template_checklist_item_001.reference,
           minimumdal:            @template_checklist_item_001.minimumdal,
           supplements:           @template_checklist_item_001.supplements,
           organization:          @template_checklist_item_001.organization
        }
      }

    assert_redirected_to template_template_checklist_template_checklist_items_url(@template,
                                                                                  @template_checklist)
    STDERR.puts('    A Template Checklist Item was updated successfully.')
  end

  test "should destroy template_checklist" do
    STDERR.puts('    Check to see that the Template Checklist Item can be deleted.')

    assert_difference('TemplateChecklistItem.count', -1) do
      delete template_template_checklist_template_checklist_item_url(@template,
                                                                     @template_checklist,
                                                                     @template_checklist_item_001)
    end

    assert_redirected_to template_template_checklist_template_checklist_items_url(@template,
                                                                                  @template_checklist)
    STDERR.puts('    A Template Checklist Item was deleted successfully.')
  end
end
