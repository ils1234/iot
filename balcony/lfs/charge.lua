local pin_charger, pin_full = ...
local charge_tick = 60
local full_tick = 0
local start_time = 0
local end_time = 0

get_charge = function()
   local v = gpio.read(pin_charger)
   local f = gpio.read(pin_full);
   return v,f,full_tick,start_time,end_time
end

start_charge = function()
   full_tick = 0
   gpio.write(pin_charger, gpio.LOW)
   start_time = rtctime.get()
   end_time = 0
end

stop_charge = function()
   gpio.write(pin_charger, gpio.HIGH)
   end_time = rtctime.get()
end

local auto_stop_charge
auto_stop_charge = function()
   local v = gpio.read(pin_full)
   if v == gpio.HIGH then
      full_tick = full_tick + 1
   else
      full_tick = 0
   end

   if full_tick >= charge_tick then
      stop_charge()
   end
end

-- tmr set
do
   gpio.mode(pin_charger, gpio.OUTPUT)
   gpio.mode(pin_full, gpio.INPUT)
   gpio.write(pin_charger, gpio.HIGH)
   tmr.create():alarm(60000, tmr.ALARM_AUTO, auto_stop_charge)
end
