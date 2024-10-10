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

HeyListen.current_mod.config_tab = function()
	return {
		n = G.UIT.ROOT,
		config = { align = "cm", padding = 0.05, colour = G.C.CLEAR },
		nodes = {
			create_option_cycle({
				w = 4,
				label = "Notifications level",
				scale = 0.8,
				options = {
					"None",
					"Once per shop",
				},
				opt_callback = "hey_listen_set_notification_level",
				current_option = HeyListen.config.notification_level,
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
