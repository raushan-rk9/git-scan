require 'test_helper'

class TemplateDocumentsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @template          = Template.find_by(title: 'ACS DO-254 Templates')
    @template_document = TemplateDocument.find_by(title: 'PHAC-A')

    user_pm
  end

  test "should get index" do
    STDERR.puts('    Check to see that the Template Documents List Page can be loaded.')
    get template_template_documents_url(@template)
    assert_response :success
    STDERR.puts('    The Template Documents List Page loaded successfully.')
  end

  test "should show template_document" do
    STDERR.puts('    Check to see that the Template Document Show Page can be loaded.')
    get template_template_document_url(@template, @template_document)
    assert_response :success
    STDERR.puts('    The Template Document Show Page loaded successfully.')
  end

  test "should get new" do
    STDERR.puts('    Check to see that the Template Document New Page can be loaded.')
    get new_template_template_document_url(@template)
    STDERR.puts('    The Template Document New Page loaded successfully.')
    assert_response :success
  end

  test "should get edit" do
    STDERR.puts('    Check to see that the Template Document Edit Page can be loaded.')
    get edit_template_template_document_url(@template, @template_document)
    assert_response :success
    STDERR.puts('    The Template Document Edit Page loaded successfully.')
  end

  test "should create template_document" do
    STDERR.puts('    Check to see that the Template Document can be created.')

    assert_difference('TemplateDocument.count') do
      post template_template_documents_url(@template),
        params:
        {
          template_document:
          {
             document_id:      @template_document.document_id + 1,
             title:            @template_document.title,
             description:      @template_document.description,
             notes:            @template_document.notes,
             document_class:   @template_document.document_class,
             document_type:    @template_document.document_type,
             template_id:      @template_document.template_id,
             organization:     @template_document.organization,
             docid:            @template_document.docid.sub('_C', '_A'),
             name:             @template_document.name,
             category:         @template_document.category,
             file_type:        @template_document.file_type,
             dal:              'A',
             version:          @template_document.version,
             source:           @template_document.source,
             draft_revision:   @template_document.draft_revision,
             upload_date:      @template_document.upload_date 
          }
        }
    end

    assert_redirected_to template_template_documents_url(@template)
    STDERR.puts('    A Template Document was created successfully.')
  end

  test "should update template_document" do
    STDERR.puts('    Check to see that the Template Document can be updated.')

    patch template_template_document_url(@template, @template_document),
      params:
      {
        template_document:
        {
           document_id:      @template_document.document_id + 1,
           title:            @template_document.title,
           description:      @template_document.description,
           notes:            @template_document.notes,
           document_class:   @template_document.document_class,
           document_type:    @template_document.document_type,
           template_id:      @template_document.template_id,
           organization:     @template_document.organization,
           docid:            @template_document.docid.sub('_C', '_A'),
           name:             @template_document.name,
           category:         @template_document.category,
           file_type:        @template_document.file_type,
           dal:              'A',
           version:          @template_document.version,
           source:           @template_document.source,
           draft_revision:   @template_document.draft_revision,
           upload_date:      @template_document.upload_date 
        }
      }

    assert_redirected_to template_template_documents_url(@template)
    STDERR.puts('    A Template Document was updated successfully.')
  end

  test "should destroy template_document" do
    STDERR.puts('    Check to see that the Template Document can be deleted.')

    assert_difference('TemplateDocument.count', -1) do
      delete template_template_document_url(@template, @template_document)
    end

    assert_redirected_to template_template_documents_url(@template)
    STDERR.puts('    A Template Document was deleted successfully.')
  end
end
