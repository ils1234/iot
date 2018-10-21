print("charge\n")

full_tick = 0
charge_tick = 30
start_time = 'unknown'
end_time = 'unknown'

function charge_start()
   full_tick = 0
   gpio.write(pin_charger, gpio.LOW)
   local tm = rtctime.epoch2cal(rtctime.get() + 28800)
   start_time = string.format("%04d-%02d-%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"])
   end_time = 'unknown'
end

function charge_stop()
   gpio.write(pin_charger, gpio.HIGH)
   local tm = rtctime.epoch2cal(rtctime.get() + 28800)
   end_time = string.format("%04d-%02d-%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"])
end

function charge_autostop()
   local v = gpio.read(pin_full)
   if v == gpio.HIGH then
      full_tick = full_tick + 1
   else
      full_tick = 0
   end

   if full_tick >= charge_tick then
      gpio.write(pin_charger, gpio.HIGH)
      local tm = rtctime.epoch2cal(rtctime.get() + 28800)
      end_time = string.format("%04d-%02d-%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"])
   end
end

-- tmr set
tmr.alarm(tmr_charge, 60000, tmr.ALARM_AUTO, charge_autostop)
