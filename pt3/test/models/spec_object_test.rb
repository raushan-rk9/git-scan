require 'test_helper'

class SpecObjectTest < ActiveSupport::TestCase
  setup do
    @project = Project.find_by(identifier: 'TEST')

    user_pm
  end

  test "Get Spec Ojects from files" do
    STDERR.puts('    Check to see that a Spec Ojects can retrieved from a file.')

    document_path = 'test/fixtures/files/example.reqif.xml'
    requirements  = SpecObject.get_requirements(document_path, @project.id)

    assert_equals(3, requirements.length, 'Spec Objects',
                  "    ExpectSpec Objects to be present. They were.")

    document_path = 'test/fixtures/files/chapter3.reqif.xml'
    requirements  = SpecObject.get_requirements(document_path, @project.id)

    assert_equals(3767, requirements.length, 'Spec Objects',
                  "    ExpectSpec Objects to be present. They were.")

    document_path = 'test/fixtures/files/_GA_FORCE2C_MASTER.reqif'
    requirements  = SpecObject.get_requirements(document_path, @project.id)

    assert_equals(864, requirements.length, 'Spec Objects',
                  "    ExpectSpec Objects to be present. They were.")

    STDERR.puts('    Spec Ojects were successfully retrieved.')
  end
end
