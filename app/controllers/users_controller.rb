class UsersController < ApplicationController
  before_filter :authenticate_user!

  def settings
    officer_signed_in? ? officer_settings : vendor_settings
  end

  def officer_settings
    render "users/officer_settings"
  end

  def vendor_settings
    render "users/vendor_settings"
  end

  def post_settings
    officer_signed_in? ? post_officer_settings : post_vendor_settings
  end

  def post_officer_settings
    current_officer.assign_attributes(officer_params)
    current_officer.notification_preferences = params[:notifications] ? params[:notifications].keys.map { |k| k.to_i } : []
    current_officer.save
    flash[:success] = "Settings successfully updated."
    redirect_to settings_path
  end

  def post_vendor_settings
    current_vendor.assign_attributes(vendor_params)
    current_vendor.notification_preferences = params[:notifications] ? params[:notifications].keys.map { |k| k.to_i } : []
    current_vendor.save
    flash[:success] = "Settings successfully updated."
    redirect_to settings_path
  end

  private
  def officer_params
    params.require(:officer).permit(:name, :title)
  end

  def vendor_params
    params.require(:vendor).permit(:name)
  end
end
