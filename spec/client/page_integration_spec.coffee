# Globals
page = desktop.active_page

describe "Page Model", ->
	describe "Sanity Test", ->
		it "should not be null", ->
			expect(page).to.be.ok()
		# it
	# sanity test
	describe "integration", ->
		beforeEach (done) ->
			@code =
				category : "code" ,
				content : "Hello World" ,
				metadata : "mocha"
			@text =
				category : "text" ,
				content : "Test Blog Entry" ,
				metadata : "Alice McTest" 
			@image =
				category : "image" ,
				content : "http://i299.photobucket.com/albums/mm281/foxnewsnetwork/logo.png" ,
				metadata : "Test caption"
			done()
		# beforeEach
		it "should make a code block", (done) ->
			sticky = page.new_sticky @code, ->
				expect( sticky.page_id ).to.equal page.id
				done() 			
			# sticky
		# it
		it "should make a text block", (done) ->
			sticky = page.new_sticky @text, ->
				expect( sticky.page_id ).to.equal page.id
				done()
		# it
		it "should make a text block", (done) ->
			sticky = page.new_sticky @image, ->
				expect( sticky.page_id ).to.equal page.id
				done()
		# it
	# integration
# Page model
