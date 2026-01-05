local mp = require("mp")

local function toggle_osc_visibility()
	-- read current visibility from script-opts (defaults to "auto" if unset)
	local v = mp.get_property_native("user-data/osc/visibility") or "auto"

	-- some builds keep the value in script-opts instead:
	-- local v = mp.get_property("script-opts/osc-visibility") or "auto"

	if v == "always" then
		mp.commandv("script-message", "osc-visibility", "auto")
	else
		mp.commandv("script-message", "osc-visibility", "always")
	end
end

mp.register_script_message("osc-toggle-always-auto", toggle_osc_visibility)
