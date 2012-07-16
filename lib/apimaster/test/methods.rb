# encoding: utf-8
#
# Copyright (C) 2011-2012  AdMaster, Inc.

module Apimaster::Test
  module Methods

    def body
      last_response.body
    end

    def patch(uri, params = {}, env = {}, &block)
      env = env.merge(:method => "PATCH", :params => params)
      request(uri, env, &block)
    end

  end
end
