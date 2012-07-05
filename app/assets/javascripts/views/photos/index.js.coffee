class Rivermier.Views.PhotosIndex extends Backbone.View

	template: JST['photos/index']
	loading: JST['partials/loading']

	tagName: 'section'

	initialize: ->
		@collection.on('reset', @render, this)
		@collection.on('add', @appendNew, this)

	render: ->
		$(@el).html(@template(loading: @loading))
		@collection.each(@append, this)
		@infiniScroll = new Backbone.InfiniScroll(@collection, {includePage: true})
		@layout(this)
		this

	append: (item) ->
		view = new Rivermier.Views.PhotosShow(model: item)
		@$('#photos > .thumbnails').append(view.render().el)

	appendNew: (item) ->
		view = new Rivermier.Views.PhotosShow(model: item)
		views = [view.render().el]
		@$('#photos > .thumbnails').append(view.render().el).isotope('appended', $(view.render().el))
		@layout(this)		

	layout: ->
		container = @$('#photos > .thumbnails')
		container.imagesLoaded ->
			$('#photos > .loading').hide()
			$('.photo-tweet').show()
			$('#loading-gif').show()
			container.isotope(itemSelector: '.tweet')