require 'test_helper'

class TemplateChecklistsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @template           = Template.find_by(title: 'ACS DO-254 Templates')
    @template_checklist = TemplateChecklist.find_by(title: 'Plan for Hardware Aspects of Certification')

    user_pm
  end

  test "should get index" do
    STDERR.puts('    Check to see that the Template Checklists List Page can be loaded.')
    get template_template_checklists_url(@template)
    assert_response :success
    STDERR.puts('    The Template Checklists List Page loaded successfully.')
  end

  test "should show template_checklist" do
    STDERR.puts('    Check to see that the Template Checklist Show Page can be loaded.')
    get template_template_checklist_url(@template, @template_checklist)
    assert_response :success
    STDERR.puts('    The Template Checklist Show Page loaded successfully.')
  end

  test "should get new" do
    STDERR.puts('    Check to see that the Template Checklist New Page can be loaded.')
    get new_template_template_checklist_url(@template)
    STDERR.puts('    The Template Checklist New Page loaded successfully.')
    assert_response :success
  end

  test "should get edit" do
    STDERR.puts('    Check to see that the Template Checklist Edit Page can be loaded.')
    get edit_template_template_checklist_url(@template, @template_checklist)
    assert_response :success
    STDERR.puts('    The Template Checklist Edit Page loaded successfully.')
  end

  test "should create template_checklist" do
    STDERR.puts('    Check to see that the Template Checklist can be created.')

    assert_difference('TemplateChecklist.count') do
      post template_template_checklists_url(@template),
        params:
        {
          template_checklist:
          {
            clid:            @template_checklist.clid + 1,
            title:           @template_checklist.title,
            description:     @template_checklist.description,
            notes:           @template_checklist.notes,
            checklist_class: @template_checklist.checklist_class,
            checklist_type:  @template_checklist.checklist_type,
            template_id:     @template_checklist.template_id,
            version:         @template_checklist.version,
            source:          @template_checklist.source,
            filename:        @template_checklist.filename,
            draft_revision:  @template_checklist.draft_revision,
          }
        }
    end

    assert_redirected_to template_template_checklists_url(@template)
    STDERR.puts('    A Template Checklist was created successfully.')
  end

  test "should update template_checklist" do
    STDERR.puts('    Check to see that the Template Checklist can be updated.')

    patch template_template_checklist_url(@template, @template_checklist),
      params:
      {
        template_checklist:
        {
           clid:            @template_checklist.clid + 1,
           title:           @template_checklist.title,
           description:     @template_checklist.description,
           notes:           @template_checklist.notes,
           checklist_class: @template_checklist.checklist_class,
           checklist_type:  @template_checklist.checklist_type,
           template_id:     @template_checklist.template_id,
           version:         @template_checklist.version,
           source:          @template_checklist.source,
           filename:        @template_checklist.filename,
           draft_revision:  @template_checklist.draft_revision,
        }
      }

    assert_redirected_to template_template_checklists_url(@template)
    STDERR.puts('    A Template Checklist was updated successfully.')
  end

  test "should destroy template_checklist" do
    STDERR.puts('    Check to see that the Template Checklist can be deleted.')

    assert_difference('TemplateChecklist.count', -1) do
      delete template_template_checklist_url(@template, @template_checklist)
    end

    assert_redirected_to template_template_checklists_url(@template)
    STDERR.puts('    A Template Checklist was deleted successfully.')
  end
end
