# Apimaster::Generators is a code generation platform Ruby frameworks.
# Generators are easily invoked within Ruby framework instances
# to add and remove components such as library and test files.
#
# New generators are easy to create and may be distributed within RubyGems,
# user home directory, or within each Ruby framework that uses Apimaster::Generators.
#
# For example, newgem uses Apimaster::Generators to generate new RubyGems. Those
# generated RubyGems can then use Apimaster::Generators (via a generated script/generate
# application) to generate tests and executable apps, etc, for the RubyGem.
#
# Generators may subclass other generators to provide variations that
# require little or no new logic but replace the template files.
#
# For a RubyGem, put your generator classes and templates within subfolders
# of the +generators+ directory.
#
# The layout of generator files can be seen in the built-in
# +test_unit+ generator:
#
#   test_unit_generators/
#     test_unit/
#       test_unit_generator.rb
#       templates/
#         test_unit.rb
#
# The directory name (+test_unit+) matches the name of the generator file
# (test_unit_generator.rb) and class (+TestUnitGenerators+). The files
# that will be copied or used as templates are stored in the +templates+
# directory.
#
# The filenames of the templates don't matter, but choose something that
# will be self-explanatory since you will be referencing these in the
# +manifest+ method inside your generator subclass.
#
#
require 'rbconfig'

