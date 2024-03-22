require 'test_helper'

class LicenseeTest < ActiveSupport::TestCase
  def setup
    @licensee = Licensee.find_by(identifier: 'test')

    user_admin
  end

  test 'Licensee record should be valid' do
    STDERR.puts('    Check to see that a Licensee Record with required fields filled in is valid.')
    assert_equals(true, @licensee.valid?, 'Licensee Record',
                  '    Expect Licensee Record to be valid. It was valid.')
    STDERR.puts('    The Licensee Record was valid.')
  end

  test 'Licensee record without identifier should be invalid' do
    STDERR.puts('    Check to see that a Licensee Record without an Identifier is invalid.')

    @licensee.identifier = nil

    assert_equals(false, @licensee.valid?, 'Licensee Record',
                  '    Expect Licensee Record without identifier to be invalid. It was invalid.')
    STDERR.puts('    The Licensee Record was invalid.')
  end

  test 'Licensee record without name should be invalid' do
    STDERR.puts('    Check to see that a Licensee Record without a Name is invalid.')

    @licensee.name = nil

    assert_equals(false, @licensee.valid?, 'Licensee Record',
                  '    Expect Licensee Record without name to be invalid. It was invalid.')
    STDERR.puts('    The Licensee Record was invalid.')
  end

  test 'Licensee record without setup date should be invalid' do
    STDERR.puts('    Check to see that a Licensee Record without a Setup Date is invalid.')

    @licensee.setup_date = nil

    assert_equals(false, @licensee.valid?, 'Licensee Record',
                  '    Expect Licensee Record without setup date to be invalid. It was invalid.')
    STDERR.puts('    The Licensee Record was invalid.')
  end

  test 'Licensee record without license date should be invalid' do
    STDERR.puts('    Check to see that a Licensee Record without a License Date is invalid.')

    @licensee.license_date = nil

    assert_equals(false, @licensee.valid?, 'Licensee Record',
                  '    Expect Licensee Record without license date to be invalid. It was invalid.')
    STDERR.puts('    The Licensee Record was invalid.')
  end

  test 'Licensee record without renewal date should be invalid' do
    STDERR.puts('    Check to see that a Licensee Record without a Renewal Date is invalid.')
    @licensee.renewal_date = nil

    assert_equals(false, @licensee.valid?, 'Licensee Record',
                  '    Expect Licensee Record without renewal date to be invalid. It was invalid.')
    STDERR.puts('    The Licensee Record was invalid.')
  end

  test 'Licensee record without administrator should be invalid' do
    STDERR.puts('    Check to see that a Licensee Record without a Administrator Date is invalid.')
    @licensee.administrator = nil

    assert_equals(false, @licensee.valid?, 'Licensee Record',
                  '    Expect Licensee Record without administrator to be invalid. It was invalid.')
    STDERR.puts('    The Licensee Record was invalid.')
  end

  test 'Licensee record without contact emails should be invalid' do
    STDERR.puts('    Check to see that a Licensee Record without Contact Emails is invalid.')
    @licensee.contact_emails = nil

    assert_equals(false, @licensee.valid?, 'Licensee Record',
                  '    Expect Licensee Record without contact emails to be invalid. It was invalid.')
    STDERR.puts('    The Licensee Record was invalid.')
  end

