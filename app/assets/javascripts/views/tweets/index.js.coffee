class Rivermier.Views.TweetsIndex extends Backbone.View

	template: JST['tweets/index']
	loading: JST['partials/loading']

	tagName: 'section'

	initialize: ->
		@collection.on('reset', @render, this)		

	render: ->
		$(@el).html(@template(loading: @loading))
		@collection.each(@append, this)		
		@layout(this)		
		this

	append: (item) ->
		view = new Rivermier.Views.TweetsShow(model: item)
		@$('#tweets > .thumbnails').append(view.render().el)

	layout: ->
		container = @$('#tweets > .thumbnails')
		container.imagesLoaded ->
			$('#tweets > .loading').hide()
			$('#tweets > .thumbnails').show()
			container.isotope(itemSelector : '.tweet', columnWidth: 320)