window.Rivermier =
	Models: {}
	Collections: {}
	Views: {}
	Routers: {}
	init: ->
		new Rivermier.Routers.Home  	
		Backbone.history.start(pushState: true)

$(document).ready ->
	Rivermier.init()