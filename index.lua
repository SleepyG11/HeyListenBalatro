HeyListen = {
	should_i_not_listen = {},
	should_i_not_listen_per_ante = {},

	orders = {},
	listeners = {},

	config_ui = {
		shop = {
			label = "Shop",
			events = {
				shop_buy = {
					label = "On buy",
					listeners = {},
				},
				shop_reroll = {
					label = "On shop reroll",
					listeners = {},
				},
			},
		},
		blinds = {
			label = "Blinds",
			events = {
				blind_select = {
					label = "On blind select",
					listeners = {},
				},
				hand_play = {
					label = "On hand play",
					listeners = {},
				},
			},
		},
		actions = {
			label = "Actions",
			events = {
				card_sell = {
					label = "On card sell",
					listeners = {},
				},
				card_use = {
					label = "On card use",
					listeners = {},
				},
			},
		},
		other = {
			label = "Other",
			events = {
				booster_skip = {
					label = "On booster skip",
					listeners = {},
				},
			},
		},
	},

	utils = {
		get_all_cards_in_shop = function()
			local cards = {}
			local areas = { G.shop_vouchers, G.shop_jokers, G.shop_booster }
			for i = 1, #areas do
				local area = areas[i]
				if area and area.cards then
					for _, v in ipairs(area.cards) do
						table.insert(cards, v)
					end
				end
			end
			return cards
		end,
		find_voucher_in_shop = function(levels)
			local hey_i_hear_voucher = nil
			local hey_i_hear_voucher_level = 0

			for key, level in pairs(levels) do
				if G.GAME.used_vouchers[key] then
					hey_i_hear_voucher_level = math.max(hey_i_hear_voucher_level, level)
				end
			end

			local cards = HeyListen.utils.get_all_cards_in_shop()

			for k, v in ipairs(cards) do
				local level = levels[v.config.center.key]
				if level and level > hey_i_hear_voucher_level then
					hey_i_hear_voucher = v
					hey_i_hear_voucher_level = level
				end
			end

			return hey_i_hear_voucher, hey_i_hear_voucher_level
		end,
		find_card_in_jokers = function(levels)
			local hey_i_hear_card = nil
			local hey_i_hear_card_level = 0

			for key, level in pairs(levels) do
				if level > hey_i_hear_card_level then
					for index, card in ipairs(G.jokers.cards) do
						if card.config.center.key == key then
							hey_i_hear_card = card
							hey_i_hear_card_level = level
						end
					end
				end
			end

			return hey_i_hear_card, hey_i_hear_card_level
		end,
		find_dagger_like_card_in_jokers = function(levels)
			if #G.jokers.cards > 15 then
				return false
			end

			local hey_i_hear_card = nil
			local hey_i_hear_card_level = 0

			for key, level in pairs(levels) do
				if level > hey_i_hear_card_level then
					for index, card in ipairs(G.jokers.cards) do
						if card.config.center.key == key then
							local next_card = G.jokers.cards[index + 1]
							if next_card and not next_card.ability.eternal then
								hey_i_hear_card = card
								hey_i_hear_card_level = level
							end
						end
					end
				end
			end

			return hey_i_hear_card, hey_i_hear_card_level
		end,
		notify_card = function(card, align)
			if not card then
				return
			end
			local card_align, card_offset = nil, nil
			if align == "top" then
				card_align = "tm"
				card_offset = -0.05 * G.CARD_H
			elseif align == "bottom" then
				card_align = "bm"
				card_offset = 0.05 * G.CARD_H
			elseif align == "blind_top" then
				card_align = "tm"
				card_offset = -0.05 * 2
			end
			if not card_align or not card_offset then
				return
			end
			attention_text({
				text = "Hey, Listen!",
				scale = 0.6,
				hold = 1.25,
				backdrop_colour = HEX("31cdf6"),
				align = card_align,
				major = card,
				offset = { x = 0, y = card_offset },
			})
			card:juice_up(0.4, 0.4)
			play_sound("foil2", 0.8, 0.3)
		end,
	},
}

----

function HeyListen.reset_listening(target_event)
	if target_event then
		HeyListen.should_i_not_listen[target_event] = {}
	else
		for event, v in pairs(HeyListen.should_i_not_listen) do
			HeyListen.should_i_not_listen[event] = {}
		end
	end
