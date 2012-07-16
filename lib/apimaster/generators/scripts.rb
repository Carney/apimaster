
module Apimaster end

require File.dirname(__FILE__) + '/options'
require File.dirname(__FILE__) + '/manifest'
require File.dirname(__FILE__) + '/simple_logger'

require File.dirname(__FILE__) + '/base'
require File.dirname(__FILE__) + '/command'
require File.dirname(__FILE__) + '/app_generator'
require File.dirname(__FILE__) + '/model_generator'
require File.dirname(__FILE__) + '/controller_generator'

module Apimaster::Generators
  module Scripts

    # Generator scripts handle command-line invocation.  Each script
    # responds to an invoke! class method which handles option parsing
    # and generator invocation.
    class Base
      include Options

      default_options :collision => :ask, :quiet => false

      attr_reader :stdout
      attr_accessor :commands

      def initialize
        @commands ||= {}
        register("new", AppGenerator)
        register("model", ModelGenerator)
        register("controller", ControllerGenerator)
      end

      def register name, klass
        @commands[name] = klass
      end

      # Run the generator script.  Takes an array of unparsed arguments
      # and a hash of parsed arguments, takes the generator as an option
      # or first remaining argument, and invokes the requested command.
      def run(args = [], runtime_options = {})
        @stdout = runtime_options[:stdout] || $stdout
        begin
          parse!(args.dup, runtime_options)
        rescue OptionParser::InvalidOption => e
          # Don't cry, script. Generators want what you think is invalid.
        end

        # Look up generator instance and invoke command on it.
        begin
          command = args.shift
          if command and commands.key?(command)
            commands[command].new(args).run
          else
            raise "Invalid command name: #{command}"
          end
        rescue => e
          stdout.puts e
          stdout.puts "  #{e.backtrace.join("\n  ")}\n" if options[:backtrace]
          raise SystemExit unless options[:no_exit]
        end
      end

    end
  end
end
