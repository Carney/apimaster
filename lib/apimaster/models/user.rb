# encoding: utf-8
#
# Copyright (C) 2011-2012  AdMaster, Inc.

require 'net/http'

module Apimaster::Models
  class User

    attr_accessor :id
    attr_accessor :email
    attr_accessor :username

    def initialize hash
      hash.each do |key, val|
        method_name = (key.to_s+'=').to_sym
        self.send(method_name, val) if respond_to?(method_name)
      end
    end

    def self.auth access_token
      oauth_domain = Apimaster::Setting.get('oauth.oauth_domain')
      json = Net::HTTP.get(oauth_domain, "/user?access_token=#{access_token}", 80)
      user_hash = JSON.parse(json)

      return nil unless user_hash.is_a?(Hash)
      raise Apimaster::OauthError.new(user_hash["message"]) if user_hash.key?("message")

      self.new user_hash
    end

  end
end
