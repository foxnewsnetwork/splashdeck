# Globals (I guess)
desktop = new DeskModel()
session = null
$( "document" ).ready -> 
	session = Session.login( "admin@admin.admin", "123456789", run_test_suite )
# test-starter

describe "Desk Model", ->
	describe "sanity test", ->
		it "should not be null", ->
			expect(desktop).to.be.ok()
		# it
		it "should have a proper toolbar", ->
			expect(desktop.toolbar).to.be.ok()
		# it
		it "should have an active paper", ->
			expect(desktop.active_page).to.be.ok()
		# it
	# sanity test
	describe "new pages", ->
		it "should create a new page", (done) ->
			page_data = { title: "My Test Page" }
			desktop.new_page page_data, ->
				flag1 = desktop.active_page.get "title" is "My Test Page"
				flag2 = desktop.active_page.get("id") > 0
				done(flag1 and flag2)
			# new_page
		# it
	# new pages
	describe "integration", ->
		beforeEach (done) ->
			@code = 
				category: "code" ,
				language: "Ruby" ,
				code: "faggots.each do |faggot| faggot.be_gay end"
		# beforeEach
		it "should be tested but I don't know how"
	# integration
# Desk Model
