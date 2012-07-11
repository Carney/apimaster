# encoding: utf-8
#
# Copyright (C) 2011-2012  AdMaster, Inc.

module Apimaster end
module Apimaster::Helpers end
module Apimaster::Controllers end
module Apimaster::Models end

require_relative './apimaster/setting'
require_relative './apimaster/error'
require_relative './apimaster/mapper'

require_relative './apimaster/helpers/headers.rb'
require_relative './apimaster/helpers/request.rb'
require_relative './apimaster/helpers/session.rb'

require_relative './apimaster/models/user.rb'
require_relative './apimaster/models/user_mock.rb'

require_relative './apimaster/controllers/errors.rb'
require_relative './apimaster/application'
