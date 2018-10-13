print("charge\n")

tmr_charge = 5
full_tick = 0
charge_tick = 30
charge_state = 'unknown'
pin_full = 12
pin_charger = 3

function charge_control()
   local v = gpio.read(pin_full)
   if cont == gpio.HIGH then
      full_tick = full_tick + 1
   else
      full_tick = 0
   end

   if full_tick >= charge_tick then
      gpio.write(pin_charger, gpio.HIGH)
      local tm = rtctime.epoch2cal(rtctime.get() + 28800)
      charge_state = string.format("end %04d-%02d-%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"])
   end
end

-- tmr set
tmr.alarm(tmr_charge, 60000, tmr.ALARM_AUTO, charge_control)
