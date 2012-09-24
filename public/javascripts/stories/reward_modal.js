$(function() {
  
	var opacity_setting = 1;
	$('.tooltipped').tipsy({opacity:opacity_setting});
	$('.tooltipped-n').tipsy({opacity:opacity_setting,gravity:'s'});
	$('.tooltipped-w').tipsy({opacity:opacity_setting,gravity:'e'});
	$('.tooltipped-e').tipsy({opacity:opacity_setting,gravity:'w'});
	
	window.RewardModalView = Backbone.View.extend({
		el: $('#reward-modal'),
		
		events: {
			'click #toggle-synopsis':         'toggle_full_synopsis',
			'click #amounts li a': 						'choose_reward_amount',
			'focus #custom_amount': 					'choose_custom_amount',
			'keydown #custom_amount':         'cleanse_reward_amount',
			'keyup #custom_amount':           'cleanse_reward_amount',
  		'blur #custom_amount':            'stop_choosing_custom',
  		'submit #reward-form':            'submit_reward',
			'click #open-comments-tab':       'toggle_comments'
		},
		
		initialize: function() {
			this.modal_open = false;
			this.editing_text = false;
			this.reward_submitted = false;
			this.comments_open = false;
			
			this.setup_key_bindings();
			this.setup_custom_reward_amount_monitoring();
		},
		
		open_modal: function() {
			$(this.el).addClass('open');
			// show the extra stuff after the css transition effect finishes
			setTimeout(function() {$('#reward-modal').addClass('opened');}, 200);
			$('#content-cover').show();
			this.modal_open = true;
			mixpanel.track('Opened Reward Modal');
		},
		
		close_modal: function() {
			$(this.el).removeClass('open opened');
			$('#content-cover').hide();
			this.modal_open = false;
		},
		
		toggle_modal: function() {
		  if (RewardModal.modal_open) {
		    if (RewardModal.comments_open) {
		      RewardModal.toggle_comments();
		    } else {
		      RewardModal.close_modal();
		    }
			} else {
				RewardModal.open_modal();
			}
			return false;
		},
		
		toggle_full_synopsis: function(event) {
		  var $link = $(event.currentTarget);
		  var $synopsis = $link.parent();
		  if ($synopsis.hasClass('more')) {
		    $link.siblings('.more').hide();
		    $link.siblings('.less').show();
		    $synopsis.removeClass('more');
		    $link.text('more');
		  } else {
		    $link.siblings('.less').hide();
		    $link.siblings('.more').show();
		    $synopsis.addClass('more');
		    $link.text('less');
		  }
		  return false;
		},
		
		turn_off_amounts: function() {
			$('#amounts a').removeClass('selected');
			$('#custom_amount').removeClass('selected');
		},
		
		choose_reward_amount: function(event) {
			var $button = $(event.currentTarget);

			RewardModal.turn_off_amounts();
			$button.addClass('selected');

			$('#reward_amount').val($button.attr('amount'));
			$('#custom_amount').val('');
			
			window.setTimeout(RewardModal.finished_reward_amount, 200);
			return false;
		},
		
		cleanse_reward_amount: function(event) {
		  var $input = $('#custom_amount');
		  var value = $input.val()
		  var bad_values = !(/^[0-9\$\.]*$/i).test(value);
		  if (bad_values) {
		    $input.val(value.replace(/[^0-9\$\.]/ig, ''));
		  }
		},
		
		choose_custom_amount: function() {
			RewardModal.turn_off_amounts();
			$('#reward_amount').val('');
  	  RewardModal.editing_text = true;
		},

  	stop_choosing_custom: function() {
  	  RewardModal.editing_text = false;
  	},
		
		setup_custom_reward_amount_monitoring: function() {
			var $amount = $('#custom_amount');
			$amount.click(function() {
				$amount.addClass('selected');
			});
			$amount.keyup(function() {
				$('#reward_amount').val($amount.val());
			});
			$('#custom_amount').observe_field(1, this.finished_reward_amount);
		},
		
		finished_reward_amount: function() {
		  $('form#reward-form input[type="submit"]').css('opacity',1);
		},

		submit_reward: function(event) {
			var $form = $('#reward-form');
			event.preventDefault();

			if ($('#reward_amount').val() == '') {
				alert('Please choose how much to reward.');
				return false;
			}

			var amount = $form.find('#reward_amount').val();
			var story_id = $form.find("#reward_story_id").val();
			var impacted_by = $form.find("#reward_impacted_by").val();
			var url = $form.attr('action');

			$('#current-step').addClass('loading');
			$.ajax({
			  url: url,
			  type: 'POST',
				data: {
					"reward[amount]":amount,
					"reward[story_id]":story_id,
					"reward[impacted_by]":impacted_by
				},
				success: function(data) {
    			$('#reward-form').remove();
				  RewardModal.reward_submitted = true;
					$("#current-step").html(data).removeClass('loading');
					$('#amounts-helper').remove();
					$('#url_to_share').click(function() { $(this).select(); });
					RewardModal.allow_commenting();
				},
				error: function(data) {
				  $('#current-step').removeClass('loading');
				  $('#invalid-reward-amount').show();
				  $('#custom_amount').focus();
				}
			});
			
			return false;
		},
		
		monitor_sharing: function(reward_id) {
		  $('#share-with-twitter').fancybox({padding:0,width:400,height:130});
		  $('#share-with-facebook').fancybox({padding:0,width:400,height:200});
		  
			// Twitter configuration
			var $configure_twitter = $('#configure-twitter');
			if ($configure_twitter.length > 0) {
				$configure_twitter.click(function() {
					RewardModal.configure_twitter_sharing($configure_twitter.attr('href'), reward_id);
					return false;
				});
			}
			
			// Twitter form submission
			RewardModal.monitor_twitter_sharing();
			
			// Facebook configuration
			var $configure_facebook = $('#configure-facebook');
			if ($configure_facebook.length > 0) {
				$configure_facebook.click(function() {
					RewardModal.configure_facebook_sharing($configure_facebook.attr('href'), reward_id);
					return false;
				});
			}
			
			// Facebook form submission
			RewardModal.monitor_facebook_sharing();
		},

		monitor_twitter_sharing: function() {
			$('#twitter_comment').keydown(function(event) {
				var text = $(this).val()
				$('#characters-left .count').text(110 - text.length);
			});
			$('#twitter_comment').keyup(function(event) {
				var text = $(this).val()
				$('#characters-left .count').text(110 - text.length);
			});
			
			$('#twitter-sharing form').submit(function(event) {
				event.preventDefault();
				
				var comment = $('#twitter_comment').val();
				var reward_id = $('#twitter_reward_id').val();
				var url = $(this).attr('action');

				if (comment == '') {
					alert('Please provide a message.');
					return false;
				}
				
				$('#twitter-sharing').addClass('loading');
				$.post(url, { comment: comment, reward_id: reward_id }, function(html) {
					$('#twitter-sharing .configured').html(html);
					$('#twitter-sharing').removeClass('loading');
					mixpanel.track('Promoted Content', { service: 'twitter' });
				});
			});
		},
		
		monitor_facebook_sharing: function() {
			$('#facebook-sharing form').submit(function(event) {
				event.preventDefault();
				
				var comment = $('#facebook_comment').val();
				var reward_id = $('#facebook_reward_id').val();
				var url = $(this).attr('action');

				if (comment == '') {
					alert('Please provide a message.');
					return false;
				}
				
				$('#facebook-sharing').addClass('loading');
				$.post(url, { comment: comment, reward_id: reward_id }, function(html) {
					$('#facebook-sharing').html(html).removeClass('loading');
					mixpanel.track('Promoted Content', { service: 'facebook' });
				});
			});
		},
		
		configure_twitter_sharing: function(url, reward_id) {
			window.oauth_twitter_window = window.open(url,'Twitter Configuration','height=500,width=900');
			window.oauth_twitter_interval = window.setInterval(function() {
				if (window.oauth_twitter_window.closed) {
					window.clearInterval(window.oauth_twitter_interval);
					RewardModal.twitter_configuration_complete(reward_id);
				}
			}, 1000);
		},
		
		twitter_configuration_complete: function(reward_id) {
			$.get('/auth/twitter/check', function(result) {
				if(result) {
					$.get('/share/twitter_form?reward_id=' + reward_id, function(html) {
						$('#twitter-sharing').html(html);
						RewardModal.monitor_twitter_sharing();
					});
				}
			});
		},
		
		configure_facebook_sharing: function(url, reward_id) {
			window.oauth_facebook_window = window.open(url,'Facebook Configuration','height=500,width=900');
			window.oauth_facebook_interval = window.setInterval(function() {
				if (window.oauth_facebook_window.closed) {
					window.clearInterval(window.oauth_facebook_interval);
					RewardModal.facebook_configuration_complete(reward_id);
				}
			}, 1000);
		},
		
		facebook_configuration_complete: function(reward_id) {
			$.get('/auth/facebook/check', function(result) {
				if(result) {
					$.get('/share/facebook_form?reward_id=' + reward_id, function(html) {
						$('#facebook-sharing').html(html);
						RewardModal.monitor_facebook_sharing();
					});
				}
			});
		},
		
		toggle_reward_hints: function() {
		  $('#amounts-helper').toggleClass('closed');
		},
		
		toggle_comments: function() {
		  var $comments = $('#comments-view');
		  $comments.toggleClass('open');
		  RewardModal.toggle_reward_hints();
		  RewardModal.comments_open = !RewardModal.comments_open;
		  return false;
		},
		
		allow_commenting: function() {
		  if (!RewardModal.comments_open) { RewardModal.toggle_comments(); }
		  $('#comments-view form').slideDown();
		},

		setup_key_bindings: function() {
			var modal = this;
			$(document).keyup(function(e) {
			  if (e.keyCode == 27) { modal.toggle_modal(); } 			// escape
			});
		}
	});
	
	window.RewardModal = new RewardModalView;
	
});