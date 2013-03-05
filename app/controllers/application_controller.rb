class ApplicationController < ActionController::Base
  protect_from_forgery
  def test
    match_remainder
  end

  def session_exists
    if !session[:current_admin_id]
      redirect_to "/admin"
    end
  end

  private
  def current_admin
    @_current_admin ||= session[:current_admin_id] &&
      Admin.find_by_id(session[:current_admin_id])
  end
end
