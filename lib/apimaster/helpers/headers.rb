# encoding: utf-8
#
# Copyright (C) 2011-2012  AdMaster, Inc.

module Apimaster::Helpers
   module Headers

    def header_pagination(pagination)
      path = base_url + request.path_info
      next_link = path + "?" + query_string_modifier(page: pagination.next_page)
      last_link = path + "?" + query_string_modifier(page: pagination.page_count)
      pagination_link = "<#{next_link}>; rel=\"next\", <#{last_link}>; rel=\"last\""
      headers "Link" => pagination_link
    end

    def header_location(path)
      headers "Location" => base_url + path
    end

    def header_link(path, rel)
      headers "Link" => "<#{base_url+path}>; rel=\"#{rel}\""
    end

    private

    def base_url
      Apimaster::Setting.get('app.base_url')
    end
  end
end
