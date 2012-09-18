module UserHelper
	def filter_anonymous_user
		unless user_signed_in?
			respond_to do |f| 
				f.json { render "shared/fail" }
			end # respond_to
		end # user_signed_in?
	end # filter_anonymous_user
end # UserHelper
