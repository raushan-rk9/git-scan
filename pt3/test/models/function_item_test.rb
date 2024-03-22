require 'test_helper'

class FunctionItemTest < ActiveSupport::TestCase
  def setup
    @project           = Project.find_by(identifier: 'TEST')
    @hardware_item     = Item.find_by(identifier: 'HARDWARE_ITEM')
    @software_item     = Item.find_by(identifier: 'SOFTWARE_ITEM')
    @hardware_sc_001   = SourceCode.find_by(item_id: @hardware_item.id,
                                            full_id: 'SC-001')
    @hardware_sc_002   = SourceCode.find_by(item_id: @hardware_item.id,
                                            full_id: 'SC-002')
    @software_sc_001   = SourceCode.find_by(item_id: @software_item.id,
                                            full_id: 'SC-001')
    @software_sc_002   = SourceCode.find_by(item_id: @software_item.id,
                                            full_id: 'SC-002')
    @function_item_001 = FunctionItem.find_by(function_item_id: 1)
    @function_item_002 = FunctionItem.find_by(function_item_id: 2)
    @function_item_003 = FunctionItem.find_by(function_item_id: 3)
    @function_item_004 = FunctionItem.find_by(function_item_id: 4)
    @function_item_005 = FunctionItem.find_by(function_item_id: 5)

    user_pm
  end

  test "function item record should be valid" do
    STDERR.puts('    Check to see that a function item Record with required fields filled in is valid.')
    assert_equals(true, @function_item_001.valid?, 'function item Record', '    Expect function item Record to be valid. It was valid.')
    STDERR.puts('    The function item Record was valid.')
  end

  test "function_item_id should be present" do
    STDERR.puts('    Check to see that a function item Record without a function item ID is invalid.')

    @function_item_001.function_item_id = nil

    assert_equals(false, @function_item_001.valid?, 'function item Record', '    Expect function item without function_item_id not to be valid. It was not valid.')
    STDERR.puts('    The function item Record was invalid.')
  end

  test "full_id should be present" do
    STDERR.puts('    Check to see that a function item Record without a full ID is invalid.')

    @function_item_001.full_id = nil

    assert_equals(false, @function_item_001.valid?, 'function item Record', '    Expect function item without full id not to be valid. It was not valid.')
    STDERR.puts('    The function item Record was invalid.')
  end

