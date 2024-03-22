#!/usr/bin/env ruby

# Imports
require 'date'
require 'byebug'
require 'optparse'
require 'shellwords'
require 'fileutils'
require 'open3'

# This hash will hold all of the options
# parsed from the command-line by
# OptionParser.
@options     = {}
@directory   = '/etc'
@directories = []

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

      if !DIR.exist?(directory)
        puts "Cannot read directory: #{directory}."

        directory = nil
      end
    end
  end
  
  return directory
end

def parse_options
  optparse                    = OptionParser.new do|opts|
    # Set a banner, displayed at the top
    # of the help screen.
    opts.banner               = "Usage: scan-certificates.rb [options]"
    # Define the options, and what they do
    @options[:verbose]        = false
    @options[:debug]          = false
    @options[:interactive]    = false
    @options[:expired]        = false
    @options[:only_filename]  = false
    @options[:directory]      = '/etc'
    @options[:domain_name]    = nil
    @options[:exclude]        = nil
    @options[:serial_number]  = nil

    opts.on('-n DOMAIN_NAME', '--name=DOMAIN_NAME', 'Domain to process') do |domain|
      @options[:domain_name]  = domain
    end

    opts.on('-d DIRECTORY', '--directory=DIRECTORY', 'Directory to process') do |directory|
      @options[:directory]    = directory
    end

    opts.on('-s SERIAL_NUMBER', '--serial-number=SERIAL_NUMBER', 'Serial Number to process') do |sn|
      @options[:serial_number] = sn
    end

    opts.on('-O', '--only-filename', 'Only Filename') do
      @options[:only_filename] = true
    end

    opts.on('-D', '--debug', 'Debug') do
      @options[:debug]         = true

      byebug
    end

    opts.on('-E', '--expired', 'Expired') do
      @options[:expired]       = true
    end

    opts.on('-I', '--interactive', 'Set interactive mode.') do
      @options[:interactive]   = true
    end

    opts.on('-s DIRECTORY', '--skip=DIRECTORY', 'Directory to skip') do |skip|
      @options[:exclude]       = skip
    end

    opts.on('-v', '--verbose', 'Output more information') do
      @options[:verbose]       = true
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
  @options[:directory] = get_folder("Folder to scan:: ") unless @options[:directory]
end

def check_options
  if @options[:directory] == nil ||
     @options             == ''  ||
     !Dir.exist?(@options[:directory])
    puts 'ERROR: No Directory present.'
    exit
  end
end

def process_file(filename)
  return false if !@options[:exclude].nil? && filename.index(@options[:exclude])

  output         = []
  domain_name    = nil
  expires        = nil
  result         = true
  domain_found   = false

  if File.readable?(filename)
    output.push("  Processing Certificate: #{filename} (Modified: #{File.mtime(filename)})...")

    Open3.popen3("openssl x509 -text -in #{filename}") do |stdout, stderr, status, thread|
      line            = stderr.gets

      while !line.nil? do
        if line =~ /^.*CN\s*=\s(.*)$/
          domain_name = Regexp.last_match(1)

          if domain_name != 'R3'
            if !domain_name.nil?            &&
               !@options[:domain_name].nil? &&
               (domain_name != @options[:domain_name])
              output.pop

              result       = false
            else
              domain_found = true
            end

            output.push("    Domain Name:   #{domain_name}")          if result && !@options[:only_filename] && (domain_name != 'R3')
          end
        elsif line =~ /^.*Not Before\s*\:\s*(.*)$/
          output.push("    Issued:        #{Regexp.last_match(1)}") if result && !@options[:only_filename]
        elsif line =~ /^.*Serial Number\s*\:\s*$/
          serial_number = stderr.gets.strip

          if !serial_number.nil?            &&
             !@options[:serial_number].nil? &&
             !serial_number.index(@options[:serial_number])
            output.pop

            result       = false
          end

          output.push("    Serial Number: #{serial_number}")         if result && !@options[:only_filename]
        elsif line =~ /^.*Not After\s*\:\s*(.*)$/
          expires = DateTime.parse(Regexp.last_match(1))

          output.push("    Expires:       #{Regexp.last_match(1)}") if result && !@options[:only_filename]
        end

        line = stderr.gets
      end
    end
  end

  if domain_found && (output.length > 0)
    if @options[:expired]
        if expires < DateTime.now
          output.each { |text| puts(text) }
        end
    else
      output.each { |text| puts(text)     }
    end
  end
end

def process_directory(directory)
  subdirectories = []

  puts "Processing: #{directory}." if @options[:verbose]

  begin
    Dir.each_child(directory) do |entry|
      if File.directory?(File.join(directory, entry))
        subdirectories.push(File.join(directory, entry))
      elsif entry =~ /^.+\.(pem|crt|cert)/i
        process_file(File.join(directory, entry))
      end
    end

    subdirectories.each { |subdirectory| process_directory(subdirectory) }
  rescue
  end
end

parse_options
input_options if @options[:interactive]
check_options
process_directory(@options[:directory])
