local pin_ds = ...
local t = require("ds18b20")
local temp_main = 263000
-- ds_addr = {"28:FF:89:42:75:16:03:E9"}
--init first call : t:read_temp(readout, 1, 'C', true, true)

get_temp = function()
   return temp_main
end

readout = function(temp)
   for addr, temp in pairs(temp) do
      temp_main = temp
   end
end

do
   --set heater io
   tmr.create():alarm(2000, tmr.ALARM_AUTO, function() t:read_temp(readout, pin_ds) end)
end
