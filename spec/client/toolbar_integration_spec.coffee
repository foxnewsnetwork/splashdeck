toolbar = desktop.toolbar

describe "Toolbar View", ->
	describe "sanity test", ->
		it "should access the toolbar through the desktop global" , ->
			expect(toolbar).to.be.ok()
		# it
	# sanity test
	describe "default behavior", ->
		it "should default to being in admin mode", ->
			expect(toolbar.mode).to.be.equal( "admin" )
		# it
	# defalt behavior
# Toolbar View
