require 'test_helper'

class ChangeSessionTest < ActiveSupport::TestCase
  def setup
    @session_id      = nil
    @data_changes    = []
    @change_sessions = []
    @project         = Project.find_by(identifier: 'TEST')

    assert @project.present?
  end

  test "Add New ChangeSession" do
    STDERR.puts('    Check to see that a Change Session can be created.')

    @project        = Project.first

    assert @project.present?

    @data_change    = DataChange.record_change('projects', 'create', @project.id, @project)

    @data_change.save!();

    @change_session = ChangeSession.start_new_change_session(@data_change.id)

    assert @change_session.present?
    assert @change_session.session_id.present?
    assert @change_session.valid?

    @change_session.destroy
    @data_change.destroy
    STDERR.puts('    A Change Session was successfully created.')
  end

  test "Add Additional ChangeSessions" do
    STDERR.puts('    Check to see that Change Sessions can be added.')

    @data_changes          = []
    @change_sessions       = []
    @project               = Project.first

    assert @project.present?

    @data_changes[0]       = DataChange.record_change('projects', 'create', @project.id, @project)

    assert @data_changes[0].present?
    @data_changes[0].save!();

    @data_changes[1]       = DataChange.record_change('projects', 'update', @project.id, @project)

    assert @data_changes[1].present?
    @data_changes[1].save!();

    @data_changes[2]       = DataChange.record_change('projects', 'delete', @project.id, @project)

    assert @data_changes[2].present?
    @data_changes[2].save!();

    @change_sessions[0]    = ChangeSession.start_new_change_session( @data_changes[0].id)

    assert@change_sessions[0].present?
    assert @change_sessions[0].session_id.present?
    assert @change_sessions[0].valid?

    @session_id           = @change_sessions[0].session_id

    for i in 1..2 do
      @change_sessions[i] = ChangeSession.add_change_session(@session_id,
                                                             @data_changes[i].id)
    end

    @changes_sessions     = ChangeSession.where(session_id: @session_id) 

    assert (@change_sessions.length == 3)

    for i in 0..2 do
      @change_sessions[i].destroy
      @data_changes[i].destroy
    end

    STDERR.puts('    Change Sessions were successfully added.')
  end
end
