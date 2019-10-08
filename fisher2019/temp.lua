t = require("ds18b20")
pin_ds = 1
pin_heater = 11
temp_main = 271000
temp_filter = 271000

--set heater io
gpio.mode(pin_heater, gpio.OUTPUT)
gpio.write(pin_heater, gpio.HIGH)

--ds_addr = {"28:FF:81:E9:73:16:05:E6", "28:FF:53:F0:C1:17:04:F9"}
--init first call : t:read_temp(readout, 1, 'C', true, true)
function readout(temp)
   for addr, temp in pairs(temp) do
      if addr:byte(8,8) == 0xe6 then
	 temp_main = temp
      elseif addr:byte(8,8) == 0xf9 then
	 temp_filter = temp
      end
      --heater control
      local v = gpio.read(pin_heater)
      if v == gpio.LOW and temp_main >= 271000 then
	 gpio.write(pin_heater, gpio.HIGH)
      elseif v == gpio.HIGH and temp_main <= 269000 then
	 gpio.write(pin_heater, gpio.LOW)
      end
  end
end

tmr.create():alarm(2000, tmr.ALARM_AUTO, function() t:read_temp(readout, pin_ds) end)
