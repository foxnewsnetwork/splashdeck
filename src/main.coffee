desktop = null unless desktop?
$("document").ready ->
	$("div#no-javascript").hide()
	desktop = new DeskModel() unless desktop?
