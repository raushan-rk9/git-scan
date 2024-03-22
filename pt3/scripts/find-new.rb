#!/usr/bin/env ruby

# Imports
require 'byebug'
require 'optparse'
require 'shellwords'
require 'fileutils'
require 'date'

# This hash will hold all of the options
# parsed from the command-line by
# OptionParser.
@options = {}

def get_directory(prompt, mode)
  directory       = nil

  while directory.nil?   ||
        (!directory.nil? &&  ((mode == :read)  && !File.readable?(directory)))
    print prompt
    $stdout.flush
    directory     = gets

    directory.chomp!

    if directory == ''
      puts "You must enter a directory."
      directory   = nil
    else
      exit(0) if directory.downcase[0, 1] == 'q'

      unless DIR.exist?(directory)
        puts "Cannot read directory: #{directory}."

        directory = nil
      end
    end
  end
  
  return directory
end

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
    @options[:debug]             = false
    @options[:recursive]         = false
    @options[:after]             = DateTime.now - 1
    @options[:before]            = DateTime.now
    @output_file                 = STDOUT
    @options[:search]            = '.'

    opts.on('-r', '--recursive', 'Recursive') do
      @options[:recursive]       = true
    end

    opts.on('-D', '--debug', 'Debug') do
      @options[:debug]           = true
      byebug
    end

    opts.on('-v', '--verbose', 'Output more information') do
      @options[:verbose]         = true
    end

    opts.on('-I', '--interactive', 'Set interactive mode.') do
      @options[:interactive]     = true
    end

    opts.on("-x EXCLUDE", "--exclude=EXCLUDE", "String to replace with") do |exclude|
      @options[:exclude]         = exclude
    end

    opts.on('-o OUTPUT', '--output-file=OUTPUT', 'Output file to save results to') do |output|
      @output_file               = File.open(@options[:output], 'w')
    end

    opts.on('-a DATE', '--after=DATE|DAYS', 'Find Files after') do |after|
      if after.to_s =~ /^[\-]{0,1}\d+$/
        @options[:after]         = DateTime.now + after.to_i
      else
        @options[:after]         = DateTime.parse(after)
      end
    end

    opts.on('-b DATE', '--before=DATE|DAYS', 'Find Files before') do |before|
      if before.to_s =~ /^[\-]{0,1}\d+$/
        @options[:before]         = DateTime.now + before.to_i
      else
        @options[:before]        = DateTime.parse(before)
      end
    end

    opts.on('-s DIRECTORY', '--search=DIRECTORY', 'Directory to search') do |search|
      if !DIR.exist?(search)
        puts "Cannot read directory: #{search}."
      else
        @options[:search]        = search
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

def process_directory(directory)
  subdirectories = []

  puts "Processing: #{directory}." if @options[:verbose]

  begin
    Dir.each_child(directory) do |entry|
      path       = File.join(directory, entry)
      modified   = File.mtime(path).to_datetime

      @output_file.puts("#{modified}: #{path}")        if (modified >= @options[:after])  &&
                                                          (modified <= @options[:before])
      subdirectories.push(File.join(directory, entry)) if @options[:recursive]            &&
                                                          File.directory?(path)
    end

    subdirectories.each { |subdirectory| process_directory(subdirectory) } unless subdirectories.empty?
  rescue => e
    puts STDERR.fputs("Error while scanning: #{e.message})")
  end
end

def find_modified
  if @options[:interactive] || @options[:verbose]
    puts("After #{@options[:after]}")
    puts("Before #{@options[:before]}")
    puts("Excluding #{@options[:exclude]}")
    puts("Writing to #{@options[:output]}")
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

  process_directory(@options[:search])
end

parse_options
input_options if @options[:interactive]
find_modified
