
module Apimaster::Generators
  class AppGenerator < Create
    attr_reader :app_name, :module_name

    def initialize(runtime_args, runtime_options = {})
      super
      #@destination_root = args.shift
      #@app_name     = File.basename(File.expand_path(@destination_root))
      @app_name     = args[0]
      raise 'Undefined app name.' unless @app_name
      @module_name  = camelize(app_name)
      extract_options
    end

    def manifest
      record do |m|
        # Ensure appropriate folder(s) exists
        m.directory ''
        BASEDIRS.each { |path| m.directory path }
        m.directory "lib/#{app_name}"

        # config
        m.template "config/boot.rb.erb", "config/boot.rb"
        m.template "config/patches.rb.erb", "config/patches.rb"
        m.template "config/initializer.rb.erb", "config/initializer.rb"
        m.template "config/application.rb.erb", "config/application.rb"
        m.template "config/settings/mongoid.yml.erb", "config/settings/mongoid.yml"
        m.template "config/settings/app.yml.erb", "config/settings/app.yml"
        m.template "config/settings/oauth.yml.erb", "config/settings/oauth.yml"

        # Create stubs
        m.template "config.ru.erb", "config.ru"
        m.template "gitignore", ".gitignore"
        m.template "lib/module.rb.erb", "lib/#{app_name}.rb"
        m.template "app/tasks/test.rake.erb", "app/tasks/test.rake"
        m.template "app/tasks/stat.rake.erb", "app/tasks/stat.rake"
        m.template "app/controllers/index_controller.rb.erb", "app/controllers/index_controller.rb"
        m.template "app/controllers/befores_controller.rb.erb", "app/controllers/befores_controller.rb"

        # Test stubs
        m.template "test/test_helper.rb.erb", "test/test_helper.rb"

        %w(LICENSE Rakefile README.md Gemfile TODO test.watchr).each do |file|
          m.template file, file
        end
      end
    end

    protected
      def banner
        <<-EOS
  Creates a Apimaster scaffold.

  USAGE: apimaster new your_app_name"
  EOS
      end

      def add_options!(opts)
        opts.separator ''
        opts.separator 'Options:'
        # For each option below, place the default
        # at the top of the file next to "default_options"
        # opts.on("-a", "--author=\"Your Name\"", String,
        #         "Some comment about this option",
        #         "Default: none") { |x| options[:author] = x }
        opts.on("-v", "--version", "Show the #{File.basename($0)} version number and quit.")
      end

      def extract_options
        # for each option, extract it into a local variable (and create an "attr_reader :author" at the top)
        # Templates can access these value via the attr_reader-generated methods, but not the
        # raw instance variable value.
        # @author = options[:author]
      end

      # Installation skeleton.  Intermediate directories are automatically
      # created so don't sweat their absence here.
      BASEDIRS = %w(
        app
        app/controllers
        app/views
        app/models
        app/helpers
        app/tasks
        bin
        config
        config/settings
        config/locales
        doc
        lib
        log
        test
        test/unit
        test/functional
        test/factory
        test/mock
        tmp
        public
      )
  end
end
