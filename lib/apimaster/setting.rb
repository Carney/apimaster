# encoding: utf-8
#
# Copyright (C) 2011-2012  AdMaster, Inc.

module Apimaster

  module Setting
    class << self
      @@hashes = {}

      # environments: development, test and production.
      ENVIRONMENTS = %w[test production development]

      attr_accessor :environment

      def set(key, value)
        @@hashes[key] = value
      end

      def get(key, default = nil)
        current = @@hashes
        key.split('.').each do |k|
          if current and current.is_a?(Hash)
            current = current.has_key?(k) ? current[k] : default
          end
        end
        current
      end

      # Loads the configuration from the YAML files whose +paths+ are passed as
      # arguments, filtering the settings for the current environment.  Note that
      # these +paths+ can actually be globs.
      def load_file(*paths)
        paths.each do |pattern|
          Dir.glob(pattern) do |file|
            yaml = config_for_env(YAML.load_file(file)) || {}
            yaml.each_pair do |key, value|
              for_env = config_for_env(value)
              set key, for_env unless value and for_env.nil? and respond_to? key
            end
          end
        end
      end

      private

      # Given a +hash+ with some application configuration it returns the
      # settings applicable to the current environment.  Note that this can only
      # be done when all the keys of +hash+ are environment names included in the
      # +environments+ setting (which is an Array of Strings).  Also, the
      # returned config is a indifferently accessible Hash, which means that you
      # can get its values using Strings or Symbols as keys.
      def config_for_env(hash)
        if hash.respond_to? :keys and hash.keys.all? { |k| ENVIRONMENTS.include? k.to_s }
          hash = hash[environment.to_s] || hash[environment.to_sym]
        end

        if hash.respond_to? :to_hash
          indifferent_hash = Hash.new {|hash,key| hash[key.to_s] if Symbol === key }
          indifferent_hash.merge hash.to_hash
        else
          hash
        end
      end

    end
  end
end
