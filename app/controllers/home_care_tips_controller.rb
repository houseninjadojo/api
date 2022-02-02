class HomeCareTipsController < ApplicationController
  def index
    home_care_tips = HomeCareTipResource.all(params)
    respond_with(home_care_tips)
  end

  def show
    home_care_tip = HomeCareTipResource.find(params)
    respond_with(home_care_tip)
  end

  def create
    home_care_tip = HomeCareTipResource.build(params)

    if home_care_tip.save
      render jsonapi: home_care_tip, status: 201
    else
      render jsonapi_errors: home_care_tip
    end
  end

  def update
    home_care_tip = HomeCareTipResource.find(params)

    if home_care_tip.update_attributes
      render jsonapi: home_care_tip
    else
      render jsonapi_errors: home_care_tip
    end
  end

  def destroy
    home_care_tip = HomeCareTipResource.find(params)

    if home_care_tip.destroy
      render jsonapi: { meta: {} }, status: 200
    else
      render jsonapi_errors: home_care_tip
    end
  end
end
