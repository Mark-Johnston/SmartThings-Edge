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
local log = require "log"
local devices = {
    AEOTEC = {
        MATCHING_MATRIX = {
            mfrs = 0x0086,
            product_types = {0x0102, 0x0002},
            product_ids = {0x005F}
        },
        PARAMETERS = {
            g1clamp1W = {parameter_number = 111, size = 4},
            zwaveNotificationStatus = {parameter_number = 2, size = 1},
            indicatorNotification = {parameter_number = 3},
            soundNotificationStatus = {parameter_number = 4, size = 1},
            tempReportInterval = {parameter_number = 20, size = 2},
            tempReportHysteresis = {parameter_number = 21, size = 2},  
            temperatureThreshold = {parameter_number = 30, size = 2},
            overheatInterval = {parameter_number = 31, size = 2},
            outOfRange = {parameter_number = 32, size = 2}
        }
    }
}

local preferences = {}

preferences.get_device_parameters = function(zw_device)
    for _, device in pairs(devices) do
log.info("mj-asdfasdfaf", device.MATCHING_MATRIX.mfrs, device.MATCHING_MATRIX.product_types, device.MATCHING_MATRIX.product_ids)
        if zw_device:id_match(
            device.MATCHING_MATRIX.mfrs,
            device.MATCHING_MATRIX.product_types,
            device.MATCHING_MATRIX.product_ids) then
			log.info("mj-matched in get-device-parameters", device.PARAMETERS)
            return device.PARAMETERS
        end
    end
    return nil
end

preferences.to_numeric_value = function(new_value)
    local numeric = tonumber(new_value)
    if numeric == nil then -- in case the value is boolean
        numeric = new_value and 1 or 0
    end
	log.info("mj-to_numeric-value", numeric, new_value)
    return numeric
end

return preferences