# We implement CRUD Testing by default. The Read Action is implicit in setup.

  test 'should create function item' do
    STDERR.puts('    Check to see that a function item can be created.')

    function_item = FunctionItem.new({
                                        function_item_id:    6,
                                        full_id:             "#{@software_sc_001.id}_6",
                                        project_id:          @software_sc_001.project_id,
                                        source_code_id:      @software_sc_001.id,
                                        filename:            '/Users/paul/pact/test/c_code/uninstrumented_coverage.c',
                                        line_number:         120,
                                        calling_function:    'main',
                                        calling_parameters:  '(int argc, char *argv[])',
                                        called_by:           nil,
                                        function:            'function_call:B',
                                        function_parameters: '()'
                                      })

    assert_not_equals_nil(function_item.save, 'function item Record', '    Expect function item Record to be created. It was.')
    STDERR.puts('    A function item was successfully created.')
  end

  test 'should update function item' do
    STDERR.puts('    Check to see that a function item can be updated.')

    full_id                             = @function_item_001.full_id 
    @function_item_001.function_item_id = 7
    @function_item_001.full_id          = @function_item_001.full_id.gsub(':A', ':G')

    assert_not_equals_nil(@function_item_001.save, 'function item Record', '    Expect function item Record to be updated. It was.')

    @function_item_001.full_id          = full_id

    STDERR.puts('    A function item was successfully updated.')
  end

  test 'should delete function item' do
    STDERR.puts('    Check to see that a function item can be deleted.')
    assert(@function_item_001.destroy)
    STDERR.puts('    A function item was successfully deleted.')
  end

  test 'should create function item with undo/redo' do
    STDERR.puts('    Check to see that a function item can be created, then undone and then redone.')

    function_item = FunctionItem.new({
                                        function_item_id:    6,
                                        full_id:             "#{@software_sc_001.id}_6",
                                        project_id:          @software_sc_001.project_id,
                                        source_code_id:      @software_sc_001.id,
                                        filename:            '/Users/paul/pact/test/c_code/uninstrumented_coverage.c',
                                        line_number:         120,
                                        calling_function:    'main',
                                        calling_parameters:  '(int argc, char *argv[])',
                                        called_by:           nil,
                                        function:            'function_call:B',
                                        function_parameters: '()'
                                      })
    data_change   = DataChange.save_or_destroy_with_undo_session(function_item, 'create')

    assert_not_equals_nil(data_change, 'function item Record', '    Expect function item Record to be created. It was.')

    assert_difference('FunctionItem.count', -1) do
      ChangeSession.undo(data_change.session_id)
    end

    assert_difference('FunctionItem.count', +1) do
      ChangeSession.redo(data_change.session_id)
    end

    STDERR.puts('    A function item was successfully created, then undone and then redone.')
  end

  test 'should update function item with undo/redo' do
    STDERR.puts('    Check to see that a function item can be updated, then undone and then redone.')

    full_id                             = @function_item_001.full_id 
    @function_item_001.function_item_id = 7
    @function_item_001.full_id          = @function_item_001.full_id.gsub(':A', ':G')
    data_change                         = DataChange.save_or_destroy_with_undo_session(@function_item_001, 'update')
    assert_not_equals_nil(data_change, 'function item Record', '    Expect function item Record to be updated. It was')
    assert_not_equals_nil(FunctionItem.find_by(full_id: @function_item_001.full_id), 'function item Record', "    Expect function item Record's ID to be #{@function_item_001.full_id.gsub(':G', ':A')}. It was.")
    assert_equals(nil, FunctionItem.find_by(full_id: full_id), 'function item Record', '    Expect original function item Record not to be found. It was not found.')

    ChangeSession.undo(data_change.session_id)
    assert_not_equals(nil, FunctionItem.find_by(full_id: full_id), 'function item Record', "    Expect updated function item's Record not to found. It was not found.")
    assert_equals(nil, FunctionItem.find_by(full_id: @function_item_001.full_id), 'function item Record', '    Expect Orginal Record to be found. it was found.')

    ChangeSession.redo(data_change.session_id)
    assert_not_equals_nil(FunctionItem.find_by(full_id: @function_item_001.full_id), 'function item Record', "    Expect updated function item's Record to be found. It was found.")
    assert_equals(nil, FunctionItem.find_by(full_id: full_id), 'function item Record', '    Expect Orginal Record not to be found. It was not found.')
    STDERR.puts('    A function item was successfully updated, then undone and then redone.')

    @function_item_001.function_item_id = 1
    @function_item_001.full_id          = full_id
  end

  test 'should delete function item with undo/redo' do
    STDERR.puts('    Check to see that a function item can be deleted, then undone and then redone.')

    data_change = DataChange.save_or_destroy_with_undo_session(@function_item_001, 'delete')

    assert_not_equals_nil(data_change, 'function item Record', '    Expect that the delete succeded. It did.')
    assert_equals(nil, FunctionItem.find_by(full_id: @function_item_001.full_id), 'function item Record', '    Verify that the function item Record was actually deleted. It was.')

    ChangeSession.undo(data_change.session_id)
    assert_not_equals_nil(FunctionItem.find_by(full_id: @function_item_001.full_id), 'function item Record', '    Verify that the function item Record was restored after undo. It was.')

    ChangeSession.redo(data_change.session_id)
    assert_equals(nil, FunctionItem.find_by(full_id: @function_item_001.full_id), 'function item Record', '    Verify that the function item Record was deleted again after redo. It was.')
    STDERR.puts('    A function item was successfully deleted, then undone and then redone.')
  end

  test 'should parse a function definition and create a function item' do
    STDERR.puts('    Check to see that a function definition can be parsed and create a function_item.')

    code = 'char [][] test_function(char * param1, int param2 = 3, struct data param3 = NULL)'

    assert_difference('FunctionItem.count', +1) do
      assert_equals(true, FunctionItem.analyze_code(code, @software_sc_002), 'function item Record', '    Verify that the function could be parsed. It was.')
    end

    STDERR.puts('    A function definition was be parsed and successfully created a function_item.')
  end

  test 'should parse a multi-line function definition and create a function item' do
    STDERR.puts('    Check to see that a function definition can be parsed and create a function_item.')

    code = 'char [][] test_function(char * param1, int param2 = 3, struct data param3 = NULL)\n{\n}\n'

    assert_difference('FunctionItem.count', +1) do
      assert_equals(true, FunctionItem.analyze_code(code, @software_sc_002), 'function item Record', '    Verify that the function could be parsed. It was.')
    end

    STDERR.puts('    A function definition was be parsed and successfully created a function_item.')
  end

  test 'should parse a function call and create a function item' do
    STDERR.puts('    Check to see that a function definition can be parsed and create a function_item.')

    code = 'test_function_call("Dog", 2, EAGLE);'

    assert_difference('FunctionItem.count', +1) do
      assert_equals(true, FunctionItem.analyze_code(code, @software_sc_002), 'function item Record', '    Verify that the function could be parsed. It was.')
    end

    STDERR.puts('    A function definition was be parsed and successfully created a function_item.')
  end

  test 'should parse a multi-line function call and create a function item' do
    STDERR.puts('    Check to see that a function definition can be parsed and create a function_item.')

    code = 'test_function_call("Dog",\n 2,\n EAGLE);'

    assert_difference('FunctionItem.count', +1) do
      assert_equals(true, FunctionItem.analyze_code(code, @software_sc_002), 'function item Record', '    Verify that the function could be parsed. It was.')
    end

    STDERR.puts('    A function definition was be parsed and successfully created a function_item.')
  end

  test 'should parse a function definition and call and create two function items' do
    STDERR.puts('    Check to see that a function definition and call can be parsed and create two function items.')

    code = "#include <stdio.h>\n\nint main(argv[][], int argc)\n{\n  printf(\"Hello World\");\n}"

    assert_difference('FunctionItem.count', +2) do
      assert_equals(true, FunctionItem.analyze_code(code, @software_sc_002), 'function item Record', '    Verify that the function could be parsed. It was.')
    end

    STDERR.puts('    A function definition and call were parsed and created two function items.')
  end

  test 'should parse uninstrumented_coverage.c and create function items' do
    STDERR.puts('    Check to see that uninstrumented_coverage.c can be parsed and create function items.')

    code = File.read('/Users/paul/pact/test/c_code/uninstrumented_coverage.c')

    assert_difference('FunctionItem.count', +28) do
      assert_equals(true, FunctionItem.analyze_code(code, @software_sc_002), 'function item Record', '    Verify that the function could be parsed. It was.')

      function_items = FunctionItem.where(filename: "alert_underpressure.c")

      function_items.each { |item| puts "#{item.id} #{item.calling_function},#{item.called_by},#{item.function}" }
    end

    STDERR.puts('    uninstrumented_coverage.c was parsed and created function items.')
  end

  test 'should parse main.c and functions.c and create function items' do
    STDERR.puts('    Check to see that main.c and functions.c and functions2.c can be parsed and function items created.')

    main_code       = File.read('/Users/paul/pact/test/c_code/main.c')
    functions_code  = File.read('/Users/paul/pact/test/c_code/functions.c')
    functions2_code = File.read('/Users/paul/pact/test/c_code/functions2.c')

    assert_difference('FunctionItem.count', +28) do
      assert_equals(true, FunctionItem.analyze_code(main_code,      @hardware_sc_001), 'function item Record', '    Verify that the main.c could be parsed. It was.')
      assert_equals(true, FunctionItem.analyze_code(functions_code, @hardware_sc_002), 'function item Record', '    Verify that the functions.c could be parsed. It was.')
      assert_equals(true, FunctionItem.analyze_code(functions2_code, @hardware_sc_002), 'function item Record', '    Verify that the functions2.c could be parsed. It was.')

      FunctionItem.associate_codes(@hardware_item.id, :item)

      function_items = FunctionItem.where(item_id: @hardware_item.id)

      function_items.each { |item| puts "#{item.id} #{item.calling_function},#{item.called_by},#{item.function}" }
    end

    STDERR.puts('    main.c and functions.c and functions2.c were parsed and created function items.')
  end
end
