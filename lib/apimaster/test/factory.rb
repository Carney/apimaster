# encoding: utf-8
#
# Copyright (C) 2011-2012  AdMaster, Inc.

module Apimaster::Test

  class Factory
    def self.define name, value = nil
      self.attrs[name] = value
    end

    def self.attrs
      @attrs ||= {}
    end

    def self.attr key
      @attrs ||= {}
      @attrs[key]
    end

    def self.register name
      @klass = name
    end

    def self.post data = {}
      raise "Please register class first." unless @klass
      @klass.post attrs.merge(data)
    end

  end
end
