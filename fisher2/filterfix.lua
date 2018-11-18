print("filterfix\n")

alarm_filter_dry = false
fix_wait_time = 15
fix_work_time = 10
filter_work = 0
filter_wait = 0

function filter_ctrl()
   local v = gpio.read(pin_low_level)
   if alarm_filter_dry == false then
      if v == gpio.LOW then
	 alarm_filter_dry = true
	 filter_wait = fix_wait_time
	 filter_work = 0
      end
   else
      if filter_wait > 0 then
	 -- filter stop
	 gpio.write(pin_filter, gpio.LOW)
	 filter_wait = filter_wait - 1
	 return
      elseif filter_work == 0 then
	 filter_work = fix_work_time
	 return
      end
      if filter_work > 0 then
	 --filter on
	 gpio.write(pin_filter, gpio.HIGH)
	 filter_work = filter_work - 1
	 if filter_work == 0 then
	    -- test if ok
	    if v == gpio.HIGH then
	       alarm_filter_dry = false
	    else
	       filter_wait = fix_wait_time
	    end
	 end
      end
   end
end

-- tmr set
tmr.alarm(tmr_filter, 1000, tmr.ALARM_AUTO, filter_ctrl)
