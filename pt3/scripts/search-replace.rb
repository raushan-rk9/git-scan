#!/usr/bin/env ruby

# Imports
require 'byebug'
require 'optparse'
require 'shellwords'
require 'fileutils'

# This hash will hold all of the options
# parsed from the command-line by
# OptionParser.
@options = {}

def get_file(prompt, mode)
  filename       = nil

  while filename.nil?   ||
        (!filename.nil? &&  ((mode == :read)  && !File.readable?(filename)))
    print prompt
    $stdout.flush
    filename     = gets

    filename.chomp!

    if filename == ''
      puts "You must enter a filename."
      filename   = nil
    else
      exit(0) if filename.downcase[0, 1] == 'q'

      if (((mode == :read)  && !File.readable?(filename)))
        if mode == :write
          puts "Cannot write file: #{filename}."
        else
          puts "Cannot read file: #{filename}."
        end

        filename = nil
      end
    end
  end
  
  return filename
end

def get_string(prompt, error)
  text     = nil

  while text.nil?
    print prompt
    $stdout.flush
    text   = gets

    text.chomp!

    if text == ''
      puts error
      text = nil
    end
  end
  
  return text
end

def parse_options
  optparse                       = OptionParser.new do|opts|
    # Set a banner, displayed at the top
    # of the help screen.
    opts.banner                  = "Usage: search-replace.rb [options]"
    # Define the options, and what they do
    @options[:verbose]           = false
    @options[:interactive]       = false
    @options[:dry_run]           = false
    @options[:debug]             = false
    @options[:replace_original]  = false

    opts.on('-D', '--debug', 'Debug') do
      @options[:debug]       = true
      byebug
    end

    opts.on('-v', '--verbose', 'Output more information') do
      @options[:verbose]     = true
    end

    opts.on('-I', '--interactive', 'Set interactive mode.') do
      @options[:interactive] = true
    end

    opts.on('-d', '--dry-run', 'Only display changes.') do
      @options[:dry_run]     = true
    end

    opts.on('-p', '--putback', 'Replace Original File arfter processing') do
      @options[:replace_original] = true
    end

    opts.on("-sSEARCH", "--search=SEARCH", "String to search for") do |search|
      @options[:search]      = search
    end

    opts.on("-rREPLACE", "--replace=REPLACE", "String to replace with") do |replace|
      @options[:replace]     = replace
    end

    opts.on("-xEXCLUDE", "--exclude=EXCLUDE", "String to replace with") do |exclude|
      @options[:exclude]     = exclude
    end

    @options[:input]         = nil

    opts.on("-iINPUT", "--input-file=INPUT", "String to replace with") do |input|
      @options[:input]       = input
    end

    @options[:output]        = nil

    opts.on('-oOUTPUT', '--output-file=OUTPUT', 'Output file to process') do |output|
      @options[:output]      = output
    end

    opts.on("-l", "--file-list=FILENAME", "String to replace with") do |file_list|
      @options[:file_list]   = []

      File.open(file_list, 'r') do |list_file|
        while(file = list_file.gets)
          file.chomp!
          file.strip!
          @options[:file_list].push(file)
        end
      end
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
end

def input_options
  @options[:input]   = get_file("Input Filename: ",  :read)               unless @options[:input]
  @options[:output]  = get_file("Output Filename: ", :write)              unless @options[:output]
  @options[:search]  = get_string("Search for: ",
                                  "You must enter a search string.")      unless @options[:search]
  @options[:replace] = get_string("Replace for: ",
                                  "You must enter a replacement string.") unless @options[:replace]
end

def check_options
  if @options[:input] && File.readable?(@options[:input])
    @options[:input] = File.absolute_path(@options[:input])
  else
    puts 'ERROR: No Input file present.'
    exit
  end

  if !@options[:output].nil?
    @options[:output] = File.absolute_path(@options[:output])
  else
    puts 'ERROR: No Output file present.'
    exit
  end

  unless @options[:search]
    puts 'ERROR: No Search String present.'
    exit
  end

  unless @options[:replace]
    puts 'ERROR: No Replace String present.'
    exit
  end
end

def process_line(line)
  return line if !@exclude.nil? && line.index(@exclude)
  return line if @search.nil?   && @replace.nil

  new_line             = line.dup

  new_line.gsub!(@search, @replace)

  return new_line
end

def process_file
  @search           = nil
  @replace          = nil
  @exclude          = nil

  unless @options[:search].nil?
    @search         = if @options[:search] =~ /^\/(.*)\/$/
                        Regexp.new(Regexp.last_match(1))
                      else
                        @options[:search]
                      end
  end

  unless @options[:replace].nil?
    @replace        = if @options[:replace] =~ /^\/(.*)\/$/
                        Regexp.new(Regexp.last_match(1))
                      else
                        @options[:replace]  
                      end
  end

  unless @options[:exclude].nil?
    @exclude        = if @options[:exclude] =~ /^\/(.*)\/$/
                        Regexp.new(Regexp.last_match(1))
                      else
                        @options[:exclude]  
                      end
  end

  File.open(@options[:input], 'r')    do |input_file|
    if @options[:output].nil? || (@options[:output].downcase == 'stdout')
      while (line   = input_file.gets)
        line        = process_line(line)

        puts(line)
      end
    else
      File.open(@options[:output], 'w') do |output_file|
        while (line = input_file.gets)
          line      = process_line(line)

          output_file.puts(line)
        end
      end
    end
  end
end

def search_replace
  check_options

  if @options[:interactive] || @options[:verbose]
    puts("Searching #{@options[:input]}")
    puts("Writing to #{@options[:output]}")
    puts("Searching for #{@options[:search]}")
    puts("Replacing with #{@options[:replace]}")
    puts("Excluding #{@options[:exclude]}")
  end

  if @options[:interactive]
    continue   = nil

    while (continue != 'y') && (continue != 'n')
      continue = get_string("Do you want to continue[YyNn]: ",
                            "You must enter Y or N.")
      continue = continue.downcase[0, 1] unless continue.nil?
    end

    exit(0) if continue == 'n'
  end

  puts "Processing #{@options[:input]} to #{@options[:input]}." if @options[:verbose]
  process_file

  if @options[:replace_original]
    FileUtils.cp(@options[:output], @options[:input])
    FileUtils.rm(@options[:output])
  end

  puts "Processed #{@options[:input]} successfully."            if @options[:verbose]
end

parse_options
input_options if @options[:interactive]

if @options[:file_list]
  @options[:file_list].each do |filename|
    @options[:input] = filename

    search_replace
  end
else
  search_replace
end