# We implement CRUD Testing by default. The Read Action is implicit in setup.

  test 'should create Licensee' do
    STDERR.puts('    Check to see that a Licensee can be created.')

    licensee = Licensee.new({
                               identifier:     @licensee.identifier,
                               name:           @licensee.name,
                               setup_date:     @licensee.setup_date,
                               license_date:   @licensee.license_date,
                               renewal_date:   @licensee.renewal_date,
                               administrator:  @licensee.administrator,
                               contact_emails: @licensee.contact_emails,
                            })

    assert_not_equals_nil(licensee.save,
                          'Licensee Record',
                          '    Expect Licensee Record to be created. It was.')
    STDERR.puts('    A Licensee was successfully created.')
  end

  test 'should update Licensee' do
    STDERR.puts('    Check to see that a Licensee can be updated.')

    @licensee.identifier += '2'

    assert_not_equals_nil(@licensee.save, 'Licensee Record',
                          '    Expect Licensee Record to be updated. It was.')
    STDERR.puts('    A Licensee was successfully updated.')
  end

  test 'should delete Licensee' do
    STDERR.puts('    Check to see that a Licensee can be deleted.')
    assert( @licensee.destroy)
    STDERR.puts('    A Licensee was successfully deleted.')
  end

  test 'should create Licensee with undo/redo' do
    STDERR.puts('    Check to see that a Licensee can be created, then undone and then redone.')

    licensee    = Licensee.new({
                                  identifier:     @licensee.identifier + '2',
                                  name:           @licensee.name,
                                  setup_date:     @licensee.setup_date,
                                  license_date:   @licensee.license_date,
                                  renewal_date:   @licensee.renewal_date,
                                  administrator:  @licensee.administrator,
                                  contact_emails: @licensee.contact_emails,
                               })
    data_change = DataChange.save_or_destroy_with_undo_session(licensee, 'create')

    assert_not_equals_nil(data_change, 'Licensee Record',
                          '    Expect Licensee Record to be created. It was.')

    assert_difference('Licensee.count', -1) do
      ChangeSession.undo(data_change.session_id)
    end

    assert_difference('Licensee.count', +1) do
      ChangeSession.redo(data_change.session_id)
    end

    STDERR.puts('    A Licensee was successfully created, then undone and then redone.')
  end

  test 'should update Licensee with undo/redo' do
    STDERR.puts('    Check to see that a Licensee can be updated, then undone and then redone.')

    @licensee.identifier = 'test2'
    data_change          = DataChange.save_or_destroy_with_undo_session(@licensee,
                                                                        'update')
    @licensee.identifier = 'test'

    assert_not_equals_nil(data_change, 'Licensee Record',
                          '    Expect Licensee Record to be updated. It was')
    assert_not_equals_nil(Licensee.find_by(identifier: 'test2'),
                          'Licensee Record',
                          "    Expect Licensee Record's ID to be #{ 'test' }. It was.")
    assert_equals(nil,
                  Licensee.find_by(identifier: 'test'),
                  'Licensee Record',
                  '    Expect original Licensee Record not to be found. It was not found.')
    ChangeSession.undo(data_change.session_id)
    assert_equals(nil,
                  Licensee.find_by(identifier: 'test2'),
                  'Licensee Record',
                  "    Expect updated Licensee's Record not to found. It was not found.")
    assert_not_equals_nil(Licensee.find_by(identifier: 'test'),
                          'Licensee Record',
                          '    Expect Orginal Record to be found. it was found.')
    ChangeSession.redo(data_change.session_id)
    assert_not_equals_nil(Licensee.find_by(identifier: 'test2'),
                          'Licensee Record',
                          "    Expect updated Licensee's Record to be found. It was found.")
    assert_equals(nil,
                  Licensee.find_by(identifier: 'test'),
                  'Licensee Record',
                  '    Expect Orginal Record not to be found. It was not found.')
    STDERR.puts('    A Licensee was successfully deleted, then undone and then redone.')
  end

  test 'should delete Licensee with undo/redo' do
    STDERR.puts('    Check to see that a Licensee can be deleted, then undone and then redone.')

    data_change = DataChange.save_or_destroy_with_undo_session(@licensee, 'delete')

    assert_not_equals_nil(data_change, 'Licensee Record', '    Expect that the delete succeded. It did.')
    assert_equals(nil, Licensee.find_by(identifier: @licensee.identifier),
                  'Licensee Record',
                  '    Verify that the Licensee Record was actually deleted. It was.')

    ChangeSession.undo(data_change.session_id)
    assert_not_equals_nil(Licensee.find_by(identifier: @licensee.identifier), 'Licensee Record', '    Verify that the Licensee Record was restored after undo. It was.')

    ChangeSession.redo(data_change.session_id)
    assert_equals(nil, Licensee.find_by(identifier: @licensee.identifier),
                  'Licensee Record',
                  '    Verify that the Licensee Record was deleted again after redo. It was.')
    STDERR.puts('    A Licensee was successfully deleted, then undone and then redone.')
  end
end
