$(function() {
	
	window.Page = Backbone.Model.extend({
		visible: false,
		
		initialize: function() {
			this.id = '#page_' + this.get('number');
		}
	});
	
	window.PageView = Backbone.View.extend({
		
		initialize: function() {
			this.el = $(this.model.id);
			this.listing = $('#metadata .pages a[page="' + this.model.get('number') + '"]');
			
			_.bindAll(this, 'update_visibility');
			this.model.bind('change:visible', this.update_visibility);
			
			
		},
		
		update_visibility: function() {
			if (this.model.get('visible')) {
				$(this.el).fadeIn('fast');
				this.listing.addClass('selected');
			} else {
				$(this.el).fadeOut('fast');
				this.listing.removeClass('selected');
			}
		}
	});
	
	window.PageList = Backbone.Collection.extend({
		model: Page,
		
		turn_on_page: function(number) {
			_(this.models).each(function(page) {
				if (page.get('number') == number) {
					page.set({visible: true});
				} else {
					page.set({visible: false});
				}
			});
		}
	});
	
	window.Pages = new PageList;
	
	window.PresenterView = Backbone.View.extend({
		
		el: $('#presenter'),
		
		events: {
			'click #previous-page': 'goto_previous_page',
			'click #next-page':     'goto_next_page',
			'click .pages a':       'jump_to_page',
			'click #content-cover': 'close_reward_modal'
		},
		
		initialize: function() {
			var page_number = 1;
			$('#pages').children().each(function(page) {
				var $page_li = $(this);
				var page = new Page({number: page_number, visible: (page_number == 1)});
				var page_view = new PageView({model: page});
				Pages.add(page);
				page_number += 1;
			});
			
			this.current_page = 1;
			this.previous_button = this.$('#previous-page');
			this.next_button = this.$('#next-page');
			this.$('ul#pages li').swipe({swipe:this.swipe,threshold:0});
			this.goto_page_in_url_or_default();
			this.setup_key_bindings();
		},
		
		goto_previous_page: function() {
			this.goto_page(this.current_page - 1);
		},
		
		goto_next_page: function() {
			this.goto_page(this.current_page + 1);
		},
		
		goto_page: function(number) {
			if (number >= 1 && number <= Pages.length && number != this.current_page) {
				this.current_page = number;
				Pages.turn_on_page(this.current_page);
			}
			
			if (this.current_page == 1) {
				this.previous_button.fadeOut('fast');
			} else {
				this.previous_button.fadeIn('fast');
			}
			if (this.current_page == Pages.length) {
				this.next_button.fadeOut('fast');
			} else {
				this.next_button.fadeIn('fast');
			}
		},
		
		swipe: function(event, direction) {
			if (direction == "left") {
				this.goto_next_page();
			} else if (direction == "right") {
				this.goto_prev_page();
			}
		},
		
		jump_to_page: function(e) {
			var $link = $(e.currentTarget);
			var number = parseInt($link.attr('page'));
			this.goto_page(number);
			return false;
		},
		
		close_reward_modal: function() {
			RewardModal.hide_modal();
		},
		
		goto_page_in_url_or_default: function() {
			var url = window.location.href;
			if (url.indexOf('#page') != -1) {
				var number = parseInt(url.substring(url.indexOf('#page') + 5));
				this.goto_page(number);
			} else {
				this.goto_page(1);
			}
		},
		
		setup_key_bindings: function() {
			var presenter = this;
			$(document).keyup(function(e) {
				if (!RewardModal.modal_open) {
				  console.log('here');
				  if (e.keyCode == 39) { presenter.goto_next_page(); } 					// right arrow
					if (e.keyCode == 37) { presenter.goto_previous_page(); }			// left arrow
				}
			});
		}
	});
	
	window.RewardModalView = Backbone.View.extend({
		el: $('#reward-modal'),
		
		events: {
			'click #reward-modal-tab':        'toggle_modal',
			'click #stars a': 								'choose_reward_amount',
			'focus #custom_amount': 					'choose_custom_amount',
  		'blur #custom_amount':            'stop_choosing_custom',
			'submit #reward-form':            'submit_reward'
		},
		
		initialize: function() {
			this.modal_open = false;
			this.setup_key_bindings();
			this.setup_custom_reward_amount_monitoring();
			this.editing_text = false;
		},
		
		show_modal: function() {
			$(this.el).animate({top: 0}, 300);
			$('#reward-modal-tab').hide().css('bottom',0);
			$('#content-cover').show();
			this.modal_open = true;
			mpq.track('Opened Reward Modal', {anonymous_id: '#{session[:analytics_anonymous_id]}'});
		},
		
		hide_modal: function() {
			$(this.el).animate({top: '-100%'}, 300, function() {
  			$('#reward-modal-tab').show().animate({bottom:'-39px'}, 300);
			});
			$('#content-cover').hide();
			this.modal_open = false;
			$('#its-you-arrow').hide();
		},
		
		toggle_modal: function() {
			if (this.modal_open) {
				this.hide_modal();
			} else {
				this.show_modal();
			}
			return false;
		},
		
		advance_to_step: function(step) {
		  $('#modal-steps li[step=' + step + ']').addClass('selected').siblings().removeClass('selected');
		},
		
		turn_off_stars: function() {
			$('#stars a').removeClass('selected');
			$('#custom_amount').removeClass('selected');
		},
		
		choose_reward_amount: function(event) {
			var $star_button = $(event.currentTarget);

			RewardModal.turn_off_stars();
			$star_button.addClass('selected');

			$('#reward_amount').val($star_button.attr('amount'));
			$('#custom_amount').val('');
			
			this.show_reward_comment();
			return false;
		},
		
		choose_custom_amount: function() {
			RewardModal.turn_off_stars();
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
			$amount.change(function() {
				$('#reward_amount').val($(this).val());
			});
			$('#custom_amount').observe_field(1, this.show_reward_comment);
		},
		
		show_reward_comment: function() {
		  var $comment = $('#comment');
			if (!$comment.is(':visible')) {
			  window.setTimeout(function() {
			    $('#amount-hints').fadeOut(200, function() {
			      $comment.fadeIn(200);
        		RewardModal.advance_to_step(2);
			    });
			  }, 300);
			}
		},
		
		advance_to_user_status: function() {
		  $('#creator-info, #reward-box').hide();
		  $('#your-status').show();
		  
			RewardModal.advance_to_step(4);
		},
		
		back_to_sharing: function() {
		  $('#your-status').hide();
		  $('#creator-info, #reward-box').show();
		  
			RewardModal.advance_to_step(3);
		},

		submit_reward: function(e) {
			var $form = $(e.currentTarget);
			e.preventDefault();

			if ($('#reward_amount').val() == '') {
				alert('Please choose how much to reward.');
				return false;
			}

			var amount = $form.find('#reward_amount').val();
			var comment = $form.find("#reward_comment").val();
			var story_id = $form.find("#reward_story_id").val();
			var impacted_by = $form.find("#reward_impacted_by").val();
			var url = $form.attr('action');

			$('#reward-box').addClass('loading');
			$('#reward-form').remove();
			$.post(url,
				{
					"reward[amount]":amount,
					"reward[comment]":comment,
					"reward[story_id]":story_id,
					"reward[impacted_by]":impacted_by
				},
				function(data) {
					$("#reward-box").html(data).removeClass('loading');
					$('#what-is-impact').fancybox();
					$('#url_to_share').click(function() { $(this).select(); });
					
					if (comment != '') {
					  $('#new-comment .text').text(comment);
					  $('#new-comment .reward').text('($' + (parseInt(amount) * 0.10).toFixed(2) + ')');
					  $('#new-comment').slideDown();
					}
				}
			);
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
		
		

		setup_key_bindings: function() {
			var modal = this;
			$(document).keyup(function(e) {
			  if (e.keyCode == 27) { modal.toggle_modal(); } 			// escape
			});
		}
	});
	
	window.Presenter = new PresenterView;
	window.RewardModal = new RewardModalView;
	
});