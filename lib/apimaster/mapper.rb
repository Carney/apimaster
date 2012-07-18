# encoding: utf-8
#
# Copyright (C) 2011-2012  AdMaster, Inc.

module Apimaster
  class Mapper
    #include ::Mongoid::Document

    def post hash
      save_with_hash hash, :post
    end

    def put hash
      save_with_hash hash, :put
    end

    def patch hash
      save_with_hash hash, :patch
    end

    def save_with_hash hash, method
      from_hash hash, method
      if valid?
        save
      else
        raise InvalidFieldError.new(class_name, errors.keys.first)
      end
      self
    end

    def from_hash(hash, method = :all)
      data = {}
      attrs = [:required, :optional]

      attrs.each do |type|
        fields = self.class.find_attrs_in_options(type, method)
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

    def class_name
      @class_name ||= self.class.to_s.split("::").last
    end

    class << self

      OPTION_TYPES = [:accessor, :required, :optional]

      # attr_options :url, accessor: [:get, :list]
      def attr_options name, options = {}
        @attr_options ||= {}
        @attr_options[name] = options
      end

      # [:url, :name]
      def find_attrs_in_options type, option = :all
        raise "Unknown attribute options type: #{type}" unless OPTION_TYPES.include? type
        @attr_options ||= {}
        @attr_options.select do |name, options|
          type_options = (options.is_a?(Hash) and options.key?(type)) ? options[type] : nil
          type_options.is_a?(Array) and (type_options.include?(option) or type_options.include?(:all))
        end.keys
      end

      def post hash
        self.new.post hash
      end

      def to_hashes accessor = :all
        result = []
        self.each do |val|
          result << val.to_hash(accessor)
        end
        result
      end

    end
  end
end
