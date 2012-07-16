
module Apimaster::Generators
  class ControllerGenerator < Create
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
        m.template "app/controllers/examples_controller.rb.erb", "app/controllers/#{pluralize name}_controller.rb"
        m.template "test/functional/examples_controller_test.rb.erb", "test/functional/#{pluralize name}_controller_test.rb"
      end
    end

    private
      def banner
        <<-EOS
  Creates an Apimaster controller.

  USAGE: apimaster controller your_controller_name"

  NOTE: Without `_controller` suffix

  EOS
      end

  end
end
