require 'test_helper'

class TemplatesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @template = Template.find_by(title: 'ACS DO-254 Templates')

    user_pm
  end

  test "should get index" do
    STDERR.puts('    Check to see that the Templates List Page can be loaded.')
    get templates_url
    assert_response :success
    STDERR.puts('    The Templates List Page loaded successfully.')
  end

  test "should show template" do
    STDERR.puts('    Check to see that the Template Show Page can be loaded.')
    get template_url(@template)
    assert_response :success
    STDERR.puts('    The Template Show Page loaded successfully.')
  end

  test "should get new" do
    STDERR.puts('    Check to see that the Template New Page can be loaded.')
    get new_template_url
    STDERR.puts('    The Template New Page loaded successfully.')
    assert_response :success
  end

  test "should get edit" do
    STDERR.puts('    Check to see that the Template Edit Page can be loaded.')
    get edit_template_url(@template)
    assert_response :success
    STDERR.puts('    The Template Edit Page loaded successfully.')
  end

  test "should create template" do
    STDERR.puts('    Check to see that the Template can be created.')

    assert_difference('Template.count') do
      post templates_url,
        params:
        {
          template:
          {
             tlid:           @template.tlid + 2,
             title:          @template.title,
             description:    @template.description,
             notes:          @template.notes,
             template_class: @template.template_class,
             template_type:  @template.template_type,
             source:         @template.source
          }
        }
    end

    assert_redirected_to templates_url
    STDERR.puts('    A Template was created successfully.')
  end

  test "should update template" do
    STDERR.puts('    Check to see that the Template can be updated.')

    patch template_url(@template),
      params:
      {
        template:
        {
           tlid:           @template.tlid + 2,
           title:          @template.title,
           description:    @template.description,
           notes:          @template.notes,
           template_class: @template.template_class,
           template_type:  @template.template_type,
           source:         @template.source
        }
      }

    assert_redirected_to templates_url
    STDERR.puts('    A Template was updated successfully.')
  end

  test "should destroy template" do
    STDERR.puts('    Check to see that the Template can be deleted.')

    assert_difference('Template.count', -1) do
      delete template_url(@template)
    end

    assert_redirected_to templates_url
    STDERR.puts('    A Template was deleted successfully.')
  end
end
