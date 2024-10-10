local hey_listen_for_vouchers_level = {
	["v_clearance_sale"] = 1,
	["v_liquidation"] = 2,
}

hey_listen_should_i_listen = false
function hey_listen_for_voucher(card)
	if not hey_listen_should_i_listen or not card or not card.area then
		return false
	end

	if card.area ~= G.shop_vouchers and card.area ~= G.shop_jokers and card.area ~= G.shop_booster then
		return false
	end

	local hey_i_hear_voucher = nil
	local hey_i_hear_voucher_level = 0

	for key, level in pairs(hey_listen_for_vouchers_level) do
		if G.GAME.used_vouchers[key] then
			hey_i_hear_voucher_level = math.max(hey_i_hear_voucher_level, level)
		end
	end

	if G.shop_vouchers and G.shop_vouchers.cards then
		for k, v in ipairs(G.shop_vouchers.cards) do
			local level = hey_listen_for_vouchers_level[v.config.center.key]
			if level and level > hey_i_hear_voucher_level then
				hey_i_hear_voucher = v
				hey_i_hear_voucher_level = level
			end
		end
	end

	if not hey_i_hear_voucher or hey_i_hear_voucher == card then
		return false
	end
	if G.GAME.dollars < (hey_i_hear_voucher.cost + card.cost) then
		return false
	end
	hey_listen_should_i_listen = false
	play_sound("foil2", 0.8, 0.3)
	attention_text({
		text = "Hey, Listen!",
		scale = 0.6,
		hold = 1.25,
		backdrop_colour = HEX("31cdf6"),
		align = "tm",
		major = hey_i_hear_voucher,
		offset = { x = 0, y = -0.05 * G.CARD_H },
	})
	hey_i_hear_voucher:juice_up(0.4, 0.4)
	return true
end
