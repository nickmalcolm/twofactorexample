class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  add_flash_types :error

  def current_user
    User.find_by(id: session[:user_id])
  end
  helper_method :current_user

  def require_current_user
    if current_user
      return true
    else
      respond_to do |format|
        format.html {
          redirect_to new_session_path, error: "Please sign in."
        }
        format.json {
          head :unauthorized
        }
      end
      return false
    end
  end

end
