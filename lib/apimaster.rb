# encoding: utf-8
#
# Copyright (C) 2011-2012  AdMaster, Inc.

module Apimaster end
module Apimaster::Helpers end
module Apimaster::Controllers end
module Apimaster::Models end
module Apimaster::Mocks end
module Apimaster::Test end

require_relative './apimaster/setting'
require_relative './apimaster/error'
require_relative './apimaster/mapper'

require_relative './apimaster/helpers/headers'
require_relative './apimaster/helpers/request'
require_relative './apimaster/helpers/session'

require_relative './apimaster/models/user'

require_relative './apimaster/controllers/errors'
require_relative './apimaster/application'

