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
		--Need to do parameters 2 - think we should retrofit that depending on demand
            valueg1 = {parameter_number = 101, size = 4},
            valueg2 = {parameter_number = 102, size = 4},
            valueg3 = {parameter_number = 103, size = 4},
			refreshOnTimeOrQuantum = {parameter_number = 3, size = 1},     -- done
			wattageChangeWholeHEM = {parameter_number = 4, size = 2},     -- done
			c1WattageChange = {parameter_number = 5, size = 2},     -- done
			c2WattageChange = {parameter_number = 6, size = 2},     -- done
			c3WattageChange = {parameter_number = 7, size = 2},     -- done
			percentageChangeWholeHEM = {parameter_number = 8, size = 1},     -- done
			c1PercentageChange = {parameter_number = 9, size = 1},  -- done
			c2PercentageChange = {parameter_number = 10, size = 1}, -- done
			c3PercentageChange = {parameter_number = 11, size = 1}, -- done
			c1RefreshInterval = {parameter_number = 111, size = 4}, -- done
			c2RefreshInterval = {parameter_number = 112, size = 4}, -- done
			c3RefreshInterval = {parameter_number = 113, size = 4}  -- done
        }
    }
}

local preferences = {}

preferences.get_device_parameters = function(zw_device)
    for _, device in pairs(devices) do
        if zw_device:id_match(
            device.MATCHING_MATRIX.mfrs,
            device.MATCHING_MATRIX.product_types,
            device.MATCHING_MATRIX.product_ids) then
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
    return numeric
end

return preferences