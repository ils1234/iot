local pin_clock,pin_hcsr = ...
local clock_mode = 1
local off_wait = 120
local curr_wait = 120
local hcsr_trig

clock_on = function()
   gpio.write(pin_clock, gpio.HIGH)
end

clock_off = function()
   gpio.write(pin_clock, gpio.LOW)
end

hcsr_trig = function()
   gpio.write(pin_clock, gpio.HIGH)
   curr_wait = off_wait
end

set_clock_mode_day = function()
   clock_mode = 1
   clock_on()
end

set_clock_mode_night = function()
   clock_mode = 2
end

do
   gpio.mode(pin_clock, gpio.OUTPUT)
   gpio.mode(pin_hcsr, gpio.INT)
   gpio.write(pin_clock, gpio.HIGH)
   gpio.trig(pin_hcsr, "up", hcsr_trig)

   tmr.create():alarm(1000, tmr.ALARM_AUTO,
                      function()
                         if clock_mode == 2 then
                            curr_wait = curr_wait - 1
                            if curr_wait == 0 then
                               clock_off()
                            end
                         end
                      end)
end