module Apimaster::Generators
  class GeneratorsError < StandardError; end
  class UsageError < GeneratorsError; end


  # The base code generator is bare-bones.  It sets up the source and
  # destination paths and tells the logger whether to keep its trap shut.
  #
  # It's useful for copying files such as stylesheets, images, or
  # javascripts.
  #
  # For more comprehensive template-based passive code generation with
  # arguments, you'll want Apimaster::Generators::NamedBase.
  #
  # Generators create a manifest of the actions they perform then hand
  # the manifest to a command which replays the actions to do the heavy
  # lifting (such as checking for existing files or creating directories
  # if needed). Create, destroy, and list commands are included.  Since a
  # single manifest may be used by any command, creating new generators is
  # as simple as writing some code templates and declaring what you'd like
  # to do with them.
  #
  # The manifest method must be implemented by subclasses, returning a
  # Apimaster::Generators::Manifest.  The +record+ method is provided as a
  # convenience for manifest creation.  Example:
  #
  #   class StylesheetGenerators < Apimaster::Generators::Base
  #     def manifest
  #       record do |m|
  #         m.directory('public/stylesheets')
  #         m.file('application.css', 'public/stylesheets/application.css')
  #       end
  #     end
  #   end
  #
  # See Apimaster::Generators::Commands::Create for a list of methods available
  # to the manifest.
  class Base
    include Options

    DEFAULT_SHEBANG = File.join(RbConfig::CONFIG['bindir'],
                                RbConfig::CONFIG['ruby_install_name'])

    default_options   :shebang => DEFAULT_SHEBANG,
                      :an_option => 'some_default'

    # Declare default options for the generator.  These options
    # are inherited to subclasses.
    default_options :collision => :ask, :quiet => false, :stdout => STDOUT

    # A logger instance available everywhere in the generator.
    attr_accessor :logger

    # Either Apimaster::Generators::Base, or a subclass (e.g. Rails::Generators::Base)
    # Currently used to determine the lookup paths via the overriden const_missing mechansim
    # in lookup.rb
    attr_accessor :active

    # Every generator that is dynamically looked up is tagged with a
    # Spec describing where it was found.
    attr_accessor :spec
    #class_attribute :spec

    attr_reader :source_root, :destination_root, :args, :stdout

    def initialize(runtime_args, runtime_options = {})
      runtime_options[:source] = File.dirname(__FILE__) + '/templates'
      runtime_options[:destination] = Dir.pwd
      runtime_options[:collision] = :ask
      runtime_options[:stdout] = STDOUT
      runtime_options[:backtrace] = true
      @logger = SimpleLogger.new
      @args = runtime_args
      parse!(@args, runtime_options)

      # Derive source and destination paths.
      @source_root = options[:source] || File.join(spec.path, 'templates')
      if options[:destination]
        @destination_root = options[:destination]
      end

      # Silence the logger if requested.
      #logger.quiet = options[:quiet]

      @stdout = options[:stdout]

      # Raise usage error if help is requested.
      usage if options[:help]
    end

    # Generators must provide a manifest.  Use the +record+ method to create
    # a new manifest and record your generator's actions.
    def manifest
      raise NotImplementedError, "No manifest for '#{spec.name}' generator."
    end

    # Return the full path from the source root for the given path.
    # Example for source_root = '/source':
    #   source_path('some/path.rb') == '/source/some/path.rb'
    #
    # The given path may include a colon ':' character to indicate that
    # the file belongs to another generator.  This notation allows any
    # generator to borrow files from another.  Example:
    #   source_path('model:fixture.yml') = '/model/source/path/fixture.yml'
    def source_path(relative_source)
      # Check whether we're referring to another generator's file.
      name, path = relative_source.split(':', 2)

      # If not, return the full path to our source file.
      if path.nil?
        File.join(source_root, name)

      # Otherwise, ask our referral for the file.
      else
        # FIXME: this is broken, though almost always true.  Others'
        # source_root are not necessarily the templates dir.
        File.join(self.class.lookup(name).path, 'templates', path)
      end
    end

    # Return the full path from the destination root for the given path.
    # Example for destination_root = '/dest':
    #   destination_path('some/path.rb') == '/dest/some/path.rb'
    def destination_path(relative_destination)
      File.expand_path(File.join(destination_root, relative_destination))
    end

    # Return the basename of the destination_root,
    # BUT, if it is trunk, tags, or branches, it continues to the
    # parent path for the name
    def base_name
      name = File.basename(destination_root)
      root = destination_root
      while %w[trunk branches tags].include? name
        root = File.expand_path(File.join(root, ".."))
        name = File.basename(root)
      end
      name
    end

    def after_generate
    end

    # Run the generator script.  Takes an array of unparsed arguments
    # and a hash of parsed arguments, takes the generator as an option
    # or first remaining argument, and invokes the requested command.
    def run
      # Look up generator instance and invoke command on it.
      manifest.replay(self)
      after_generate
    rescue => e
      puts e
      puts "  #{e.backtrace.join("\n  ")}\n" if options[:backtrace]
      raise SystemExit unless options[:no_exit]
    end

    def camelize(term, uppercase_first_letter = true)
      string = term.to_s
      string = string.sub(/^[a-z\d]*/) { $&.capitalize }
      string.gsub(/(?:_|(\/))([a-z\d]*)/i) { "#{$1}#{$2.capitalize}" }.gsub('/', '::')
    end

    def pluralize(word)
      rules = {}
      rules.store(/$/, 's')
      rules.store(/s$/i, 's')
      rules.store(/(ax|test)is$/i, '\1es')
      rules.store(/(octop|vir)us$/i, '\1i')
      rules.store(/(octop|vir)i$/i, '\1i')
      rules.store(/(alias|status)$/i, '\1es')
      rules.store(/(bu)s$/i, '\1ses')
      rules.store(/(buffal|tomat)o$/i, '\1oes')
      rules.store(/([ti])um$/i, '\1a')
      rules.store(/([ti])a$/i, '\1a')
      rules.store(/sis$/i, 'ses')
      rules.store(/(?:([^f])fe|([lr])f)$/i, '\1\2ves')
      rules.store(/(hive)$/i, '\1s')
      rules.store(/([^aeiouy]|qu)y$/i, '\1ies')
      rules.store(/(x|ch|ss|sh)$/i, '\1es')
      rules.store(/(matr|vert|ind)(?:ix|ex)$/i, '\1ices')
      rules.store(/(m|l)ouse$/i, '\1ice')
      rules.store(/(m|l)ice$/i, '\1ice')
      rules.store(/^(ox)$/i, '\1en')
      rules.store(/^(oxen)$/i, '\1')
      rules.store(/(quiz)$/i, '\1zes')
      uncountable = %w(equipment information rice money species series fish sheep jeans)

      result = word.to_s.dup

      if word.empty? || uncountables.any? { |inflection| result =~ /\b#{inflection}\Z/i }
        result
      else
        rules.each { |(rule, replacement)| break if result.gsub!(rule, replacement) }
        result
      end
    end

    protected
      # Convenience method for generator subclasses to record a manifest.
      def record
        Apimaster::Generators::Manifest.new(self) { |m| yield m }
      end

      # Override with your own usage banner.
      def banner
        "Usage: #{$0} #{spec.name} [options]"
      end

      # Read USAGE from file in generator base path.
      def usage_message
        File.read(File.join(spec.path, 'USAGE')) rescue ''
      end
  end

end
