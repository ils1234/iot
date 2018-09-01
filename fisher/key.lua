print('key\n')

tmr_key = 3
tmr_addwater = 4

pin_main_water_level = 1
pin_high_level = 12
pin_addwater = 3
pin_wave = 4
pin_fog = 5
pin_filter = 6
pin_camera = 7
pin_light = 8

key_volt = {{646,666},{758,778},{868,888},{980,1000},{1018,1024},{538,558},{431,451},{319,339},{211,231},{99,119}}
addwater_work = 0
addwater_wait = 0

function addwater_control()
   -- stop if water enough
   local water_level = gpio.read(pin_main_water_level)
   if water_level == gpio.HIGH then
      gpio.write(pin_addwater, gpio.HIGH)
      tmr.stop(tmr_addwater)
      return
   end
   -- pause if filter water high
   water_level = gpio.read(pin_high_level)
   if water_level == gpio.HIGH then
      gpio.write(pin_addwater, gpio.HIGH)
      addwater_wait = 10
      return
   end
   -- pass if temp low
   if temp < temp_limit_low or temp == temp_limit_low and temp_dec <= 900 then
      gpio.write(pin_addwater, gpio.HIGH)
      addwater_wait = 10
      return
   end
   -- add / wait
   if addwater_wait > 0 then
      addwater_wait = addwater_wait - 1
      gpio.write(pin_addwater, gpio.HIGH)
      return
   else
      addwater_work = 3
      return
   end
   if addwater_work > 0 then
      addwater_work = addwater_work - 1
      gpio.write(pin_addwater, gpio.LOW)
      return
   else
      addwater_wait = 10
      gpio.write(pin_addwater, gpio.HIGH)
      return
   end
end

-- f1 main light
function f1()
   local soc = net.createConnection(net.TCP, 0)
   soc:on("connection", function(sck, cont)
      sck:send("020202")
   end)
   soc:on("receive", function(sck, cont)
      sck:close()
      local cmd	     
      if cont == "on" then
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
function f2()
   local v = gpio.read(pin_light)
   if v == gpio.HIGH then
      gpio.write(pin_light, gpio.LOW)
   else
      gpio.write(pin_light, gpio.HIGH)
   end
end

-- f3 fog
function f3()
   local v = gpio.read(pin_fog)
   if v == gpio.HIGH then
      gpio.write(pin_fog, gpio.LOW)
   else
      gpio.write(pin_fog, gpio.HIGH)
   end
end

-- f4 wave
function f4()
   local v = gpio.read(pin_wave)
   if v == gpio.HIGH then
      gpio.write(pin_wave, gpio.LOW)
   else
      gpio.write(pin_wave, gpio.HIGH)
   end
end

-- f5 socket
function f5()
   local soc = net.createConnection(net.TCP, 0)
   soc:on("connection", function(sck, cont)
      sck:send("121212")
   end)
   soc:on("receive", function(sck, cont)
      sck:close()
      local cmd
      if cont == "on" then
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
function f6()
   local v = gpio.read(pin_filter)
   if v == gpio.HIGH then
      gpio.write(pin_filter, gpio.LOW)
   else
      gpio.write(pin_filter, gpio.HIGH)
   end
end

-- f7 camera power
function f7()
   local v = gpio.read(pin_camera)
   if v == gpio.HIGH then
      gpio.write(pin_camera, gpio.LOW)
   else
      gpio.write(pin_camera, gpio.HIGH)
   end
end

-- f8 manual add water
function f8()
   tmr.stop(tmr_addwater)
   local v = gpio.read(pin_addwater)
   if v == gpio.HIGH then
      gpio.write(pin_addwater, gpio.LOW)
   else
      gpio.write(pin_addwater, gpio.HIGH)
   end
end

-- f9 auto add water
function f9()
   local running
   local mode

   running, mode = tmr.state(tmr_addwater)
   if running then
      -- stop tmr and pump
      tmr.stop(tmr_addwater)
      gpio.write(pin_addwater, gpio.HIGH)
   else
      addwater_work = 5
      addwater_wait = 0
      tmr.alarm(tmr_addwater, 1000, tmr.ALARM_AUTO, addwater_control)
   end
end

-- f10 add 1 temperature
function f10()
   if temp_limit >= 32 then
      temp_limit_low = 17
      temp_limit = 18
   else
      temp_limit = temp_limit + 1
      temp_limit_low = temp_limit_low + 1
   end
end

key_function = {f1, f2, f3, f4, f5, f6, f7, f8, f9, f10}

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
            key_func[k]()
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
