class HomeController < ApplicationController
  skip_before_action :authenticate_request!

  def index
    root_url = "https://#{Rails.settings.domains[:app]}"

    link_self = { self: "#{root_url}/" }
    link_resources = {
      addresses: "#{root_url}/addresses",
      properties: "#{root_url}/properties",
      users: "#{root_url}/users",
    }

    if current_user.present?
      links = link_self.merge(link_resources)
    else
      links = link_self
    end

    render json: {
      meta: {
        name: 'House Ninja API',
      },
      links: links
    }, status: 200
  end
end
