# encoding: utf-8
#
# Copyright (C) 2011-2012  AdMaster, Inc.
#
# @author: sunxiqiu@admaster.com.cn

module Apimaster::Helpers
  module Request

    # Convert a hash to a querystring for form population
    def hash_to_query_string(hash)
      hash.collect {|k,v| "#{k}=#{v}"}.join("&")
    end

    def query_string_modifier(hash)
      hash_to_query_string(CGI::parse(request.query_string).merge(hash))
    end

    def posts
      @posts ||= to_symbol_key_hash(request_json)
    end

    private

    def to_symbol_key_hash(hash)
      return hash unless hash.is_a? Hash
      result = {}
      hash.map do |key, val|
        val = to_symbol_key_hash(val) if val.is_a? Hash
        result[key.to_sym] = val
      end
      result
    end

    def request_json
      begin
        @request_json ||= parse_json
      rescue JSON::ParserError => e
        raise Apimaster::RequestError, "Problems parsing JSON"
      end
    end

    def parse_json
      body_data = request.body.read
      body_data.empty? ? {} : JSON.parse(body_data)
    end

  end
end
