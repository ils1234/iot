local pin_relay, pin_led = ...
temp_limit = 24
current = 0
relay = 'off'
local wait_time = 20
local work_time = 20

set_heater_on = function()
   current = 0
   gpio.write(pin_led, gpio.LOW)
   gpio.write(pin_relay, gpio.HIGH)
   relay = 'on'
end

set_heater_off = function()
   current = 0
   gpio.write(pin_led, gpio.HIGH)
   gpio.write(pin_relay, gpio.LOW)
   relay = 'off'
end

local heater_ctrl = function()
   current = current + 1
   local v = gpio.read(pin_relay)
   if v == gpio.HIGH then
      if current >= work_time then
         set_heater_off()
      end
   else
      if current >= wait_time and temp < temp_limit then
         set_heater_on()
      end
   end
end

do
   gpio.mode(pin_relay, gpio.OUTPUT)
   gpio.mode(pin_led, gpio.OUTPUT)
   gpio.write(pin_relay, gpio.LOW)
   gpio.write(pin_led, gpio.HIGH)
   
   tmr.create():alarm(60000, tmr.ALARM_AUTO, heater_ctrl)
end
