#!/usr/bin/env ruby

# Imports
require 'csv'
require 'optparse'
require 'shellwords'

# This hash will hold all of the options
# parsed from the command-line by
# OptionParser.
options = {}
optparse = OptionParser.new do|opts|
  # Set a banner, displayed at the top
  # of the help screen.
  opts.banner = "Usage: process_csv.rb [options]"
  # Define the options, and what they do
  options[:verbose] = false
  opts.on('-v', '--verbose', 'Output more information') do
    options[:verbose] = true
  end
  options[:csvfilepath] = nil
  opts.on('-p', '--csvfilepath FOLDER', 'Folder containing CSVs to process') do |folder|
    options[:csvfilepath] = folder
  end
  # This displays the help screen, all programs are
  # assumed to have this option.
  opts.on('-h', '--help', 'Display this screen') do
    puts opts
    exit
  end
end
# Parse the command-line. Remember there are two forms
# of the parse method. The 'parse' method simply parses
# ARGV, while the 'parse!' method parses ARGV and removes
# any options found there, as well as any parameters for
# the options. What's left is the list of files to resize.
optparse.parse!

# Print options
if options[:csvfilepath]
  csvfile_path = File.absolute_path(options[:csvfilepath])
  csvfile_array = Dir.glob("#{csvfile_path}/*.csv", File::FNM_CASEFOLD)
  puts "CSV files: #{csvfile_array}"
else
  puts 'ERROR: No CSV file/folder'
  exit
end

# Functions
# Validate that the string is alphanumeric
def validate(string)
  !string.match(/\A[a-zA-Z0-9]*\z/).nil?
end


# Begin Code
# Loop for each csv found
csvfile_array.each do |csv_each|
  puts "\nProcessing #{csv_each}"
  begin
    # Try to read the csv.
    csvfile_read = CSV.read(csv_each)

    # First pass, get header lines.
    header1 = nil
    header2 = nil
    csvfile_read.each do |line|
      # Print the header line.
      if line[1] == 'Checklist Item'
        header1 = line
        puts "Header Line 1: #{header1}" 
      end
      if line[7] == 'MB' or line[7] == 'DO-330'
        header2 = line
        puts "Header Line 2: #{header2}\n"
      end
    end

    # Detect if DO-330 or MB
    headertype = '0'
    if header2[7] == 'MB'
      headertype = '1'
    elsif header2[7] == 'DO-330'
      headertype = '2'
    end

    # Second pass, create hash
    hasharray = []
    linenum = 1
    csvfile_read.each do |line|
      unless line[0].nil? or line[1].nil? or !validate(line[0])
        # Print the line being processed.
        # puts "Line #{linenum}: #{line}"

        # CSV Notes:
        # 0: id, 1: description, 2: reference, 3-6: DAL A through D required, 7: DO330, 8: Combliance Y, 9: Compliance N, 10: Compliance N/A, 11: Remarks
        # 0: id, 1: description, 2: reference, 3-6: DAL A through D required, 7: modelbased, 8: formalmethod, 9: objectoriented, 10: Combliance Y, 11: Compliance N, 12: Compliance N/A, 13: Remarks

        # Get DAL level
        dal = 'N/A'
        if line[6] == 'X'
          dal = 'D'
        elsif line[5] == 'X'
          dal = 'C'
        elsif line[4] == 'X'
          dal = 'B'
        elsif line[3] == 'X'
          dal = 'A'
        else
          dal = 'N/A'
        end

        # Get do330, modelbased, formalmethod, and objectoriented.
        supp = []
        # Type one has modelbased, formalmethod, and objectoriented. Type two has DO-330
        if headertype == '1'
          supp.push('Model Based') if line[7] == 'X'
          supp.push('Formal Method') if line[8] == 'X'
          supp.push('Object Oriented') if line[9] == 'X'
        elsif headertype == '2'
          supp.push('DO-330') if line[7] == 'X'
        end

        # Create a hash.
        csv_hash = {
          id: line[0],
          description: line[1],
          reference: line[2],
          minimumdal: dal,
          supplements: supp,
        }
        # puts "#{csv_hash},"
        hasharray.push(csv_hash)
      end
      linenum += 1
    end

    # Create string to output to file
    a = '#!/usr/bin/env ruby'
    a += "\n"
    a += "hash = [\n"
    hasharray.each_with_index do |h, index|
      a += h.to_s
      if index != hasharray.size - 1
        a += ','
      end
      a += "\n"
    end
    a += ']'

    # Set the filename of the output
    csv_basename = File.basename(csv_each)
    # Write the file
    output_filename = File.absolute_path(File.join(csvfile_path, "#{csv_basename}.rb"))
    File.write(output_filename, a)
    # Format the rb file using external tool rubocop.
    system("rubocop -af progress #{output_filename.shellescape}", :out => File::NULL)
  rescue
    puts "\nERROR: File #{csv_each} failed to process!\n"
  end
end