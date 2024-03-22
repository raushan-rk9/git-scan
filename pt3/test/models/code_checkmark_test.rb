require 'test_helper'

class CodeCheckmarkTest < ActiveSupport::TestCase
  def setup
    user_pm

    @bitfield_bitmap      = "1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001111"
    @ten_k_bitmap         = "101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010" \
                            "101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010" \
                            "101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010" \
                            "101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010" \
                            "1010101010101010101010101010101010101010101010101010101010"
    @integer_bitmap       = "9223372037926674175"
    @hex_bitmap           = "0x800000003fe3deff"
    @c_folder             = File.join(Rails.root, 'test', 'c_code')
    @code_file            = 'coverage.c'
    @code_filename        = File.join(@c_folder, @code_file)
    @coverage_file        = 'coverage.log'
    @coverage_filename    = File.join(@c_folder, @coverage_file)
    @seconds_file         = 'coverage_seconds.log'
    @seconds_filename     = File.join(@c_folder, @seconds_file)
    @nanoseconds_file     = 'coverage_nanoseconds.log'
    @nanoseconds_filename = File.join(@c_folder, @nanoseconds_file)
    @strftime_file        = 'coverage_strftime.log'
    @strftime_filename    = File.join(@c_folder, @strftime_file)
    @integer_file         = 'coverage_integer_bitmap.log'
    @integer_filename     = File.join(@c_folder, @integer_file)
    @hex_file             = 'coverage_bitmap.log'
    @hex_filename         = File.join(@c_folder, @hex_file)
    @project              = Project.create!(
                                             identifier:   'Test Project',
                                             name:         'Test Project',
                                             description:  'Test Project',
                                             access:       'Public',
                                             organization: 'global'
                                           )
    @item                 = Item.create!(
                                          project_id:   @project.id,
                                          identifier:   'Test Item',
                                          name:         'Test Item',
                                          itemtype:     'DO-18',
                                          level:        'C',
                                          organization: 'global'
                                       )
    @source_code          = SourceCode.create!(
                                                project_id:                          @project.id,
                                                item_id:                             @item.id,
                                                codeid:                              1,
                                                full_id:                             'SC-1',
                                                file_name:                           @code_file,
                                                module:                              '',
                                                function:                            'main',
                                                derived:                             true,
                                                derived_justification:               'For testing only.',
                                                high_level_requirement_associations: '',
                                                low_level_requirement_associations:  '',
                                                url_type:                            'ATTACHMENT',
                                                url_description:                     'Coverage',
                                                url_link:                            @code_filename,
                                                version:                             1,
                                                organization:                        'global'
                                             )
    @code_marks           = [
                               0,
                               1,
                               2,
                               3,
                               4,
                               5,
                               6,
                               7,
                               8,
                               9,
                               10,
                               11,
                               12,
                               13,
                               14,
                               15,
                               16,
                               17,
                               18,
                               19,
                               20,
                               21,
                               22,
                               23,
                               24,
                               25,
                               26,
                               27,
                               28,
                               29,
                               30,
                               31,
                               32,
                               33,
                               34,
                               99
                            ]
  end

  def dump_hits(test, code_mark_hits)
    STDERR.puts
    STDERR.puts "      #{test}"

    code_mark_hits.each do |hit|
      code_checkmark = CodeCheckmark.find(hit.code_checkmark_id)

      if hit.hit_at.present?
        STDERR.puts("      CMARK ID: #{code_checkmark.checkmark_id}, #{DateTime.now.strftime('%Y-%m-%dT%H:%M:%S.%N')}")
      else
        STDERR.puts("      CMARK ID: #{code_checkmark.checkmark_id}")
      end
    end unless code_mark_hits.empty?

    STDERR.puts
  end

  test "instrument_code_file(#{@code_file})" do
    STDERR.puts('    Check to see that a Code File can be instrumented.')
    assert CodeCheckmark.instrument_code_file(@code_filename, @source_code)

    @code_marks  = CodeCheckmark.where(filename: @code_filename)

    assert @code_marks.length == @code_marks.length
    STDERR.puts('    A Code File was successfully instrumented.')
  end

  test "10K Bitmap" do
    STDERR.puts('    Check to see that a 10K Bitmap can be processed.')
    assert CodeCheckmark.instrument_code_file(@code_filename, @source_code)

    @code_marks  = CodeCheckmark.where(filename: @code_filename)

    assert @code_marks.length == @code_marks.length

    assert CodeCheckmarkHit.record_hits(@ten_k_bitmap)

    @code_mark_hits  = CodeCheckmarkHit.all

    dump_hits('Bitmap Hits:', @code_mark_hits)
    STDERR.puts('    A 10K Bitmap was successfully instrumented.')
  end

  test "Bitmap Field" do
    STDERR.puts('    Check to see that a Bitmap Field file can be processed.')
