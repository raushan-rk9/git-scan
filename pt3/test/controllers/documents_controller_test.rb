require 'test_helper'

class DocumentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @document = Document.find_by(docid: 'PHAC')
    @flowchart = Document.find_by(docid: 'flowchart')
    @item     = Item.find(@document.item_id)

    user_pm
  end

  test "should get index" do
    STDERR.puts('    Check to see that the Document List Page can be loaded.')
    get item_documents_url(@item)

    assert_response :success
    STDERR.puts('    The Document List Page loaded successfully.')
  end

  test "should get new" do
    STDERR.puts('    Check to see that a New Document Page can be loaded.')
    get new_item_document_url(@item)

    assert_response :success
    STDERR.puts('    The New Document Page loaded successfully.')
  end

  test "should create document" do
    STDERR.puts('    Check to see that a Document can be created.')
    assert_difference('Document.count') do
      post item_documents_url(@item),
        params:
        {
          document:
          {
            docid:            @document.docid + '_001',
            name:             @document.name,
            category:         @document.category,
            version:          @document.version,
            item_id:          @document.item_id,
            project_id:       @document.project_id,
            draft_revision:   @document.draft_revision,
            doccomment_count: @document.doccomment_count,
            document_type:    @document.document_type,
            file_path:        @document.file_path,
            file_type:        @document.file_type,
            upload_date:      @document.upload_date,
            file:             fixture_file_upload('files/PHAC.doc')
          }
        }
    end

    assert_redirected_to item_document_url(@item, Document.last)

    STDERR.puts('    The Document was created successfully.')
  end

  test "should show document" do
    STDERR.puts('    Check to see that a Document viewed.')
    get item_document_url(@item, @document)

    assert_response :success
    STDERR.puts('    The New Document View loaded successfully.')
  end

  test "should get edit" do
    STDERR.puts('    Check to see that a Edit Document Page can be loaded.')
    get edit_item_document_url(@item, @document)

    assert_response :success
    STDERR.puts('    The Edit Document page loaded successfully.')
  end

  test "should update document" do
    STDERR.puts('    Check to see that a Document can be updated.')

    patch item_document_url(@item, @document),
      params: {
        document:
        {
          docid:            @document.docid + '_001',
          name:             @document.name,
          category:         @document.category,
          version:          @document.version,
          item_id:          @document.item_id,
          project_id:       @document.project_id,
          draft_revision:   @document.draft_revision,
          doccomment_count: @document.doccomment_count,
          document_type:    @document.document_type,
          file_path:        @document.file_path,
          file_type:        @document.file_type,
          upload_date:      @document.upload_date
        }
      }

    assert_redirected_to item_document_url(@item, @document)
    STDERR.puts('    The Document was successfully updated.')
  end

  test "should destroy document" do
    STDERR.puts('    Check to see that a Document can be deleted.')

    assert_difference('Document.count', -1) do
      delete item_document_url(@item, @document)
    end

    assert_redirected_to item_documents_url(@item)

    STDERR.puts('    A Document was successfully deleted.')
  end

  test "should upload document" do
    STDERR.puts('    Check to see that a Document can be uploded.')

    patch item_document_url(@item, @document),
      params: {
        document:
        {
          docid:            @document.docid + '_002',
          name:             @document.name,
          category:         @document.category,
          version:          @document.version,
          item_id:          @document.item_id,
          project_id:       @document.project_id,
          draft_revision:   @document.draft_revision,
          doccomment_count: @document.doccomment_count,
          document_type:    @document.document_type,
          file_path:        @document.file_path,
          file_type:        @document.file_type,
          upload_date:      @document.upload_date
        }
      }

    assert_redirected_to item_document_url(@item, @document)
    STDERR.puts('    The Document was successfully uploaded.')
  end

  test "should download document" do
    STDERR.puts('    Check to see that a Document can be downloded.')

    get item_document_download_document_url(@item, @document)
    assert_equals(6059520, response.body.length, 'Download Length', "    Expect download length to be 6059520.")

    STDERR.puts('    The Document was successfully downloaded.')
  end

  test "should get document history" do
    STDERR.puts('    Check to see that a document history can be retrieved.')

    get item_document_document_history_url(@item, @document)

    assert_response :success

    STDERR.puts('    The document history was successfully retrieved.')
  end

  test "should select documents" do
    STDERR.puts('    Check to see that documents can be selected.')

    get item_documents_select_documents_url(@item)

    assert_response :success

    STDERR.puts('    The documents were successfully selected.')
  end

  test "should package documents" do
    STDERR.puts('    Check to see that documents can be packaged.')

    put item_documents_package_documents_url(@item,
      params: {
        selected_documents:
        {
          selections: @document.id,
          filename:   'test.zip'
        }
      })

    assert_equals(3061148, response.body.length, 'Zip Download Length', "    Expect download length to be 3061148")

    STDERR.puts('    The documents were successfully packaged.')
  end

  test "should display file" do
    STDERR.puts('    Check to see that a file can be displayed.')

    get item_document_display_url(@item, @flowchart)

    assert_response :success

    STDERR.puts('    The file was successfully displayed.')
  end

  test "get PACT Documents" do
    STDERR.puts('    Check to see that we can get a list of PACT documents.')

    get item_documents_get_pact_documents_url(@item, :format => :json)

    assert_response :success

    result = JSON.parse(response.body)

    assert_equals(2, result.length, '    PACT Documents Length', "    Expect PACT documents length to be 4.")
    
    STDERR.puts('    The PACT documents were successfully retrieved..')
  end



end
