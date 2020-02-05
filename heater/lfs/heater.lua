local pin_relay, pin_key, pin_led, pin_led2 = ...
temp_limit = 24
current = 0
local wait_time = 20
local work_time = 20

set_heater_on = function()
   current = 0
   gpio.write(pin_led2, gpio.LOW)
   gpio.write(pin_relay, gpio.HIGH)
end

set_heater_off = function()
   current = 0
   gpio.write(pin_led2, gpio.HIGH)
   gpio.write(pin_relay, gpio.LOW)
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

local led_ctrl = function()
   if temp < temp_limit then
      local v = gpio.read(pin_led)
      if v == gpio.HIGH then
         gpio.write(pin_led, gpio.LOW)
      else
         gpio.write(pin_led, gpio.HIGH)
      end
   else
      gpio.write(pin_led, gpio.HIGH)
   end
end

button_trig = function(level, when)
   gpio.trig(pin_key)
   set_heater_on()
   tmr.create():alarm(500, tmr.ALARM_SINGLE, function()
                         gpio.trig(pin_key, "down", button_trig)
                                             end)
end

do
   gpio.mode(pin_relay, gpio.OUTPUT)
   gpio.mode(pin_key, gpio.INT, gpio.PULLUP)
   gpio.mode(pin_led, gpio.OUTPUT)
   gpio.mode(pin_led2, gpio.OUTPUT)
   gpio.write(pin_relay, gpio.LOW)
   gpio.write(pin_led, gpio.HIGH)
   gpio.write(pin_led2, gpio.HIGH)
   gpio.trig(pin_key, "down", button_trig)
   
   tmr.create():alarm(60000, tmr.ALARM_AUTO, heater_ctrl)
   tmr.create():alarm(1000, tmr.ALARM_AUTO, led_ctrl)
end
