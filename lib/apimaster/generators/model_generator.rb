
module Apimaster::Generators
  class ModelGenerator < Create
    attr_reader :app_name, :module_name, :name

    def initialize(runtime_args, runtime_options = {})
      super
      @app_name     = File.basename(File.expand_path('./'))
      @module_name  = camelize(app_name)
      @name     = args[0]
      raise 'Undefined app name.' unless @app_name
    end

    def manifest
      record do |m|
        m.template "app/models/example.rb.erb", "app/models/#{name}.rb"
        m.template "test/unit/example_test.rb.erb", "test/unit/#{name}_test.rb"
        m.template "test/factory/example_factory.rb.erb", "test/factory/#{name}_factory.rb"
      end
    end

    private
      def banner
        <<-EOS
  Creates an Apimaster model.

  USAGE: apimaster model your_model_name"

  EOS
      end

  end
end
