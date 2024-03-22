require 'test_helper'

class ReqIfTest < ActiveSupport::TestCase
  setup do
    @project       = Project.find_by(identifier: 'TEST')
    @hardware_item = Item.find_by(identifier: 'HARDWARE_ITEM')
    @software_item = Item.find_by(identifier: 'SOFTWARE_ITEM')

    user_pm
  end

  test "parse ReqIF" do
    STDERR.puts('    Check to see that a ReqIF files can be parsed.')

    @reqif_file = 'test/fixtures/files/example.reqif.xml'

    STDERR.puts("    Check to see that #{@reqif_file} can be parsed.")

    @reqif      = ReqIf.new(@reqif_file)

    assert_equals(3, @reqif.header.children.length, 'Header Length',
                  "    Expect Header Length to be 1. It was.")
    assert_equals(15, @reqif.reqif_header.children.length, 'ReqIf Header Children Length',
                  "    Expect ReqIf Header Children Length to be 7. It was.")
    assert_equals(7, @reqif.data_types.children.length, 'Data Types Children Length',
                  "    Expect Data Types Children Length to be 3. It was.")
    assert_equals(27, @reqif.spec_types.children.length, 'Spec Types Children Length',
                  "    Expect Spec Types Children Length to be 13. It was.")
    assert_equals(7, @reqif.spec_objects.children.length, 'Spec Objects Children Length',
                  "    Expect Spec Objects Children Length to be 3. It was.")
    assert_equals(3, @reqif.spec_relations.children.length, 'Spec Relations Children Length',
                  "    Expect Spec Relations Children Length to be 1. It was.")
    assert_equals(3, @reqif.specifications.children.length, 'Specifications Children Length',
                  "    Expect Specifications Children Length to be 1. It was.")
    assert_equals(1, @reqif.spec_relations_groups.children.length, 'Spec Relations Groups Children Length',
                  "    Expect Spec Relations Groups Children Length to be 0. It was.")

    @reqif_file = 'test/fixtures/files/chapter3.reqif.xml'

    STDERR.puts("    Check to see that #{@reqif_file} can be parsed.")

    @reqif      = ReqIf.new(@reqif_file)

    assert_equals(3, @reqif.header.children.length, 'Header Length',
                  "    Expect Header Length to be 1. It was.")
    assert_equals(11, @reqif.reqif_header.children.length, 'ReqIf Header Children Length',
                  "    Expect ReqIf Header Children Length to be 5. It was.")
    assert_equals(13, @reqif.data_types.children.length, 'Data Types Children Length',
                  "    Expect Data Types Children Length to be 6. It was.")
    assert_equals(7535, @reqif.spec_objects.children.length, 'Spec Objects Children Length',
                  "    Expect Spec Objects Children Length to be 3767. It was.")
    assert_equals(993, @reqif.spec_relations.children.length, 'Spec Relations Children Length',
                  "    Expect Spec Relations Children Length to be 496. It was.")
    assert_equals(3, @reqif.specifications.children.length, 'Specifications Children Length',
                  "    Expect Specifications Children Length to be 1. It was.")

    @reqif_file = 'test/fixtures/files/_GA_FORCE2C_MASTER.reqif'

    STDERR.puts("    Check to see that #{@reqif_file} can be parsed.")

    @reqif      = ReqIf.new(@reqif_file)

    assert_equals(3, @reqif.header.children.length, 'Header Length',
                  "    Expect Header Length to be 1. It was.")
    assert_equals(13, @reqif.reqif_header.children.length, 'ReqIf Header Children Length',
                  "    Expect ReqIf Header Children Length to be 5. It was.")
    assert_equals(27, @reqif.data_types.children.length, 'Data Types Children Length',
                  "    Expect Data Types Children Length to be 6. It was.")
    assert_equals(5, @reqif.spec_types.children.length, 'Spec Types Children Length',
                  "    Expect Spec Types Children Length to be 5. It was.")
    assert_equals(1729, @reqif.spec_objects.children.length, 'Spec Objects Children Length',
                  "    Expect Spec Objects Children Length to be 3767. It was.")
    assert_equals(1, @reqif.spec_relations.children.length, 'Spec Relations Children Length',
                  "    Expect Spec Relations Children Length to be 496. It was.")
    assert_equals(3, @reqif.specifications.children.length, 'Specifications Children Length',
                  "    Expect Specifications Children Length to be 1. It was.")
    assert_equals(1, @reqif.spec_relations_groups.children.length, 'Spec Relations Groups Children Length',
                  "    Expect Spec Relations Groups Children Length to be 0. It was.")

    STDERR.puts('    ReqIF files were parsed successfully.')
  end

  test "export ReqIF" do
    STDERR.puts('    Check to see that a ReqIF file can be exported.')

    @reqif_file = 'tmp/test.reqif'

    reqif = ReqIf.new()

    assert(reqif.export(@reqif_file, @project.id, ReqIf::DEFAULT_ELEMENTS))

    STDERR.puts('    ReqIF file was exported successfully.')
  end
end
