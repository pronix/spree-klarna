module Spree
  class Admin::KlarnaSettingsController < Admin::ResourceController

    # save settings
    def update
      settings = Spree::KlarnaSetting.new
      params[:preferences].each do |k, v|
        settings[k] = v
      end
      flash[:notice] = 'Update successfuly'
      render :edit
    end

  end
end
