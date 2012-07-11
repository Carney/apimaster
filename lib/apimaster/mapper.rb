# encoding: utf-8
#
# Copyright (C) 2011-2012  AdMaster, Inc.

module Apimaster
  class Mapper
    # include Mongoid::Document

    def post hash
      from_hash hash
      save
    end

    def put hash
      from_hash hash
      save
    end

    def patch hash
      from_hash hash
      save
    end

    def to_hash accessor = :all
      record = {}
      fields = self.class.find_attrs_in_options(:accessor, accessor)
      fields.each do |field|
        if self.respond_to?(field)
          record[field] = self.send(field)
        else
          raise "Dataset #{self.class} has no method with the name of #{field}"
        end
      end
      record
    end

    def from_hash(hash, method = :all)
      data = {}
      attrs = [:required, :optional]

      attrs.each do |type|
        fields = self.class.get_attrs(type, method)
        fields.each do |field|
          if hash.has_key?(field)
            data[field] = hash[field]
          elsif hash.has_key?(field.to_s)
            data[field] = hash[field.to_s]
          else
            raise Apimaster::MissingFieldError.new(self.class.get_class_name, field) if type == :required
          end
        end
      end

      data.each do |key, val|
        respond_setter key, val
      end
    end

    def respond_setter key, val
      name = (key.to_s + '=').to_sym
      raise "#{self.class} lost of #{name}" unless self.respond_to?(name)
      self.send name, val
    end

    class << self

      OPTION_TYPES = [:accessor, :required, :optional]

      @attr_options ||= {}

      # attr_options :url, accessor: [:get, :list]
      def attr_options name, options = {}
        @attr_options[name] = options
      end

      # [:url, :name]
      def find_attrs_in_options type, option = :all
        raise "Unknown attribute options type: #{type}" unless OPTION_TYPES.include? type
        @attr_options.select do |name, options|
          type_options = options.is_a?(Hash) and options.key?(type) ? options[type] : nil
          type_options.is_a?(Array) and (type_options.include?(option) or type_options.include(:all))
        end.keys
      end
    end
  end
end
