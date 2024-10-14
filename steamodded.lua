--- STEAMODDED HEADER
--- MOD_NAME: Hey, Listen!
--- MOD_ID: HeyListen
--- MOD_AUTHOR: [SleepyG11]
--- MOD_DESCRIPTION: You have voucher to buy!

--- PRIORITY: 0
--- DISPLAY_NAME: Hey, Listen!
--- PREFIX: HeyListen
--- VERSION: 1.0.1
----------------------------------------------
------------MOD CODE -------------------------

HeyListen.current_mod = SMODS.current_mod
for k, v in pairs(SMODS.current_mod.config) do
	HeyListen.config[k] = v
end
SMODS.current_mod.config = HeyListen.config
function HeyListen.save_config()
	SMODS.save_mod_config(HeyListen.current_mod)
end
function G.FUNCS.hey_listen_set_notification_level(arg)
	HeyListen.config.notification_levels[arg.cycle_config.listener] = arg.to_key
	HeyListen.save_config()
end

HeyListen.UI = {}
HeyListen.UI.PARTS = {
	create_config_section = function(label, nodes)
		return {
			n = G.UIT.R,
			config = { align = "cm", padding = 0.05, colour = G.C.BLACK, r = 0.5, minw = 5 },
			nodes = {
				{
					n = G.UIT.R,
					config = { align = "cm", padding = 0.1 },
					nodes = {
						{
							n = G.UIT.T,
							config = {
								align = "cm",
								text = label,
								colour = G.C.WHITE,
								scale = 0.45,
								shadow = true,
							},
						},
					},
				},
				{
					n = G.UIT.R,
					config = { align = "cm" },
					nodes = nodes,
				},
			},
		}
	end,
	create_section_separator = function()
		return {
			n = G.UIT.R,
			config = { h = 0.1 },
		}
	end,
}

HeyListen.current_mod.config_tab = function()
	return {
		n = G.UIT.ROOT,
		config = { align = "cm", padding = 0.05, colour = G.C.CLEAR },
		nodes = {
			HeyListen.UI.PARTS.create_config_section("On buy", {
				create_option_cycle({
					w = 4,
					label = "Discount vouchers",
					scale = 0.6,
					options = {
						"Never",
						"Once per ante",
						"Once per shop",
					},
					opt_callback = "hey_listen_set_notification_level",
					listener = "sale_voucher",
					current_option = HeyListen.config.notification_levels.sale_voucher,
				}),
			}),
			HeyListen.UI.PARTS.create_section_separator(),
			HeyListen.UI.PARTS.create_config_section("On shop reroll", {
				{
					n = G.UIT.C,
					config = { align = "cm" },
					nodes = {
						create_option_cycle({
							w = 4,
							label = "Overstock vouchers",
							scale = 0.6,
							options = {
								"Never",
								"Once per ante",
								"Once per shop",
							},
							opt_callback = "hey_listen_set_notification_level",
							listener = "overstock_voucher",
							current_option = HeyListen.config.notification_levels.overstock_voucher,
						}),
					},
				},
				{
					n = G.UIT.C,
					config = { align = "cm" },
					nodes = {
						create_option_cycle({
							w = 4,
							label = "Reroll discount vouchers",
							scale = 0.6,
							options = {
								"Never",
								"Once per ante",
								"Once per shop",
							},
							opt_callback = "hey_listen_set_notification_level",
							listener = "surplus_voucher",
							current_option = HeyListen.config.notification_levels.surplus_voucher,
						}),
					},
				},
			}),
			HeyListen.UI.PARTS.create_section_separator(),
			HeyListen.UI.PARTS.create_config_section("On booster skip", {
				create_option_cycle({
					w = 4,
					label = "Constellation on Celestial pack",
					scale = 0.6,
					options = {
						"Never",
						"Once per ante",
						"Once per booster",
					},
					opt_callback = "hey_listen_set_notification_level",
					listener = "constellation",
					current_option = HeyListen.config.notification_levels.constellation,
				}),
			}),
			HeyListen.UI.PARTS.create_section_separator(),
			HeyListen.UI.PARTS.create_config_section("On blind select", {
				create_option_cycle({
					w = 4,
					label = "Ceremonial dagger",
					scale = 0.6,
					options = {
						"Never",
						"Once per ante",
						"Once per round",
					},
					opt_callback = "hey_listen_set_notification_level",
					listener = "dagger",
					current_option = HeyListen.config.notification_levels.dagger,
				}),
			}),
		},
	}
end

SMODS.Atlas({
	key = "modicon",
	path = "icon.png",
	px = 47,
	py = 47,
})

----------------------------------------------
------------MOD CODE END----------------------
