require 'test_helper'

class TemplateTest < ActiveSupport::TestCase
  def setup
    @template = Template.find_by(title: 'ACS DO-254 Templates')

    user_pm
  end

  test 'Template record should be valid' do
    STDERR.puts('    Check to see that a Template Record with required fields filled in is valid.')
    assert_equals(true, @template.valid?, 'Template Record',
                  '    Expect Template Record to be valid. It was valid.')
    STDERR.puts('    The Template Record was valid.')
  end

# We implement CRUD Testing by default. The Read Action is implicit in setup.

  test 'should create Template' do
    STDERR.puts('    Check to see that a Template can be created.')

    template = Template.new({
                               tlid:           @template.tlid,
                               title:          @template.title,
                               description:    @template.description,
                               notes:          @template.notes,
                               template_class: @template.template_class,
                               template_type:  @template.template_type,
                               source:         @template.source
                            })

    assert_not_equals_nil(template.save, 'Template Record',
                          '    Expect Template Record to be created. It was.')
    STDERR.puts('    A Template was successfully created.')
  end

  test 'should update Template' do
    STDERR.puts('    Check to see that a Template can be updated.')

    @template.tlid += 2

    assert_not_equals_nil(@template.save, 'Template Record',
                          '    Expect Template Record to be updated. It was.')
    STDERR.puts('    A Template was successfully updated.')
  end

  test 'should delete Template' do
    STDERR.puts('    Check to see that a Template can be deleted.')
    assert( @template.destroy)
    STDERR.puts('    A Template was successfully deleted.')
  end

  test 'should create Template with undo/redo' do
    STDERR.puts('    Check to see that a Template can be created, then undone and then redone.')

    template    = Template.new({
                                 tlid:           @template.tlid,
                                 title:          @template.title,
                                 description:    @template.description,
                                 notes:          @template.notes,
                                 template_class: @template.template_class,
                                 template_type:  @template.template_type,
                                 source:         @template.source
                               })
    data_change = DataChange.save_or_destroy_with_undo_session(template,
                                                               'create')

    assert_not_equals_nil(data_change, 'Template Record',
                          '    Expect Template Record to be created. It was.')

    assert_difference('Template.count', -1) do
      ChangeSession.undo(data_change.session_id)
    end

    assert_difference('Template.count', +1) do
      ChangeSession.redo(data_change.session_id)
    end

    STDERR.puts('    A Template was successfully created, then undone and then redone.')
  end

  test 'should update Template with undo/redo' do
    STDERR.puts('    Check to see that a Template can be updated, then undone and then redone.')

    @template.tlid += 2
    data_change     = DataChange.save_or_destroy_with_undo_session(@template,
                                                                   'update')
    @template.tlid -= 2

    assert_not_equals_nil(data_change, 'Template Record',
                          '    Expect Template Record to be updated. It was')
    assert_not_equals_nil(Template.find_by(tlid: 4),
                          'Template Record',
                          "    Expect Template Record's ID to be 4. It was.")
    assert_equals(nil, Template.find_by(tlid: 2),
                  'Template Record',
                  '    Expect original Template Record not to be found. It was not found.')
    ChangeSession.undo(data_change.session_id)
    assert_equals(nil, Template.find_by(tlid: 4),
                  'Template Record',
                  "    Expect updated Template's Record not to found. It was not found.")
    assert_not_equals_nil(Template.find_by(tlid: 2),
                          'Template Record',
                          '    Expect Orginal Record to be found. it was found.')
    ChangeSession.redo(data_change.session_id)
    assert_not_equals_nil(Template.find_by(tlid: 4),
                          'Template Record',
                          "    Expect updated Template's Record to be found. It was found.")
    assert_equals(nil, Template.find_by(tlid: 2),
                  'Template Record',
                  '    Expect Orginal Record not to be found. It was not found.')

    STDERR.puts('    A Template was successfully updated, then undone and then redone.')
  end

  test 'should delete Template with undo/redo' do
    STDERR.puts('    Check to see that a Template can be deleted, then undone and then redone.')

    data_change = DataChange.save_or_destroy_with_undo_session(@template,
                                                               'delete')

    assert_not_equals_nil(data_change, 'Template Record',
                          '    Expect that the delete succeeded. It did.')
    assert_equals(nil, Template.find_by(tlid: @template.tlid),
                  'Template Record',
                  '    Verify that the Template Record was actually deleted. It was.')
    ChangeSession.undo(data_change.session_id)
    assert_not_equals_nil(Template.find_by(tlid: @template.tlid), 'Template Record', '    Verify that the Template Record was restored after undo. It was.')
    ChangeSession.redo(data_change.session_id)
    assert_equals(nil, Template.find_by(tlid: @template.tlid),
                  'Template Record',
                  '    Verify that the Template Record was deleted again after redo. It was.')
    STDERR.puts('    A Template was successfully deleted, then undone and then redone.')
  end
end
