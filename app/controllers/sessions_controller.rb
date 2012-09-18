class SessionsController < Devise::SessionsController
	def create
		resource = warden.authenticate!(auth_options)
		set_flash_message(:notice, :signed_in) if is_navigational_format?
		sign_in(resource_name, resource)
		@user = current_user
		if user_signed_in?
			respond_to { |f| f.json { render "users/show" } }
		else
			respond_to { |f| f.json { render "shared/fail" } }
		end # success
	end # create
end # SessionController
