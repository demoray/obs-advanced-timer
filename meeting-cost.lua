obs           = obslua
activated     = false
current_spend = 0.0
salary   = 100000.0
initial_cost  = 0.0
last_time 	  = 0
participants  = 1
source_name   = ""
default_prefix = "This meeting has cost"
default_suffix = "thus far."
prefix = default_prefix
suffix = default_suffix
timer_active  = false
show_participants = true

hotkey_id_dec_participants = obs.OBS_INVALID_HOTKEY_ID
hotkey_id_inc_participants = obs.OBS_INVALID_HOTKEY_ID
hotkey_id_pause     = obs.OBS_INVALID_HOTKEY_ID
hotkey_id_reset     = obs.OBS_INVALID_HOTKEY_ID

function script_description()
	return "How much has this meeting cost?"
end

function set_cost_text(ns)
	if ns > 0 then
		local ms = math.floor(ns/ 1000000)
		local current_cost = ms / 3600000 * participants * (salary / 49 / 40)
		current_spend = current_spend + current_cost
	end

	local text = string.format("$%.02f", current_spend)
	if not (prefix == "") then
		text = string.format('%s %s', prefix, text)
	end

	if not (suffix == "") then
		text = string.format('%s %s', text, suffix)
	end

	if show_participants then
		text = string.format("%s (%d participants)", text, participants)
	end

	local source = obs.obs_get_source_by_name(source_name)
	if source ~= nil then
		local settings = obs.obs_data_create()
		obs.obs_data_set_string(settings, "text", text)
		obs.obs_source_update(source, settings)
		obs.obs_data_release(settings)
		obs.obs_source_release(source)
	end
end

function script_tick(sec)
	if timer_active == false then
		return
	end

	local since = 0
	local now = obs.os_gettime_ns()
	if last_time > 0 then
		since = now - last_time
	end
	last_time = now

	set_cost_text(since)
end

function start_timer()
	timer_active = true
	last_time = obs.os_gettime_ns()
end

function stop_timer()
	timer_active = false
end

function reset(pressed)
	if pressed == true then
		current_spend = initial_cost
		last_time = 0
		set_cost_text(0)
	end
end

function inc_participants(pressed)
	if pressed == true then
		participants = participants + 1
	end
	set_cost_text(0)
end

function dec_participants(pressed)
	if pressed == true then
		participants = participants - 1
		if participants < 0 then
			participants = 0
		end
	end
	set_cost_text(0)
end

function on_pause(pressed)
	if pressed == true then
    	if timer_active then
    		stop_timer()
    	else
    		start_timer()
    	end
    end
	set_cost_text(0)
end

function pause_button_clicked(props, p)
	on_pause(true)
	return true
end

function reset_button_clicked(props, p)
	reset(true)
	return true
end

function script_properties()
	local props = obs.obs_properties_create()

	obs.obs_properties_add_float(props, "initial_cost", "Initial Cost", 0, 100000000, 0)
	obs.obs_properties_add_float(props, "salary", "Average salary", 1, 100000000, 1)
	obs.obs_properties_add_int(props, "participants", "Number of participants", 1, 100000000, 1)
	obs.obs_properties_add_bool(props, "show_participants", "Show the participant count")
	obs.obs_properties_add_text(props, "text_prefix", "Text prefix", obs.OBS_TEXT_DEFAULT)
	obs.obs_properties_add_text(props, "text_suffix", "Text suffix", obs.OBS_TEXT_DEFAULT)

	local p = obs.obs_properties_add_list(props, "source", "Text source", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
	local sources = obs.obs_enum_sources()
	if sources ~= nil then
		for _, source in ipairs(sources) do
			source_id = obs.obs_source_get_unversioned_id(source)
			if source_id == "text_gdiplus" or source_id == "text_ft2_source" then
				local name = obs.obs_source_get_name(source)
				obs.obs_property_list_add_string(p, name, name)
			end
		end
	end
	obs.source_list_release(sources)

	obs.obs_properties_add_button(props, "pause_button", "Start/Stop", pause_button_clicked)
	obs.obs_properties_add_button(props, "reset_button", "Reset", reset_button_clicked)

	return props
end

function script_update(settings)
	source_name = obs.obs_data_get_string(settings, "source")
	participants = obs.obs_data_get_int(settings, "participants")
	salary = obs.obs_data_get_double(settings, "salary")
	initial_cost = obs.obs_data_get_double(settings, "initial_cost")
	show_participants = obs.obs_data_get_bool(settings, "show_participants")
	prefix = obs.obs_data_get_string(settings, "text_prefix")
	suffix = obs.obs_data_get_string(settings, "text_suffix")

	print("updating script")
	print(string.format("suffix: %s prefix: %s done %s %s", suffix, prefix, 
		obs.obs_data_get_default_string(settings, "text_prefix"),
		obs.obs_data_get_string(settings, "text_prefix")
	))
end

function script_defaults(settings)
	obs.obs_data_set_default_int(settings, "participants", 1)
	obs.obs_data_set_default_double(settings, "salary", 100000)
	obs.obs_data_set_default_double(settings, "initial_cost", 0.0)
	obs.obs_data_set_default_bool(settings, "show_participants", true)
	obs.obs_data_set_default_string(settings, "text_prefix", default_prefix)
	obs.obs_data_set_default_string(settings, "text_suffix", default_suffix)
end

function save_hotkey(settings, id, name)
	local data = obs.obs_hotkey_save(id)
	obs.obs_data_set_array(settings, name, data)
	obs.obs_data_array_release(data)
end

function script_save(settings)
	save_hotkey(settings, hotkey_id_reset, "reset_timer")
	save_hotkey(settings, hotkey_id_pause, "pause_timer")
	save_hotkey(settings, hotkey_id_inc_participants, "increment_participants")
	save_hotkey(settings, hotkey_id_dec_participants, "decrement_participants")
end

function setup_hotkey(settings, name, text, func)
	local hotkey_id = obs.obs_hotkey_register_frontend(name, text, reset)
	local hotkey_save_array_reset = obs.obs_data_get_array(settings, name)
	obs.obs_hotkey_load(hotkey_id_reset, hotkey_save_array_reset)
	obs.obs_data_array_release(hotkey_save_array_reset)
	return hotkey_id
end

function script_load(settings)
	local sh = obs.obs_get_signal_handler()
	obs.signal_handler_connect(sh, "source_activate", source_activated)
	obs.signal_handler_connect(sh, "source_deactivate", source_deactivated)

	hotkey_id_reset = setup_hotkey(settings, "reset_timer", "Reset Timer", reset)
	hokey_id_pause = setup_hotkey(settings, "pause_timer", "Pause/Resume", on_pause)
	hotkey_id_inc_participants = setup_hotkey(settings, "increment_participants", "Increment meeting participants", inc_participants)
	hotkey_id_dec_participants = setup_hotkey(settings, "decrement_participants", "Decrement meeting participants", dec_participants)

	script_update(settings)
end