end
function HeyListen.reset_listening_per_ante(target_event)
	if target_event then
		HeyListen.should_i_not_listen_per_ante[target_event] = {}
	else
		for event, v in pairs(HeyListen.should_i_not_listen_per_ante) do
			HeyListen.should_i_not_listen_per_ante[event] = {}
		end
	end
end

function HeyListen.get_should_i_not_listen(event, listener, notif_level)
	if notif_level == 1 then
		return true
	elseif notif_level == 2 then
		return (HeyListen.should_i_not_listen_per_ante[event] or {})[listener]
	elseif notif_level == 3 then
		return (HeyListen.should_i_not_listen[event] or {})[listener]
	else
		return true
	end
end
function HeyListen.set_should_i_not_listen(event, listener, notif_level)
	if notif_level == 1 then
		return
	end
	local target_obj

	if notif_level == 2 then
		target_obj = HeyListen.should_i_not_listen_per_ante
	elseif notif_level == 3 then
		target_obj = HeyListen.should_i_not_listen
	else
		return
	end
	if not target_obj[event] then
		target_obj[event] = {}
	end
	target_obj[event][listener] = true
end

----

HeyListen.config = {
	notification_levels = {},
}

function HeyListen.save_config() end

--

function HeyListen.process_event(event, options)
	for _, listener in ipairs(HeyListen.orders[event] or {}) do
		local notif_level = HeyListen.config.notification_levels[event .. "/" .. listener]
		if not HeyListen.get_should_i_not_listen(event, listener, notif_level) then
			local handler = (HeyListen.listeners[event] or {})[listener] or function() end
			local notify_card, notify_align = handler(options.args or {})
			if notify_card then
				HeyListen.set_should_i_not_listen(event, listener, notif_level)
				HeyListen.utils.notify_card(notify_card, notify_align)
				if type(options.after_notify) == "function" then
					options.after_notify()
				end
				return true
			end
		end
	end
	return false
end

function HeyListen.on_shop_card_buy(card)
	if
		not card.area or (card.area ~= G.shop_vouchers and card.area ~= G.shop_jokers and card.area ~= G.shop_booster)
	then
		return false
	end

	return HeyListen.process_event("shop_buy", {
		args = { card = card },
	})
end

function HeyListen.on_shop_reroll(button)
	return HeyListen.process_event("shop_reroll", {
		args = { button = button },
	})
end

function HeyListen.on_blind_select(button)
	return HeyListen.process_event("blind_select", {
		args = { button = button },
		after_notify = function()
			button.disable_button = false
		end,
	})
end

function HeyListen.on_booster_skip(button)
	return HeyListen.process_event("booster_skip", {
		args = { button = button },
		after_notify = function()
			button.disable_button = false
		end,
	})
end

function HeyListen.on_hand_play(button)
	return HeyListen.process_event("hand_play", {
		args = { button = button },
		after_notify = function()
			button.disable_button = false
		end,
	})
end

function HeyListen.on_card_sell(button, card)
	return HeyListen.process_event("card_sell", {
		args = { button = button, card = card },
	})
end

function HeyListen.on_card_use(button, card, mute, nosave)
	return HeyListen.process_event("card_use", {
		args = { button = button, card = card, mute = mute, nosave = nosave },
	})
end

--

--- Add event listener
--- @param options { event: string, key: string, listener: function, key_pos?: integer, config_default?: integer, config_label: string, config_options: string[] }
function HeyListen.add_event_listener(options)
	local event = options.event
	local listener = options.key

	local handler = options.listener
	assert(
		type(handler) == "function",
		"[HeyListen] Trying to add listener without handler function: " .. event .. "/" .. listener
	)

	if not HeyListen.orders[event] then
		HeyListen.orders[event] = {}
	end
	local order_list = HeyListen.orders[event]
	for _, current_listener in ipairs(order_list) do
		assert(current_listener ~= listener, "[HeyListen] Listener key already used: " .. event .. "/" .. listener)
	end
	if options.key_pos then
		table.insert(order_list, options.key_pos, listener)
	else
		table.insert(order_list, listener)
	end
	if not HeyListen.listeners[event] then
		HeyListen.listeners[event] = {}
	end
	HeyListen.listeners[event][listener] = handler

	local config_key = event .. "/" .. listener
	if not HeyListen.config.notification_levels[config_key] then
		HeyListen.config.notification_levels[config_key] =
			math.min(3, math.max(1, math.floor(options.config_default or 2)))
	end

	for k, v in pairs(HeyListen.config_ui) do
		local event_block = v.events[event]
		if event_block then
			event_block.listeners[listener] = {
				key = config_key,
				label = options.config_label or config_key,
				options = options.config_options,
			}
			return
		end
	end
