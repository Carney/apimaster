# encoding: utf-8
#
# Copyright (C) 2011-2012  AdMaster, Inc.
#
# @author: sunxiqiu@admaster.com.cn

module Apimaster

  class NormalError < StandardError
    attr_reader :code
    attr_reader :error
    attr_reader :resource
    attr_reader :field

    # error :missing, :missing_field, :invalid, :already_exists
    def initialize(message = '', code = nil, error = :invalid, resource = nil, field = nil)
      @code = code
      @error = error.to_sym
      @resource = resource
      @field = field
      super(message)
    end
  end

  class MissingError < NormalError
    def initialize(resource = nil)
      super("Resource '#{resource}' does not exist.", 404, :missing, resource)
    end
  end

  class MissingFieldError < NormalError
    def initialize(resource = nil, field = nil)
      super("Required field '#{field}' on a resource '#{resource}' has not been set.", 422, :missing_field, resource, field)
    end
  end

  class InvalidFieldError < NormalError
    def initialize(resource = nil, field = nil)
      super("The formatting of the field '#{field}' on a resource '#{resource}' is invalid.", 422, :invalid_field, resource, field)
    end
  end

  class AlreadyExistsError < NormalError
    def initialize(resource = nil, field = nil)
      super("Another resource '#{resource}' has the same value as this field '#{field}'. ", 409, :already_exists, resource, field)
    end
  end

  class RelationExistsError < NormalError
    def initialize(resource = nil, field = nil)
      super("Our results indicate a positive relationship exists.", 409, :relation_exists, resource, field)
    end
  end

  class RequestError < StandardError
    def initialize(resource = nil, field = nil)
      super("Problems parsing JSON.", 400, :parse_error, resource, field)
    end
  end

  class UnauthorizedError < NormalError
    def initialize(resource = nil, field = nil)
      super("Your authorization token were invalid.", 401, :unauthorized, resource, field)
    end
  end

  class PermissionDeniedError < NormalError
    def initialize(resource = nil, field = nil)
      super("Permission denied to access resource '#{resource}'.", 403, :forbidden, resource, field)
    end
  end

  class OauthError < NormalError
    def initialize(message)
      super(message, 422, :oauth_error)
    end
  end

end
