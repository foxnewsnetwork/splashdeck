SRC=src
TSRC=spec/client
CLIB=tests/client
JC=coffee

.PHONY: build client

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
	
