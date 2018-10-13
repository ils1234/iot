print('key\n')

tmr_key = 3
pin_wave = 3
pin_fog = 5
pin_filter = 6
pin_camera = 7
pin_light = 8

key_volt = {{646,666},{758,778},{868,888},{980,1000},{1018,1024},{538,558},{431,451},{319,339},{211,231},{99,119}}

-- f1 light
function key_mainlight()
   local soc = net.createConnection(net.TCP, 0)
   soc:on("connection", function(sck, cont)
      sck:send("020202")
   end)
   soc:on("receive", function(sck, cont)
      sck:close()
      local cmd	     
      if cont == "off" then
          cmd = "010101"
      else
          cmd = "000000"
      end
      local soc2 =  net.createConnection(net.TCP, 0)
      soc2:on("connection", function(sck2, cont2)
         sck2:send(cmd)
      end)
      soc2:on("receive", function(sck2, cont2)
          sck2:close()
	  print(cont2)
      end)
      soc2:connect(client_port, client_host)
   end)
   soc:connect(client_port, client_host)
end

-- f2 small light
function key_smalllight()
   local v = gpio.read(pin_light)
   if v == gpio.HIGH then
      gpio.write(pin_light, gpio.LOW)
   else
      gpio.write(pin_light, gpio.HIGH)
   end
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
   local soc = net.createConnection(net.TCP, 0)
   soc:on("connection", function(sck, cont)
      sck:send("121212")
   end)
   soc:on("receive", function(sck, cont)
      sck:close()
      local cmd
      if cont == "off" then
          cmd = "111111"
      else
          cmd = "101010"
      end
      local soc2 =  net.createConnection(net.TCP, 0)
      soc2:on("connection", function(sck2, cont2)
         sck2:send(cmd)
      end)
      soc2:on("receive", function(sck2, cont2)
          sck2:close()
	  print(cont2)
      end)
      soc2:connect(client_port, client_host)
   end)
   soc:connect(client_port, client_host)
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
      gpio.write(pin_addwater, gpio.LOW)
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

key_function = {key_mainlight, key_smalllight, key_fog, key_wave, key_socket, key_filter, key_camera, key_pump, key_addwater, key_addtemp}

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
