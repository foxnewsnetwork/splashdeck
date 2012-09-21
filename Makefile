SRC=src
TSRC=spec/client
CLIB=tests/client
JC=coffee

.PHONY: build client production clear_test_js migrate_application

production: clear_test_js migrate_application
	cake build


clear_test_js: 
	mv vendor/assets/javascripts/mocha.js vendor/assets/unused/ &&\
	mv vendor/assets/javascripts/chai.js vendor/assets/unused/ &&\
	mv vendor/assets/javascripts/expect.js vendor/assets/unused/ &&\
	mv app/assets/javascripts/application.js vendor/assets/unused/application.test.js &&\
	mv app/assets/stylesheets/application.css vendor/assets/unused/application.test.css 
	
migrate_application:
	cp  -f vendor/assets/unused/application.production.js app/assets/javascripts/application.js &&\
	cp -f vendor/assets/unused/application.production.css app/assets/stylesheets/application.css 

client:
	@coffee \
		-b \
		-o $(CLIB) \
		-c $(TSRC)

build:
	@coffee \
		-b \
		-o faggot/ \
		-c src/ \
		
$(CLIB)/%.js: $(SRC)/%.coffee
	$(JC) --bare --compile $< --output $@
	
