local pin_led,pin_sw,pin_dir,pin_win = ...
local status = 0
-- 0-stop/top/bottom, 1-down, 2-up
local position = "stop"
local blink

get_curtain = function()
   local win = gpio.read(pin_win) 
   return position,win
end

blink = function()
   gpio.write(pin_led, gpio.LOW)
   tmr.create():alarm(1000, tmr.ALARM_SINGLE, function()
                         gpio.write(pin_led, gpio.HIGH)
                                              end)
end

curtain_down = function()
   if status ~= 0 then
      status = 0
      position = "stop"
      gpio.write(pin_sw, gpio.HIGH)
      gpio.write(pin_dir, gpio.HIGH)
      return
   end
   local win = gpio.read(pin_win)
   if win == gpio.HIGH then
      blink()
      return
   end
   status = 1
   position = "down"
   gpio.write(pin_dir, gpio.LOW)
   gpio.write(pin_sw, gpio.LOW)
   tmr.create():alarm(90000, tmr.ALARM_SINGLE, function()
                         status = 0
                         position = "bottom"
                         gpio.write(pin_sw, gpio.HIGH)
                         gpio.write(pin_dir, gpio.HIGH)
                                               end)
end

curtain_up = function()
   if status ~= 0 then
      status = 0
      position = "stop"
      gpio.write(pin_sw, gpio.HIGH)
      gpio.write(pin_dir, gpio.HIGH)
      return
   end
   win = gpio.read(pin_win)
   if win == gpio.HIGH then
      blink()
      return
   end
   status = 2
   position = "up"
   gpio.write(pin_dir, gpio.HIGH)
   gpio.write(pin_sw, gpio.LOW)
   tmr.create():alarm(90000, tmr.ALARM_SINGLE, function()
                         status = 0
                         position = "top"
                         gpio.write(pin_sw, gpio.HIGH)
                         gpio.write(pin_dir, gpio.HIGH)
                                               end)
end

do
   gpio.mode(pin_led, gpio.OUTPUT)
   gpio.mode(pin_sw, gpio.OUTPUT)
   gpio.mode(pin_dir, gpio.OUTPUT)
   gpio.mode(pin_win, gpio.INPUT, gpio.PULLUP)

   gpio.write(pin_led, gpio.HIGH)
   gpio.write(pin_sw, gpio.HIGH)
   gpio.write(pin_dir, gpio.HIGH)
end
