class ApplicationController < ActionController::Base
  protect_from_forgery
  def test
    match_remainder
  end
end
