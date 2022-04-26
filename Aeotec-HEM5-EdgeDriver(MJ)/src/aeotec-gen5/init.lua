-- Copyright 2021 SmartThings
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

local capabilities = require "st.capabilities"
--- @type st.zwave.CommandClass.Configuration
local Configuration = (require "st.zwave.CommandClass.Configuration")({ version=1 })
--- @type st.zwave.CommandClass.Meter
local Meter = (require "st.zwave.CommandClass.Meter")({ version=3 })
--- @type st.zwave.CommandClass
local cc = require "st.zwave.CommandClass"
local log = require "log"
local preferencesMap = require "preferences"


local AEOTEC_GEN5_FINGERPRINTS = {
  {mfr = 0x0086, prod = 0x0102, model = 0x005F},  -- Aeotec Home Energy Meter (Gen5) US
  {mfr = 0x0086, prod = 0x0002, model = 0x005F},  -- Aeotec Home Energy Meter (Gen5) EU
}

local POWER_UNIT_WATT = "W"
local ENERGY_UNIT_KWH = "kWh"
local VOLTAGE_UNIT_V = "V"

--- Handle preference changes
---
--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
--- @param event table
--- @param args
local function info_changed(driver, device, event, args)
  local preferences = preferencesMap.get_device_parameters(device)
log.info("mj-info_changed - just started routine")
 if preferences then
 log.info("mj-info_changed - passed 'if preferences'")
    for id, value in pairs(device.preferences) do
	log.info("mj-info_changed", id, value, args.old_st_store.preferences[id], device.preferences[id])
      if args.old_st_store.preferences[id] ~= value and preferences[id] then
        local new_parameter_value = preferencesMap.to_numeric_value(device.preferences[id])
log.info("mj-info_changed - about to send zwave stuff like:", preferences[id].parameter_number, preferences[id].size, new_parameter_value)

--          device:send(Configuration:Set({parameter_number = preferences[id].parameter_number, size = preferences[id].size, configuration_value = new_parameter_value}))
      end
    end
  end
end


local function can_handle_aeotec_gen5_meter(opts, driver, device, ...)
  for _, fingerprint in ipairs(AEOTEC_GEN5_FINGERPRINTS) do
    if device:id_match(fingerprint.mfr, fingerprint.prod, fingerprint.model) then
     return true
    end
  end
  return false
end

local do_configure = function (self, device)
log.info("mj-configuring the HEM params")
  device:send(Configuration:Set({parameter_number = 101, size = 4, configuration_value = 592128})) -- all clamp 1
  device:send(Configuration:Set({parameter_number = 102, size = 4, configuration_value = 1184256})) -- all clamp 2
  device:send(Configuration:Set({parameter_number = 103, size = 4, configuration_value = 2368512})) -- all clamp 3
--  device:send(Configuration:Set({parameter_number = 101, size = 4, configuration_value = 3}))   -- report total power in Watts and total energy in kWh...
--  device:send(Configuration:Set({parameter_number = 102, size = 4, configuration_value = 0}))  - -- disable group 2...
--  device:send(Configuration:Set({parameter_number = 103, size = 4, configuration_value = 0}))   -- disable group 3...
  device:send(Configuration:Set({parameter_number = 111, size = 4, configuration_value = 300})) -- ...every 5 min
  device:send(Configuration:Set({parameter_number = 112, size = 4, configuration_value = 300})) -- ...every 5 min
  device:send(Configuration:Set({parameter_number = 113, size = 4, configuration_value = 300})) -- ...every 5 min
  device:send(Configuration:Set({parameter_number = 90, size = 1, configuration_value = 0}))    -- enabling automatic reports, disabled selective reporting...
  device:send(Configuration:Set({parameter_number = 13, size = 1, configuration_value = 0}))   -- disable CRC16 encapsulation
end



function meter_report_handler(self, device, cmd)
  local event_arguments = nil
log.info("mj-in meter_report_handler", self, device, cmd)
  if cmd.args.scale == Meter.scale.electric_meter.KILOWATT_HOURS then
    event_arguments = {
      value = cmd.args.meter_value,
      unit = ENERGY_UNIT_KWH
    }
    device:emit_event_for_endpoint(
      cmd.src_channel,
      capabilities.energyMeter.energy(event_arguments)
    )
  elseif cmd.args.scale == Meter.scale.electric_meter.WATTS then
     local event_arguments = {
      value = cmd.args.meter_value,
      unit = POWER_UNIT_WATT
    }
    device:emit_event_for_endpoint(
      cmd.src_channel,
      capabilities.powerMeter.power(event_arguments)
    )
  elseif cmd.args.scale == Meter.scale.electric_meter.VOLTS then
     local event_arguments = {
      value = cmd.args.meter_value,
      unit = VOLTAGE_UNIT_V
    }
    device:emit_event_for_endpoint(
      cmd.src_channel,
      capabilities.voltageMeasurement.voltage(event_arguments)
    )
  end
end

local function component_to_endpoint(device, component_id)
  local ep_str = component_id:match("Group(%d)")
  local ep_num = ep_str and math.floor(ep_str)
  return {ep_num and tonumber(ep_num)} or {}
end
  
local function endpoint_to_component(device, ep)
  local meter_comp = string.format("Group%d", ep)
  if device.profile.components[meter_comp] ~= nil then
    return meter_comp
  else
    return "main"
  end
end

local device_init = function(self, device)
  device:set_component_to_endpoint_fn(component_to_endpoint)
  device:set_endpoint_to_component_fn(endpoint_to_component)
end


local aeotec_gen5_meter = {
  supported_capabilities = {
	capabilities.refresh
  },
  zwave_handlers = { -- added from this line
    [cc.METER] = {
      [Meter.REPORT] = meter_report_handler
    }
  }, -- to this line
  lifecycle_handlers = {
    doConfigure = do_configure,
	infoChanged = info_changed,
	init = device_init -- added this line too (don't forget comma above)
  },
  NAME = "aeotec gen5 meter",
  can_handle = can_handle_aeotec_gen5_meter
}

return aeotec_gen5_meter
