$(document).bind( "mobileinit", function() {

	$.event.special.swipe.horizontalDistanceThreshold = 75;
		
	$('#trend-makers').live('pagecreate', function(event){
	  $('#trend-makers-content').find('.tweet-text').each(function() {
			var text = $(this).find(".original-text").text();
			urlMaker(this, text);
			$(this).closest('.tweet-details').find('.time').timeago();				
		});
	});

	$('#popular-tweets').live('pagecreate', function(event){
		$('#popular-tweets-content').load('/mobile-retweets', function(){							
		  $('#popular-tweets-content').find('.tweet-text').each(function() {
				var text = $(this).find(".original-text").text();
				urlMaker(this, text);
				$(this).closest('.tweet-details').find('.time').timeago();				
			});			
		});
	  jc.subscribe("retweets", function(data){
			publishTweet(jQuery.parseJSON(data), true);
	  });		
	});

	$('#photos').live('pagecreate', function(event){		
		$('#photos-content').load('/mobile-photos', function(){							
		  $('#photos-content').find('.tweet-text').each(function() {
				var text = $(this).find(".original-text").text();
				urlMaker(this, text);
				$(this).closest('.tweet-details').find('.time').timeago();				
			});			
		});
	  jc.subscribe("photos", function(data){
			publishMedia(jQuery.parseJSON(data));
	  });	
	});
	
	$(".tweet").live('swipe', function() {
		showActionBar($(this));
	});
	
	function showActionBar(tweet_element){
		var height = $(tweet_element).find(".sub_tweet").height();
		$(tweet_element).find(".sub_tweet").hide();
		$(tweet_element).find(".tweet_actions").css("height", height);
		$(tweet_element).find(".tweet_actions").css("top", height/2-5);
		$(tweet_element).find(".tweet_actions").show();		
	}
	
	$(window).bind("resize", function(){
		$('.fluid').each(function() {
			this.style.width = "100%";
		});		
	});
	
  $(window).bind('scrollstart', function () {
		$('body').find(".sub_tweet").show();
		$('body').find(".tweet_actions").hide()		
  });	
			
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

	function deleteTweet(data){
		$(".tweet_" + data.tweet_id).next(".entity").remove();			
		$(".tweet_" + data.tweet_id).remove();
	}

	function publishTweet(tweet, retweet) {
		if (retweet == true) {
			var selector = "#popular-tweets-content > .tweets";
		}
		else {
			var selector = "#trend-makers-content > .tweets";		
		}
		$(selector).prepend('<div class="hide tweet tweet_'+ tweet.tweet_id +'"><div class="sub_tweet"><div class="profile_picture"><img src="' + tweet.profile_image_url + '"/></div><div class="tweet-details"><strong><a href="https://twitter.com/' + tweet.screen_name + '/statuses/' + tweet.tweet_id +'" target="_blank">' + tweet.name + '</a></strong> <small class="username">@' + tweet.screen_name +'</small><span class="time" title="'+ tweet.created_at + '"></span><p class="tweet-text ' + tweet.tweet_id +'"></p></div><div class"clear"></div><div class="hide tweet_actions"><div class="row-fluid icons actions tweet_"><span class="reply"><span class="reply-icon twitter-icon">&nbsp;</span><a href="https://twitter.com/intent/tweet?in_reply_to=' + tweet.tweet_id + '">Reply</a></span><span class="retweet"><span class="retweet-icon twitter-icon">&nbsp;</span><a href="https://twitter.com/intent/retweet?tweet_id=' + tweet.tweet_id + '">Retweet</a></span><span class="favorite"><span class="favorite-icon twitter-icon">&nbsp;</span><a href="https://twitter.com/intent/favorite?tweet_id=' + tweet.tweet_id + '">Favorite</a></span><div class"clear"></div></div></div></div>');		
		$('.tweet_' + tweet.tweet_id + ' > .tweet-details > .time').timeago();				
		urlMaker('.' + tweet.tweet_id, tweet.text);
		putLoadDiv(selector);
	}
	
	function publishMedia(tweet) {		
		$("#media-content > .tweets").prepend('<div class="hide tweet entity borderless high media_'+ tweet.media_id +'"><div class="crop"><a href="'+ tweet.url +'" target="_blank"><img src="' + tweet.media_url + '"/></a></div></div>');				
		$("#media > .tweets").prepend('<div class="hide tweet borderless tweet_'+ tweet.tweet_id +'"><div class="sub_tweet"><div class="profile_picture"><img src="' + tweet.profile_image_url + '"/></div><div class="tweet-details"><strong><a href="https://twitter.com/' + tweet.screen_name + '/statuses/' + tweet.tweet_id +'" target="_blank">' + tweet.name + '</a></strong> <small class="username">@' + tweet.screen_name +'</small><span class="time" "title=' + tweet.created_at + '"</span><p class="tweet-text tweet_media_' + tweet.tweet_id +'"></p></div><div class"clear"></div><div class="hide tweet_actions"><div class="row-fluid icons actions tweet_"><span class="reply"><span class="reply-icon twitter-icon">&nbsp;</span><a href="https://twitter.com/intent/tweet?in_reply_to=' + tweet.tweet_id + '">Reply</a></span><span class="retweet"><span class="retweet-icon twitter-icon">&nbsp;</span><a href="https://twitter.com/intent/retweet?tweet_id=' + tweet.tweet_id + '">Retweet</a></span><span class="favorite"><span class="favorite-icon twitter-icon">&nbsp;</span><a href="https://twitter.com/intent/favorite?tweet_id=' + tweet.tweet_id + '">Favorite</a></span><div class"clear"></div></div></div></div>');
		$('.media_' + tweet.tweet_id + '  > .tweet-details > .time').timeago();								
		urlMaker('.tweet_media_' + tweet.tweet_id, tweet.text);			
		putLoadDiv("#media-content > .tweets");
	}	
	
	function updateTrends(trends) {
		$('#trends').replaceWith('<div id="trends"><div class="trends-title">Current Trends</div><p>' + trends.trends.join(", ") + '</p></div>');
	}	
	
	function putLoadDiv(selector){		
		var count = 0;		
		if ($(selector + " > .load-more > .count").length != 0) {
			var count = $(selector + " > .load-more > .count").text();
		}
		count = parseInt(count) + 1;
		$(selector + " > .load-more").remove();
		$(selector).prepend('<div class="load-more">Show <span class="count"></span> New Tweets</div>');
		$(selector + " > .load-more > .count").text(count);
		$('div.load-more').bind('click', function(){
			$(selector + ' > .hide').show();
			$(this).remove();
		});
	}

	function urlMaker(selector, tweet_text){
		var combinedRegex = /@\w+|#\w+|(?:https?|ftp):\/\/.*?\..*?(?=\W?(\s|$))/gi,
		container = $(selector);			
		var result, prevLastIndex = 0;
		combinedRegex.lastIndex = 0;
		while((result = combinedRegex.exec(tweet_text))) {
			container.append($('<span/>').text(tweet_text.slice(prevLastIndex, result.index)));
			if (result[0].slice(0, 1) == "@") {
				container.append($('<a/>')
				.attr('href', 'http://twitter.com/' + encodeURIComponent(result[0].slice(1)))
				.attr('target', '_blank')
				.text(result[0]));
			}
			else if (result[0].slice(0, 1) == "#") {
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
		
});