end

--

HeyListen.add_event_listener({
	event = "shop_buy",
	key = "sale_voucher",
	config_label = "Discount vouchers",
	config_options = {
		"Never",
		"Once per ante",
		"Once per shop",
	},
	config_default = 2,
	listener = function(ctx)
		local card = ctx.card
		local levels = {
			["v_clearance_sale"] = 1,
			["v_liquidation"] = 2,
			["v_money_mint"] = 3,
			["v_cry_massproduct"] = 4,
		}
		local hey_i_hear_voucher = HeyListen.utils.find_voucher_in_shop(levels)

		if not hey_i_hear_voucher or hey_i_hear_voucher == card then
			return false
		end
		if card.cost == 0 or G.GAME.dollars < (hey_i_hear_voucher.cost + card.cost) then
			return false
		end

		return hey_i_hear_voucher, "top"
	end,
})
HeyListen.add_event_listener({
	event = "shop_reroll",
	key = "surplus_voucher",
	config_label = "Reroll discount vouchers",
	config_options = {
		"Never",
		"Once per ante",
		"Once per shop",
	},
	config_default = 2,
	listener = function(ctx)
		local levels = {
			["v_reroll_surplus"] = 1,
			["v_reroll_glut"] = 2,
		}

		local hey_i_hear_voucher = HeyListen.utils.find_voucher_in_shop(levels)

		if not hey_i_hear_voucher then
			return false
		end

		if G.GAME.dollars < hey_i_hear_voucher.cost then
			return false
		end

		return hey_i_hear_voucher, "top"
	end,
})
HeyListen.add_event_listener({
	event = "shop_reroll",
	key = "overstock_voucher",
	config_label = "Overstock vouchers",
	config_options = {
		"Never",
		"Once per ante",
		"Once per shop",
	},
	config_default = 2,
	listener = function(ctx)
		local levels = {
			["v_reroll_surplus"] = 1,
			["v_reroll_glut"] = 2,
		}

		local hey_i_hear_voucher = HeyListen.utils.find_voucher_in_shop(levels)

		if not hey_i_hear_voucher then
			return false
		end

		if G.GAME.dollars < hey_i_hear_voucher.cost then
			return false
		end

		return hey_i_hear_voucher, "top"
	end,
})
HeyListen.add_event_listener({
	event = "blind_select",
	key = "dagger_joker",
	config_label = "Ceremonial Dagger",
	config_options = {
		"Never",
		"Once per ante",
		"Once per round",
	},
	config_default = 2,
	listener = function(ctx)
		local hey_i_hear_dagger = HeyListen.utils.find_dagger_like_card_in_jokers({
			["j_ceremonial"] = 1,
		})

		if not hey_i_hear_dagger then
			return false
		end

		return hey_i_hear_dagger, "bottom"
	end,
})
HeyListen.add_event_listener({
	event = "booster_skip",
	key = "constellation_joker",
	config_label = "Constellation on Celestial pack",
	config_options = {
		"Never",
		"Once per ante",
		"Once per booster",
	},
	config_default = 2,
	listener = function(ctx)
		if G.STATE ~= G.STATES.PLANET_PACK then
			return false
		end

		local hey_i_hear_constellation = HeyListen.utils.find_card_in_jokers({
			["j_constellation"] = 1,
		})

		if not hey_i_hear_constellation then
			return false
		end

		return hey_i_hear_constellation, "bottom"
	end,
})
HeyListen.add_event_listener({
	event = "hand_play",
	key = "psychic_blind",
	config_label = "The Psychic boss blind",
	config_options = {
		"Never",
		"Once per ante",
	},
	config_default = 2,
	listener = function(ctx)
		if G.GAME.blind.name ~= "The Psychic" or #G.hand.highlighted >= 5 then
			return false
		end
		return G.GAME.blind, "blind_top"
	end,
})
