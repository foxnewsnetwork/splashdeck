###
# Exposed Globals:
# desktop, toolbar, session
###

describe "Session Model", ->
	describe "sanity test", ->
		it "should have null admin by default", ->
			expect(Session).to.be.ok()
		# it
	# sanity test
	describe "login", ->
		it "should create a session through login", ->
			expect( session ).to.be.ok()
		# it
		it "should make the toolbar go into admin mode", ->
			expect( toolbar.mode ).to.be.equal( "admin" )
		# it
	# login
# Session Model

