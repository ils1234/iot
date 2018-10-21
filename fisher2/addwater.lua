print('addwater\n')

wait_time = 30
work_time = 10
addwater_work = 0
addwater_wait = 0
addwater_state = "unknown"

function addwater_stop()
   -- stop tmr and pump
   tmr.stop(tmr_addwater)
   gpio.write(pin_addwater, gpio.HIGH)
end

function addwater_control()
   -- stop if water enough
   local water_level = gpio.read(pin_main_water_level)
   if water_level == gpio.HIGH then
      addwater_stop()
      addwater_state = "done"
      return
   end
   -- pause if filter water high
   water_level = gpio.read(pin_high_level)
   if water_level == gpio.HIGH then
      gpio.write(pin_addwater, gpio.HIGH)
      addwater_wait = wait_time
      addwater_state = "full"
      return
   end
   -- pass if temp low
   if temp < temp_limit_low or temp == temp_limit_low and temp_dec <= 900 then
      gpio.write(pin_addwater, gpio.HIGH)
      addwater_wait = wait_time
      addwater_state = "cold"
      return
   end
   -- add / wait
   if addwater_wait > 0 then
      addwater_wait = addwater_wait - 1
      gpio.write(pin_addwater, gpio.HIGH)
      addwater_state = "wait"
      return
   elseif addwater_work == 0 then
      addwater_work = work_time
      addwater_state = "topump"
      return
   end
   if addwater_work > 0 then
      addwater_work = addwater_work - 1
      gpio.write(pin_addwater, gpio.LOW)
      if addwater_work == 0 then
	 addwater_wait = wait_time
	 addwater_state = "towait"
      else
	 addwater_state = "pump"
      end
   end
end

function key_addwater()
   local running
   local mode

   running, mode = tmr.state(tmr_addwater)
   if running then
      addwater_stop()
      addwater_state = "stop"	 
   else
      addwater_work = 5
      addwater_wait = 0
      tmr.alarm(tmr_addwater, 1000, tmr.ALARM_AUTO, addwater_control)
      addwater_state = "start"
   end
end
