print('key\n')

key_volt = {{646,666},{758,778},{868,888},{980,1000},{1018,1024},{538,558},{431,451},{319,339},{211,231},{99,119}}

-- f1 light
function key_light()
   local v = gpio.read(pin_light)
   if v == gpio.LOW then
      gpio.write(pin_light, gpio.HIGH)
      send_client('l0l0l0')
   else
      gpio.write(pin_light, gpio.LOW)
      send_client('l1l1l1')
   end
end

-- f2 bulb
function key_bulb()
   client_do('b2b2b2', 'b0b0b0', 'b1b1b1')
end

-- f3 fog
function key_fog()
   local v = gpio.read(pin_fog)
   if v == gpio.HIGH then
      gpio.write(pin_fog, gpio.LOW)
   else
      gpio.write(pin_fog, gpio.HIGH)
   end
end

-- f4 wave
function key_wave()
   local v = gpio.read(pin_wave)
   if v == gpio.HIGH then
      gpio.write(pin_wave, gpio.LOW)
   else
      gpio.write(pin_wave, gpio.HIGH)
   end
end

-- f5 socket
function key_socket()
   client_do('s2s2s2', 's0s0s0', 's1s1s1')
end

-- f6 filter pump
function key_filter()
   local v = gpio.read(pin_filter)
   if v == gpio.HIGH then
      gpio.write(pin_filter, gpio.LOW)
   else
      gpio.write(pin_filter, gpio.HIGH)
   end
end

-- f7 camera power
function key_camera()
   local v = gpio.read(pin_camera)
   if v == gpio.HIGH then
      gpio.write(pin_camera, gpio.LOW)
   else
      gpio.write(pin_camera, gpio.HIGH)
   end
end

-- f8 manual add water
function key_pump()
   tmr.stop(tmr_addwater)
   local v = gpio.read(pin_addwater)
   if v == gpio.HIGH then
      addwater_stop()
   else
      gpio.write(pin_addwater, gpio.HIGH)
   end
end

-- f10 add 1 temperature
function key_addtemp()
   if temp_limit >= 32 then
      temp_limit_low = 17
      temp_limit = 18
   else
      temp_limit = temp_limit + 1
      temp_limit_low = temp_limit_low + 1
   end
end

key_function = {key_light, key_bulb, key_fog, key_wave, key_socket, key_filter, key_camera, key_pump, key_addwater, key_addtemp}

current_key = 0
nop_cnt = 0

-- key callback
function key_control()
   if nop_cnt > 0 then
      nop_cnt = nop_cnt - 1
      return
   end
   local volt = adc.read(0)
   for k,v in pairs(key_volt) do
      if volt >= v[1] and volt <= v[2] then
         if current_key == k then
            current_key = 0
	    nop_cnt = 4
            key_function[k]()
         else
            current_key = k
         end
	 return
      end
   end
   current_key = 0
end

-- tmr set
tmr.alarm(tmr_key, 300, tmr.ALARM_AUTO, key_control)
