class SessionsController < ApplicationController
  def new
  end

  def create
    if params[:session] && @user = User.authenticate(params[:session][:email], params[:session][:password])
      session[:user_id] = @user.id
      redirect_to root_path, notice: "Welcome, #{@user.email}"
    else
      redirect_to new_session_path, error: "Sorry, your email or password is incorrect"
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: "Bye!"
  end

end
