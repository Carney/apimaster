# encoding: utf-8
#
# Copyright (C) 2011-2012  AdMaster, Inc.
#
# @author: sunxiqiu@admaster.com.cn

module Apimaster::Helpers
  module Session

    # Check logged in user is the owner
    def is_owner? owner_id
      !!current_user && current_user.id.to_i == owner_id.to_i
    end

    def authorize
      raise Apimaster::UnauthorizedError.new :user unless current_user
    end

    # Return current_user record if logged in
    def current_user
      @current_user ||= auth_user
    end

    def auth_user
      @access_token ||= params[:access_token] or header_token
      user_model.auth @access_token
    end

    def user_model
      @user_model ||= Apimaster::Models::User
    end

    def header_token
      keys = %w{HTTP_AUTHORIZATION X-HTTP_AUTHORIZATION X_HTTP_AUTHORIZATION}
      authorization ||= keys.inject(nil) { |auth, key| auth || request.env[key] }
      authorization.split[1] if authorization and authorization[/^token/i]
    end

  end
end
