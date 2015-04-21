class TwoFactorAuthenticationController < ApplicationController
  before_action :require_current_user

  def setup
  end

  # This registers a User and starts immediate verification
  # A nice fat method ;)
  def register
    response = Authy::API.register_user(
      email: current_user.email,
      cellphone: setup_params[:cellphone].to_i,
      country_code: setup_params[:country_code].to_i
    )
    if response.ok?
      # Don't persist it yet - it isn't verified
      session[:pending_authy_id] = response.id

      # Request immediate verification
      Authy::API.request_sms(id: session[:pending_authy_id])

      flash[:notice] = "To finish setting up 2FA, enter your 2FA code"
      redirect_to action: :verify
    else
      flash[:error] = "Sorry: #{response.errors["message"]}"
      redirect_to action: :setup
    end
  end

  def verify
  end

  private
    def setup_params
      params.require(:setup).permit(:country_code, :cellphone)
    end

end
