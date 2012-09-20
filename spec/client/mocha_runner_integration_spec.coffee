mocha.setup("bdd")
run_test_suite = ->
	mocha.globals( ['desktop'] ).run()
# run_test_suite
