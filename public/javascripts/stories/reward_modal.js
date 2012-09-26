$(function() {
  
	var opacity_setting = 1;
	$('.tooltipped').tipsy({opacity:opacity_setting});
	$('.tooltipped-n').tipsy({opacity:opacity_setting,gravity:'s'});
	$('.tooltipped-w').tipsy({opacity:opacity_setting,gravity:'e'});
	$('.tooltipped-e').tipsy({opacity:opacity_setting,gravity:'w'});
	
	window.RewardModalView = Backbone.View.extend({
		el: $('#reward-modal'),
		
		events: {
		  'click a[href="#about"]':         'goto_about',
		  'click a[href="#reward"]':        'goto_reward',
		  'click #login-button':            'goto_login',
		  'submit #login-form':             'login',
			'click #amounts li a': 						'choose_reward_amount',
			'focus #custom_amount': 					'choose_custom_amount',
			'keydown #custom_amount':         'cleanse_reward_amount',
			'keyup #custom_amount':           'cleanse_reward_amount',
  		'blur #custom_amount':            'stop_choosing_custom',
  		'submit #reward-form':            'submit_reward',
  		'click a.after-link':             'goto_after_view'
		},
		
		initialize: function() {
			this.modal_open = false;
			this.editing_text = false;
			this.reward_submitted = false;
			this.comments_open = false;
			
			this.setup_key_bindings();
			this.setup_custom_reward_amount_monitoring();
		},
		
		// ACTIONS IF NOT LOGGED IN -------------------------------------
		
		goto_about: function() {
		  $('#reward-actions').css('margin-left',-620);
		  return false;
		},
		
		goto_reward: function() {
		  $('#reward-actions').css('margin-left',0);
		  return false;
		},
		
		goto_login: function() {
		  $('#reward-actions').css('margin-left',-1210);
		  return false;
		},
		
		login: function(event) {
		  var $form = $(event.target);
		  event.preventDefault();
		  
		  var email = $('#login_email').val();
		  var password = $('#login_password').val();
		  var token = $form.find('input[name="authenticity_token"]').val();
		  var data = {remote: true, commit: "Sign in", utf8: "✓",
        user: {remember_me: 1, password: password, email: email}};
		  
		  $form.addClass('loading');
		  $('#signup-section .alert').text('');
		  $.post('/users/sign_in_remote.json', data, function(response) {
  		  $form.removeClass('loading');
		    if (response.success) {
		      $('#reward_submit').show();
		      $('#what-is-momeant-link, #login-button').remove();
		      $('#current-user').show().find('.name').text(response.name);
		      current_user = true;
		      RewardModal.goto_reward();
		    } else {
		      $('#signup-section .alert').text('Invalid email/password.');
		    }
		  });
		  
		  return false;
		},
		
		// REWARD ACTIONS (LOGGED IN) -------------------------------------
		
		turn_off_amounts: function() {
			$('#amounts a').removeClass('selected');
			$('#custom_amount').removeClass('selected');
		},
		
		choose_reward_amount: function(event) {
		  if (!current_user) { RewardModal.goto_about(); return false; }
		  
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
		  $('form#reward-form input[type="submit"]').removeAttr('disabled');
		},

		submit_reward: function(event) {
			var $form = $('#reward-form');
			event.preventDefault();

			var amount = $form.find('#reward_amount').val();
			if (amount == '') {
				alert('Please choose how much to reward.');
				return false;
			}
			var story_id = $form.find("#reward_story_id").val();
			var impacted_by = $form.find("#reward_impacted_by").val();
			var url = $form.attr('action');

			$('#reward-actions').addClass('loading');
			$.ajax({
			  url: url,
			  type: 'POST',
				data: {
					"reward[amount]":amount,
					"reward[story_id]":story_id,
					"reward[impacted_by]":impacted_by
				},
				complete: function(xhr) {
				  var response = xhr.response;
				  var json = $.parseJSON(response);
				  if (json.success) {
      			RewardModal.reward_submitted = true;
      			mixpanel.track('Rewarded Content', {story_id: story_id, mp_note: amount, amount: amount});
            RewardModal.monitor_sharing(json.reward_id);
  					$('#main').html(json.html);
				  } else {
  				  $('#reward-actions').removeClass('loading');
  				  $('#invalid-reward-amount').show();
  				  $('#custom_amount').focus();
  				  alert(json.error);
				  }
				}
			});
			
			return false;
		},
		
		// ACTIONS AFTER REWARDING -------------------------------------
		
		goto_after_view: function(event) {
		  var $link = $(event.target);
		  $('#after-reward .after-view').hide();
		  $('#after-reward ' + $link.attr('href') + '-view').show();
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