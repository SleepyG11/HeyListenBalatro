HeyListen = {
	should_i_not_listen = {},
	should_i_not_listen_per_ante = {},
	enums = {
		sale_voucher_levels = {
			["v_clearance_sale"] = 1,
			["v_liquidation"] = 2,
			["v_money_mint"] = 3,
			["v_cry_massproduct"] = 4,
		},
		surplus_voucher_levels = {
			["v_reroll_surplus"] = 1,
			["v_reroll_glut"] = 2,
		},
		overstock_voucher_levels = {
			["v_overstock_norm"] = 1,
			["v_overstock_plus"] = 2,
		},
		dagger_levels = {
			["j_ceremonial"] = 1,
		},
		constellation_levels = {
			["j_constellation"] = 1,
		},
	},

	orders = {
		shop_buy = {
			"sale_voucher",
		},
		shop_reroll = {
			"surplus_voucher",
			"overstock_voucher",
		},
		blind_select = {
			"dagger_joker",
		},
		booster_skip = {
			"constellation_joker",
		},
		hand_play = {
			"psychic_blind",
		},
	},
	listeners = {
		shop_buy = {
			sale_voucher = function(card)
				local hey_i_hear_voucher = HeyListen.utils.find_voucher_in_shop(HeyListen.enums.sale_voucher_levels)

				if not hey_i_hear_voucher or hey_i_hear_voucher == card then
					return false
				end
				if card.cost == 0 or G.GAME.dollars < (hey_i_hear_voucher.cost + card.cost) then
					return false
				end

				return hey_i_hear_voucher, "top"
			end,
		},
		shop_reroll = {
			surplus_voucher = function()
				local hey_i_hear_voucher = HeyListen.utils.find_voucher_in_shop(HeyListen.enums.surplus_voucher_levels)

				if not hey_i_hear_voucher then
					return false
				end

				if G.GAME.dollars < hey_i_hear_voucher.cost then
					return false
				end

				return hey_i_hear_voucher, "top"
			end,
			overstock_voucher = function()
				local hey_i_hear_voucher =
					HeyListen.utils.find_voucher_in_shop(HeyListen.enums.overstock_voucher_levels)

				if not hey_i_hear_voucher then
					return false
				end

				if G.GAME.dollars < hey_i_hear_voucher.cost then
					return false
				end

				return hey_i_hear_voucher, "top"
			end,
		},
		blind_select = {
			dagger_joker = function()
				local hey_i_hear_dagger = HeyListen.utils.find_dagger_like_card_in_jokers(HeyListen.enums.dagger_levels)

				if not hey_i_hear_dagger then
					return false
				end

				return hey_i_hear_dagger, "bottom"
			end,
		},
		booster_skip = {
			constellation_joker = function()
				if G.STATE ~= G.STATES.PLANET_PACK then
					return false
				end

				local hey_i_hear_constellation =
					HeyListen.utils.find_card_in_jokers(HeyListen.enums.constellation_levels)

				if not hey_i_hear_constellation then
					return false
				end

				return hey_i_hear_constellation, "bottom"
			end,
		},
		hand_play = {
			psychic_blind = function()
				if G.GAME.blind.name ~= "The Psychic" or #G.hand.highlighted >= 5 then
					return false
				end
				return G.GAME.blind, "blind_top"
			end,
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
	notification_levels = {
		sale_voucher = 2,
		surplus_voucher = 2,
		overstock_voucher = 2,
		dagger_joker = 2,
		constellation_joker = 2,
		psychic_blind = 2,
	},
}

function HeyListen.save_config() end

--

function HeyListen.process_event(event, options)
	for _, listener in ipairs(HeyListen.orders[event]) do
		local notif_level = HeyListen.config.notification_levels[listener]
		if not HeyListen.get_should_i_not_listen(event, listener, notif_level) then
			local notify_card, notify_align = HeyListen.listeners[event][listener](unpack(options.args or {}))
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
		args = { card },
	})
end

function HeyListen.on_shop_reroll(button)
	return HeyListen.process_event("shop_reroll", {
		args = { button },
	})
end

function HeyListen.on_blind_select(button)
	return HeyListen.process_event("blind_select", {
		args = { button },
		after_notify = function()
			button.disable_button = false
		end,
	})
end

function HeyListen.on_booster_skip(button)
	return HeyListen.process_event("booster_skip", {
		args = { button },
		after_notify = function()
			button.disable_button = false
		end,
	})
end

function HeyListen.on_hand_play(button)
	return HeyListen.process_event("hand_play", {
		args = { button },
		after_notify = function()
			button.disable_button = false
		end,
	})
end