#    assert CodeCheckmark.instrument_code_file(@code_filename, @source_code,
#                                              nil, true, 'CMARK_BITFIELD')

    @code_marks  = CodeCheckmark.where(filename: @code_filename)

#    assert CodeCheckmarkHit.record_hits(@bitfield_bitmap)

    @code_mark_hits  = CodeCheckmarkHit.all

    dump_hits('Bitmap Hits:', @code_mark_hits)
    STDERR.puts('    A 10K Bitmap was successfully instrumented.')
  end

  test "Integer Bitmap" do
    STDERR.puts('    Check to see that a Integer Bitmap can be processed.')
    assert CodeCheckmark.instrument_code_file(@code_filename, @source_code)

    @code_marks  = CodeCheckmark.where(filename: @code_filename)

    assert @code_marks.length == @code_marks.length

    assert CodeCheckmarkHit.record_hits(@integer_bitmap)

    @code_mark_hits  = CodeCheckmarkHit.all

    dump_hits('Integer Time Hits:', @code_mark_hits)
    STDERR.puts('    A Integer Bitmap was successfully instrumented.')
  end

  test "Hex Bitmap" do
    STDERR.puts('    Check to see that a Hex Bitmap can be processed.')
    assert CodeCheckmark.instrument_code_file(@code_filename, @source_code)

    @code_marks  = CodeCheckmark.where(filename: @code_filename)

    assert @code_marks.length == @code_marks.length

    assert CodeCheckmarkHit.record_hits(@hex_bitmap)

    @code_mark_hits  = CodeCheckmarkHit.all

    dump_hits('Integer Time Hits:', @code_mark_hits)
    STDERR.puts('    A Hex Bitmap was successfully instrumented.')
  end

  test "Coverage No Time" do
    STDERR.puts('    Check to see that a coverage without time can be processed.')
    assert CodeCheckmark.instrument_code_file(@code_filename, @source_code)

    @code_marks  = CodeCheckmark.where(filename: @code_filename)

    assert @code_marks.length == @code_marks.length

    assert CodeCheckmarkHit.record_hits(@coverage_filename)

    @code_mark_hits  = CodeCheckmarkHit.all

    dump_hits('Coverage No Time:', @code_mark_hits)
    STDERR.puts('    Coverage without time was successfully instrumented.')
  end

  test "Coverage Seconds" do
    STDERR.puts('    Check to see that a coverage in seconds can be processed.')
    assert CodeCheckmark.instrument_code_file(@code_filename, @source_code)

    @code_marks  = CodeCheckmark.where(filename: @code_filename)

    assert @code_marks.length == @code_marks.length

    assert CodeCheckmarkHit.record_hits(@seconds_filename)

    @code_mark_hits  = CodeCheckmarkHit.all

    dump_hits('Seconds Time Hits:', @code_mark_hits)
    STDERR.puts('    Coverage in seconds was successfully instrumented.')
  end

  test "Coverage Nanoseconds" do
    STDERR.puts('    Check to see that a coverage in nanaseconds can be processed.')
    assert CodeCheckmark.instrument_code_file(@code_filename, @source_code)

    @code_marks  = CodeCheckmark.where(filename: @code_filename)

    assert CodeCheckmarkHit.record_hits(@nanoseconds_filename)

    @code_mark_hits  = CodeCheckmarkHit.all

    dump_hits('Nanoseconds Time Hits:', @code_mark_hits)
    STDERR.puts('    Coverage in nanoseconds was successfully instrumented.')
  end

  test "Coverage strftime" do
    STDERR.puts('    Check to see that a coverage using strftime can be processed.')
    assert CodeCheckmark.instrument_code_file(@code_filename, @source_code)

    @code_marks  = CodeCheckmark.where(filename: @code_filename)

    assert @code_marks.length == @code_marks.length

    assert CodeCheckmarkHit.record_hits(@strftime_filename)

    @code_mark_hits  = CodeCheckmarkHit.all

    dump_hits('Strftime Time Hits:', @code_mark_hits)
    STDERR.puts('    Coverage using strftime was successfully instrumented.')
  end
end
