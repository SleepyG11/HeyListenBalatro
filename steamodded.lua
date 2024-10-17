--- STEAMODDED HEADER
--- MOD_NAME: Hey, Listen!
--- MOD_ID: HeyListen
--- MOD_AUTHOR: [SleepyG11]
--- MOD_DESCRIPTION: You have voucher to buy!

--- PRIORITY: 0
--- DISPLAY_NAME: Hey, Listen!
--- PREFIX: HeyListen
--- VERSION: 1.0.3-dev
----------------------------------------------
------------MOD CODE -------------------------

--- Merge target table with source tables
--- @param target table
--- @param ... table[]
--- @return table
local function table_merge(target, ...)
	assert(type(target) == "table", "Target is not a table")
	local tables_to_merge = { ... }
	if #tables_to_merge == 0 then
		return target
	end

	for k, t in ipairs(tables_to_merge) do
		assert(type(t) == "table", string.format("Expected a table as parameter %d", k))
	end

	for i = 1, #tables_to_merge do
		local from = tables_to_merge[i]
		for k, v in pairs(from) do
			if type(k) == "number" then
				table.insert(target, v)
			elseif type(k) == "string" then
				if type(v) == "table" then
					target[k] = target[k] or {}
					target[k] = table_merge(target[k], v)
				else
					target[k] = v
				end
			end
		end
	end

	return target
end

HeyListen.current_mod = SMODS.current_mod
HeyListen.config = table_merge(HeyListen.config, SMODS.current_mod.config or {})
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
	create_option_cycle = function(label, options, key)
		return {
			n = G.UIT.C,
			config = { align = "cm" },
			nodes = {
				create_option_cycle({
					w = 4,
					label = label,
					scale = 0.6,
					options = options,
					opt_callback = "hey_listen_set_notification_level",
					listener = key,
					current_option = HeyListen.config.notification_levels[key],
					col = true,
				}),
			},
		}
	end,

	create_event_section = function(tab, event)
		local ui_data = HeyListen.config_ui[tab].events[event]
		local ui_listeners = ui_data.listeners

		local result = {
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
								text = ui_data.label,
								colour = G.C.WHITE,
								scale = 0.45,
								shadow = true,
							},
						},
					},
				},
			},
		}

		local current_row = {}
		local counter = 0
		for k, v in pairs(ui_listeners) do
			counter = counter + 1
			if counter % 3 == 1 then
				current_row = {}
				table.insert(result.nodes, {
					n = G.UIT.R,
					config = { align = "cm" },
					nodes = current_row,
				})
			end
			table.insert(current_row, HeyListen.UI.PARTS.create_option_cycle(v.label, v.options, v.key))
		end

		return result
	end,
	create_event_section_separator = function()
		return {
			n = G.UIT.R,
			config = { h = 0.1 },
		}
	end,

	create_tab = function(tab)
		local ui_data = HeyListen.config_ui[tab]
		local ui_events = ui_data.events

		local result = {
			n = G.UIT.ROOT,
			config = { align = "cm", padding = 0.05, colour = G.C.CLEAR },
			nodes = {},
		}

		local sorted_events = {}
		for event, v in pairs(ui_events) do
			table.insert(sorted_events, event)
		end
		table.sort(sorted_events, function(a, b)
			return a < b
		end)
		for _, event in ipairs(sorted_events) do
			table.insert(result.nodes, HeyListen.UI.PARTS.create_event_section(tab, event))
			table.insert(result.nodes, HeyListen.UI.PARTS.create_event_section_separator())
		end

		table.remove(result.nodes, #result.nodes)

		return result
	end,

	create_extra_tabs = function()
		local result = {}
		for k, v in pairs(HeyListen.config_ui) do
			table.insert(result, {
				label = v.label,
				tab_definition_function = function()
					return HeyListen.UI.PARTS.create_tab(k)
				end,
			})
		end
		table.sort(result, function(a, b)
			return a.label < b.label
		end)
		return result
	end,
}

HeyListen.current_mod.extra_tabs = HeyListen.UI.PARTS.create_extra_tabs

SMODS.Atlas({
	key = "modicon",
	path = "icon.png",
	px = 47,
	py = 47,
})

----------------------------------------------
------------MOD CODE END----------------------
