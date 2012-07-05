$(document).ready(function() {
 
	/* Navigation Events */
	
	$('a[href="#/live-stream"]').click(function(){
		switchNavigationStyles('#today', '#live-stream', '#/live-stream');
 		_gaq.push(['_trackPageview', '/']);		
		return false;
	});	
	
	$('a[href="#/today"]').click(function(){
		switchNavigationStyles('#live-stream', '#today', '#/today');
		if($("#today > .sub-contents").length == 0){
			$('#today').load('/today', function(){
				processTweetCollection("#today");
			});			
		}
 		_gaq.push(['_trackPageview', '/today']);
		return false;
	});
			
	/* Today Events */
		
	$('#today-photos-button').live('click', function(){
		if ($('#today-photos > #photos-contents').length == 0) {
			$('#today-photos').load('/today-photos', function(){
				processTweetCollection("#today-photos");;
			});
		}
 		_gaq.push(['_trackPageview', '/today-photos']);		
		return false;
	});
	
 	$('#today-videos-button').live('click', function(){
		if ($('#today-videos > #videos-contents').length == 0) {
			$('#today-videos').load('/today-videos', function(){
				processTweetCollection("#today-videos");
			});
		}
 		_gaq.push(['_trackPageview', '/today-videos']);		
		return false;
	}) 		
	
	$('#today-links-button').live('click', function(){
		if ($('#today-links > #links-contents').length == 0) {
			$('#today-links').load('/today-links', function(){
				$('#today-links').find('.link-headline > a').each(function() {
					if (isThaana($(this).attr("href"))) {
						$(this).closest(".link-box").addClass('thaana');
						$(this).closest(".link-box").find('.link-photo').attr('style','float:right');
					}
				});
				linkifyTwitterUsernames();
			});
		}
 		_gaq.push(['_trackPageview', '/today-links']);		
		return false;
	});
		
	$('#today-topics-button').live('click', function(){
		if ($('#today-topics > #topics-contents').length == 0) {
			$('#today-topics').load('/today-topics', function(){
				processTweetCollection("#today-topics");
			});
		}
 		_gaq.push(['_trackPageview', '/today-topics']);		
		return false;
	});
	
	$('#load-more-today-button').live('click', function(){     
		$('#load-more-today-button').hide();		
		$('#topics-contents > .tweets').append('<div class="loading"><div>Loading tweets...</div><img src="/assets/img/loading.gif" /></div>');		
		var offset = $('#load-more-today-button').attr("offset");
		var topic = $('#load-more-today-button').attr("topic");
		url = '/today-topics?topic=' + topic + '&offset=' + offset
		$.get(url, function(data) {
			$('#topics-contents > .tweets > .loading').remove();
			$('#topics-contents > .tweets').append(data);
			processTweetCollection("#today-topics");			
		});
		return false;
	});	
	
	$('.trend-button').live('click', function(){
		$('#topics-contents > .tweets').empty();		
		$('#topics-contents > .tweets').append('<div class="loading"><div>Loading tweets...</div><img src="/assets/img/loading.gif" /></div>');
		topic = $(this).attr("trend");
		offset = 0;
		url = '/today-topics?topic=' + topic + '&offset=' + offset
		$.get(url, function(data) {
			$('#topics-contents > .tweets').empty();
			$('#topics-contents > .tweets').append(data);
			processTweetCollection("#today-topics");			
		});
 		_gaq.push(['_trackEvent', '/today-topics', topic]);
		return false;
	});	
				
	$('#today-people-button').live('click', function(){
		if ($('#today-people > #people-contents').length == 0) {
			$('#today-people').load('/today-people', function(){
				linkifyTwitterUsernames();		
			});
		}
 		_gaq.push(['_trackPageview', '/today-people']);		
		return false;
	});
			
	/* Live Stream Events */
	
	$('#trend-makers-button').click(function(){
		$(".trend-box").show();
 		_gaq.push(['_trackPageview', '/']);		
	});	

	$('#popular-tweets-button').click(function(){
		if ($('#popular-tweets > .tweets').length == 0) {			
			$('#popular-tweets').load('/retweets', function(){				
				processTweetCollection('#popular-tweets > .tweets');
			});
		  jc.subscribe("retweets", function(data){
				publishTweet(jQuery.parseJSON(data), true);
		  });			
		}
		$(".trend-box").hide();
 		_gaq.push(['_trackPageview', '/retweets']);		
	});
	
	$('#media-button').click(function(){
		if ($('#media > .tweets').length == 0) {			
			$('#media').load('/photos', function(){
				processTweetCollection('#media > .tweets');
			});
		  jc.subscribe("photos", function(data){
				publishPhoto(jQuery.parseJSON(data));
		  });			
		}
		$(".trend-box").hide();		
 		_gaq.push(['_trackPageview', '/photos']);		
	});
	   
	$('#videos-button').click(function(){
		if ($('#videos > .tweets').length == 0) {			
			$('#videos').load('/videos', function(){
				processTweetCollection('#videos > .tweets');
			});
		  jc.subscribe("videos", function(data){
				publishVideo(jQuery.parseJSON(data));
		  });			
		}
		$(".trend-box").hide();		
 		_gaq.push(['_trackPageview', '/videos']);		
	});
	
	$('#trends > a').live("click", function(){
		var tag = $(this).text().toLowerCase().replace(/\#/, "");		
		if ($.rivermier.first == true){
			$("#trends > a").each(function(){           
				var t = $(this).text().toLowerCase().replace(/\#/, "");
				if (t != tag){
					$(this).css("background-color", "#ddd");
					$(this).attr("enabled", "false");
					$.rivermier.hide_tags.push(t);
				}						
			});
			$("#trend-makers > .tweets").find("div[tags]").hide();
			$("#trend-makers > .tweets").find("div[tags*='" + tag + "']").show();
			$.rivermier.first = false;
		}
		else {			
			if ($(this).attr("enabled") == "true"){
				$(this).css("background-color", "#ddd");
				$(this).attr("enabled", "false");
				$.rivermier.hide_tags.push(tag);
				$("#trend-makers > .tweets").find("div[tags*='" + tag + "']").hide();
			}
			else {
				$(this).css("background-color", "");
				$(this).attr("enabled", "true");		
				$.rivermier.hide_tags.remove(tag);
				$("#trend-makers > .tweets").find("div[tags*='" + tag + "']").show();
			}			
		}
 		_gaq.push(['_trackPageview', '/', tag]);
		return false;		
	});	
	
	/* Juggernaut Events */
		
	function deleteTweet(data){
		$(".tweet_" + data.tweet_id).next(".entity").remove();			
		$(".tweet_" + data.tweet_id).remove();
	}
	
	function updateTrends(trends) {		
		$.each(trends.trends, function(index, value){
			$.rivermier.tags.push(value.replace(/\#/, ""));
		});
		$.rivermier.tags = $.rivermier.tags.unique().sort();
		var new_contents = ""		
		$.each($.rivermier.tags, function(index, value){
			new_contents = new_contents + '<a href="#" enabled="true">' + value +'</a> '
		});
		$('li#trends').replaceWith('<li id="trends" class="topics">' + new_contents + '</li>');
		$('.trend-updated-at').replaceWith('<span class="trend-updated-at">( <span class="trend-time" title="' + trends.time + '"></span> ago )</span>');
		$('.trend-time').timeago();		
	}	
	
	function publishTweet(tweet, retweet) {
		
		if (retweet == true) {
			var selector = "#popular-tweets > .tweets";
		}
		else {
			var selector = "#trend-makers > .tweets";		
		}
		prependTweet(tweet, selector);
		var keep_hidden = false;
		$.each(tweet.tags, function(index, value){
			if ($.inArray(value, $.rivermier.hide_tags) > -1){
				keep_hidden = true;
			}
		});
		processTweet(selector, '.' + tweet.tweet_id, tweet.text, keep_hidden);
		return false;		
	}
	
	function publishPhoto(tweet) {
		$($.el.div({'class':'hide row-fluid entity borderless high media_' + tweet.media_id},
			$.el.div({'class':'span12 crop'},
				$.el.a({'href':tweet.url, 'target':'_blank'},
					$.el.img({'src':tweet.media_url})
				)
			)
		)).prependTo("#media > .tweets");
		prependTweet(tweet, "#media > .tweets");				
		processTweet("#media > .tweets", '.tweet_media_' + tweet.tweet_id, tweet.text);
		return false;				
	}
	
	function publishVideo(tweet) {
		$($.el.div({'class':'hide row-fluid entity borderless high video_' + tweet.media_id},
			$.el.div({'class':'span12'},
				$.el.iframe({'type':'text/html', 'width':'550', 'height':'335', 'src':'http://www.youtube.com/embed/' + tweet.media_id + '?autoplay=0&wmode=opaque&origin=http://rivermier.com', 'frameborder':'0'})
			)
		)).prependTo("#videos > .tweets");
		prependTweet(tweet, "#videos > .tweets"); 	
		processTweet("#videos > .tweets", '.tweet_video_' + tweet.tweet_id, tweet.text);
		return false;		
	}
	
	function prependTweet(tweet, selector) {
		$($.el.div({'class':'hide row-fluid borderless tweet tweet_' + tweet.tweet_id},
			$.el.div({'class':'span1 profile_picture'},
				$.el.img({'src':tweet.profile_image_url})
			),
			$.el.div({'class':'span10 relative'},
				$.el.strong($.el.a({'href':'https://twitter.com/' + tweet.screen_name, 'target':'_blank', 'title':'@' + tweet.screen_name})),
				$.el.small({'class':'username'},'@' + tweet.screen_name),
				$.el.span({'class':'time', 'title':tweet.created_at}),
				$.el.div({'class':'hide icons'},
					$.el.span({'class':'reply'}, 
						$.el.span({'class':'reply-icon twitter-icon'}),
						$.el.a({'href':'https://twitter.com/intent/tweet?in_reply_to=' + tweet.tweet_id}, "Reply")
					),
					$.el.span({'class':'retweet'}, 
						$.el.span({'class':'retweet-icon twitter-icon'}),
						$.el.a({'href':'https://twitter.com/intent/retweet?in_reply_to=' + tweet.tweet_id}, "Retweet")
					),
					$.el.span({'class':'favorite'}, 
						$.el.span({'class':'favorite-icon twitter-icon'}),
						$.el.a({'href':'https://twitter.com/intent/favorite?in_reply_to=' + tweet.tweet_id}, "Favorite")
					),
					$.el.span(" . "),
					$.el.span(
						$.el.a({'href':'https://twitter.com/' + tweet.screen_name + '/status/' + tweet.tweet_id, 'target':'_blank'}, "Open")
					)
				),
				$.el.p({'class':'tweet-text ' + tweet.tweet_id})
			)
		)).prependTo(selector)
	}	
		
	/ * Site init */
	
	$('.tweet-text').each(function() {
		var text = $(this).find(".original-text").text();
		urlMaker(this, text);
	});

	$('.trend-time').timeago();	
	$('.time').timeago();	
	
	linkifyTwitterUsernames();
	
	$.rivermier = {};
	$.rivermier.first = true;
	$.rivermier.hide_tags = new Array();
	$.rivermier.tags = new Array();
	$.rivermier.tags = $("#trends").attr("tags").split(" ");
	
	
	/ * Juggernaut */	

	var jc = new Juggernaut({ host: "stream.rivermier.com", port: 80 });

  jc.subscribe("tweets", function(data){
		publishTweet(jQuery.parseJSON(data), false);
  });

  jc.subscribe("trends", function(data){
		updateTrends(jQuery.parseJSON(data));
  });
     
  jc.subscribe("deletes", function(data){
		deleteTweet(jQuery.parseJSON(data));
  });

  jc.subscribe("test", function(data){
		updateTrends(jQuery.parseJSON(data));
  });

	/ * Site methods */
	
	$(".tweet").live("mouseenter", function(){ 
		$(this).find(".time").hide();
		$(this).find(".icons").show();
	});	
	
	$(".tweet").live("mouseleave", function(){
		$(this).find(".icons").hide();
		$(this).find(".time").show();
	});
	
	$(".tweet").live("click", function(){
		$(this).find(".icons").toggle();
		$(this).find(".time").toggle();
	});	
		
	function putLoadDiv(selector){
				
		var count = 1;		
		var title_count = 1;		
				
		var button_element = "#" + $(selector).parent().attr("id") + "-button";
		var link_text = $(button_element).text().match(/\d*(\D+)/)[1];
		 	
		if ($(button_element + " > .badge").text().length != 0) {
			var count = count + parseInt($(button_element + " > .badge").text());
		}
			
		if ($('title').text().match(/\((\w+)\)/)) {
			var title_count = title_count + parseInt($('title').text().match(/\((\w+)\)/)[1]);
		}
		
		$('title').text("(" + title_count + ") Rivermier | Dhivehi Tweets and Trends");
		$('#live-stream-button').html("<span class='badge badge-info'>" + title_count + "</span>Live Stream");
		
		$(button_element).html("<span class='badge badge-info'>" + count + "</span>" + link_text);

		if ($(selector + " > .load-more").length == 0){
			$(selector).prepend('<div class="load-more load-button well">Show New Tweets</div>');
		}

		$(selector + ' > .load-more').bind('click', function(){
			var grand_total = 0						
			$(this).remove();
			$(selector + ' > .hide').show();
			$(button_element + " > .badge").remove();
			$('.live-stream-nav').find('li > a > .badge').each(function(){
				$(this).text();
				grand_total = grand_total +  parseInt($(this).text());
			});
			if (grand_total > 0){
				$('title').text("(" + grand_total + ") Rivermier | Dhivehi Tweets and Trends");
				$('#live-stream-button').html("<span class='badge badge-info'>" + grand_total + "</span>Live Stream");				
			}
			else {
				$('title').text("Rivermier | Dhivehi Tweets and Trends");						
				$('#live-stream-button').html("Live Stream");				
			}
		});
	}	

	function processTweet(main_element, tweet_text_element, tweet_text, keep_hidden){
		$(tweet_text_element).closest('.tweet').find('.time').timeago();
		urlMaker(tweet_text_element, tweet_text);
		linkifyTwitterUsernames();
		if (keep_hidden == undefined || keep_hidden == false) {
			putLoadDiv(main_element);
		}		
	}
		
	function processTweetCollection(main_element){
		$(main_element).find('.tweet-text').each(function() {
			var text = $(this).find(".original-text").text();
			urlMaker(this, text);
		});
		$(main_element).find('.time').each(function() {
			$(this).timeago();
		});
		linkifyTwitterUsernames();
	}
	
	function urlMaker(selector, tweet_text){
		var combinedRegex = /#\w+|(?:https?|ftp):\/\/.*?\..*?(?=\W?(\s|$))/gi,
		container = $(selector);
				
		var result, prevLastIndex = 0;
		combinedRegex.lastIndex = 0;
		while((result = combinedRegex.exec(tweet_text))) {
			container.append($('<span/>').text(tweet_text.slice(prevLastIndex, result.index)));
			if (result[0].slice(0, 1) == "#") {
				container.append($('<a/>')
				.attr('href', 'http://twitter.com/search/' + encodeURIComponent(result[0].slice(1)))
				.attr('target', '_blank')				
				.text(result[0]));
			}
			else {
				container.append($('<a/>')
				.attr('href', result[0])
				.attr('target', '_blank')
				.text(result[0]));
		}
		prevLastIndex = combinedRegex.lastIndex;
		}
		container.append($('<span/>').text(tweet_text.slice(prevLastIndex)));		
	}
	
	function linkifyTwitterUsernames(){		
		
	  twttr.anywhere(function (T) {
			T.hovercards({
				expanded: true
			});
	  });		
		
	  twttr.anywhere(function (T) {
			T("strong > a").hovercards({
				expanded: true,
				username: function(node) {
					return node.title;
				}
			});
	  });				
	}
	
	function isThaana(s) {
		return /haveeru\.com\.mv\/dhivehi|sun\.mv\/\d|manadhoolive|newdhivehiobserver|moonlight\.com\.mv|cnm\.com\.mv|dhitv\.com\.mv/.test(s);
	} 
	
	function switchNavigationStyles(current_tab, new_tab, new_tab_href){
		$(current_tab).hide();
		$(new_tab).show();
		$('.navbar').find(".active").removeClass("active");
		$('a[href="' + new_tab_href +'"]').closest("li").addClass("active");
	}
	
	Array.prototype.remove = function(elem) {
		var match = -1;
		while( (match = this.indexOf(elem)) > -1 ) {
			this.splice(match, 1);
		}
	}
	
	Array.prototype.unique = function () {
		var arrVal = this;
		var uniqueArr = [];
		for (var i = arrVal.length; i--; ) {
			var val = arrVal[i];
			if ($.inArray(val, uniqueArr) === -1) {
				uniqueArr.unshift(val);
			}
		}
		return uniqueArr;
	}		

});