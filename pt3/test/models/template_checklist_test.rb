require 'test_helper'

class TemplateChecklistTest < ActiveSupport::TestCase
  def setup
    @template           = Template.find_by(title: 'ACS DO-254 Templates')
    @template_checklist = TemplateChecklist.find_by(title: 'Plan for Hardware Aspects of Certification')

    user_pm
  end

  test 'Template Checklist record should be valid' do
    STDERR.puts('    Check to see that a Template Checklist Record with required fields filled in is valid.')
    assert_equals(true, @template_checklist.valid?, 'Template Checklist Record',
                  '    Expect Template Checklist Recordto be valid. It was valid.')
    STDERR.puts('    The Template Checklist Record was valid.')
  end

  test 'Template Checklist record needs template_id to be valid' do
    STDERR.puts('    Check to see that a Template Checklist with a template checklist id is invalid.')
    @template_checklist.template_id = nil

    assert_equals(false, @template_checklist.valid?, 'Template Checklist Record',
                  '    Expect Template Checklist Recordwithout template_checklist_id to be invalid. It was valid.')
    STDERR.puts('    The Template Checklist Record was invalid.')
  end

# We implement CRUD Testing by default. The Read Action is implicit in setup.

  test 'should create Template Checklist' do
    STDERR.puts('    Check to see that a Template Checklist can be created.')
    template_checklist = TemplateChecklist.new({
                                                  clid:            @template_checklist.clid,
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
                                                })

    assert_not_equals_nil(template_checklist.save, 'Template Checklist Record',
                          '    Expect Template Checklist Record to be created. It was.')
    STDERR.puts('    A Template Checklist was successfully created.')
  end

  test 'should update Template Checklist' do
    STDERR.puts('    Check to see that a Template Checklist can be updated.')

    @template_checklist.clid += 1

    assert_not_equals_nil(@template_checklist.save, 'Template Checklist Record',
                          '    Expect Template Checklist Record to be updated. It was.')
    STDERR.puts('    A Template Checklist was successfully updated.')
  end

  test 'should delete Template Checklist' do
    STDERR.puts('    Check to see that a Template Checklist can be deleted.')
    assert( @template_checklist.destroy)
    STDERR.puts('    A Template Checklist was successfully deleted.')
  end

  test 'should create Template Checklist with undo/redo' do
    STDERR.puts('    Check to see that a Template Checklist can be created, then undone and then redone.')

    template_checklist = TemplateChecklist.new({
                                                  clid:            @template_checklist.clid,
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
                                                })
    data_change      = DataChange.save_or_destroy_with_undo_session(template_checklist,
                                                                    'create')

    assert_not_equals_nil(data_change, 'Template Checklist Record',
                          '    Expect Template Checklist Record to be created. It was.')

    assert_difference('TemplateChecklist.count', -1) do
      ChangeSession.undo(data_change.session_id)
    end

    assert_difference('TemplateChecklist.count', +1) do
      ChangeSession.redo(data_change.session_id)
    end

    STDERR.puts('    A Template Checklist was successfully created, then undone and then redone.')
  end

  test 'should update Template Checklist with undo/redo' do
    STDERR.puts('    Check to see that a Template Checklist can be updated, then undone and then redone.')

    @template_checklist.clid += 1
    data_change                   = DataChange.save_or_destroy_with_undo_session(@template_checklist, 'update')
    @template_checklist.clid -= 1

    assert_not_equals_nil(data_change, 'Template Checklist Record',
                          '    Expect Template Checklist Record to be updated. It was')
    assert_not_equals_nil(TemplateChecklist.find_by(clid: 2),
                          'Template Checklist Record',
                          "    Expect Template Checklist Record's ID to be 2. It was.")
    assert_equals(nil, TemplateChecklist.find_by(clid: 1),
                  'Template Checklist Record',
                  '    Expect original Template Checklist Record not to be found. It was not found.')
    ChangeSession.undo(data_change.session_id)
    assert_equals(nil, TemplateChecklist.find_by(clid: 2),
                  'Template Checklist Record',
                  "    Expect updated Template Checklist's Record not to found. It was not found.")
    assert_not_equals_nil(TemplateChecklist.find_by(clid: 1),
                          'Template Checklist Record',
                          '    Expect Orginal Record to be found. it was found.')
    ChangeSession.redo(data_change.session_id)
    assert_not_equals_nil(TemplateChecklist.find_by(clid: 2),
                          'Template Checklist Record',
                          "    Expect updated Template Checklist's Record to be found. It was found.")
    assert_equals(nil, TemplateChecklist.find_by(clid: 1),
                  'Template Checklist Record',
                  '    Expect Orginal Record not to be found. It was not found.')

    STDERR.puts('    A Template Checklist was successfully updated, then undone and then redone.')
  end

  test 'should delete Template Checklist with undo/redo' do
    STDERR.puts('    Check to see that a Template Checklist can be deleted, then undone and then redone.')

    data_change = DataChange.save_or_destroy_with_undo_session(@template_checklist,
                                                               'delete')

    assert_not_equals_nil(data_change, 'Template Checklist Record',
                          '    Expect that the delete succeded. It did.')
    assert_equals(nil, TemplateChecklist.find_by(clid: @template_checklist.clid),
                  'Template Checklist Record',
                  '    Verify that the Template Checklist Record was actually deleted. It was.')
    ChangeSession.undo(data_change.session_id)
    assert_not_equals_nil(TemplateChecklist.find_by(clid: @template_checklist.clid), 'Template Checklist Record', '    Verify that the Template Checklist Record was restored after undo. It was.')
    ChangeSession.redo(data_change.session_id)
    assert_equals(nil, TemplateChecklist.find_by(clid: @template_checklist.clid),
                  'Template Checklist Record',
                  '    Verify that the Template Checklist Record was deleted again after redo. It was.')

    STDERR.puts('    A Template Checklist was successfully deleted, then undone and then redone.')
  end
end
