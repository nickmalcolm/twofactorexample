class SessionsController < ApplicationController
  before_action :require_current_user, only: [:destroy]
  before_action :require_pending_user, only: [:two_factor_required, :two_factor_verification]
  def new
  end

  def create
    if params[:session] && @user = User.authenticate(params[:session][:email], params[:session][:password])
      if @user.authy_id
        Authy::API.request_sms(id: @user.authy_id)
        session[:pending_user_id] = @user.id
        flash[:notice] = "Please enter your 2FA code"
        redirect_to action: :two_factor_required
      else
        session[:user_id] = @user.id
        redirect_to root_path, notice: "Welcome, #{@user.email}"
      end
    else
      redirect_to new_session_path, error: "Sorry, your email or password is incorrect"
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: "Bye!"
  end

  ### Two Factor Authentication

  def two_factor_required
  end

  def two_factor_verification
    response = Authy::API.verify(
      id: @pending_user.authy_id,
      token: verification_params[:token],
      force: true
    )
    if response.ok?
      session[:pending_user_id] = nil
      session[:user_id] = @pending_user.id
      redirect_to root_path
    else
      session[:pending_user_id] = nil
      redirect_to new_session_path, error: "That 2FA code was invalid"
    end
  end

  private

    def require_pending_user
      @pending_user = User.find_by(id: session[:pending_user_id])
      unless @pending_user && @pending_user.authy_id
        redirect_to new_session_path, error: "Please sign in"
      end
    end

    def verification_params
      params.require(:verification).permit(:token)
    end

end
