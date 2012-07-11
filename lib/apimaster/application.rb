# encoding: utf-8
#
# Copyright (C) 2011-2012  AdMaster, Inc.

module Apimaster
  class Application < Sinatra::Base

    # Helpers
    superclass.helpers Sinatra::JSON
    superclass.helpers Apimaster::Helpers::Request
    superclass.helpers Apimaster::Helpers::Headers
    superclass.helpers Apimaster::Helpers::Session

    superclass.configure :development do
      superclass.register Sinatra::Reloader
      superclass.also_reload "./app/{controllers,models,helpers}/**/*.rb"
    end

    superclass.configure do
      superclass.set :root, ::File.expand_path(".")
      superclass.set :json_encoder, :to_json
      superclass.set :show_exceptions, false
    end

    use Apimaster::Controllers::Errors

  end
end
