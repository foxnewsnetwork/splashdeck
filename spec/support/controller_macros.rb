require 'factories'
module ControllerMacros
  def login_admin
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:admin]
      @current_user = User.new Factory.next(:user)
      @current_user.set_admin
      raise "GOD FUCKING DAMMIT ERROR in #{__FILE__}" unless @current_user.admin?
      sign_in @current_user
    end # before each
  end

  def login_user
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @current_user = User.create Factory.next(:user)
      # user.confirm! # or set a confirmed_at inside the factory. Only necessary if you are using the confirmable module
      sign_in @current_user
    end # before
  end # login_user
  
  def signed_in? 
  	@request.env["devise.mapping"] = Devise.mappings[:user]
  	user_signed_in?
  end # user_signed_in?
end # controllermacros
