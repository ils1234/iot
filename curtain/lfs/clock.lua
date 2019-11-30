local pin_clock,pin_hcsr = ...
local clock_mode = 1
local hcsr_trig

clock_on = function()
   gpio.write(pin_clock, gpio.HIGH)
end

clock_off = function()
   gpio.write(pin_clock, gpio.LOW)
end

hcsr_trig = function()
   gpio.write(pin_clock, gpio.HIGH)
   if clock_mode == 2 then
      tmr.create():alarm(60000, tmr.ALARM_SINGLE, function()
                            clock_off()
                                                  end)
   end
end

set_clock_mode_day = function()
   clock_mode = 1
   gpio.write(pin_clock, gpio.HIGH)
end

set_clock_mode_night = function()
   clock_mode = 2
   gpio.write(pin_clock, gpio.LOW)
end

do
   gpio.mode(pin_clock, gpio.OUTPUT)
   gpio.mode(pin_hcsr, gpio.INT)
   gpio.write(pin_clock, gpio.HIGH)
   gpio.trig(pin_hcsr, "up", hcsr_trig)
end
