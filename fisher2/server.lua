print('server\n')

-- out 12345678
-- in abc
pin = {[49]=0, [50]=3, [51]=4, [52]=5, [53]=6, [54]=7, [55]=8, [56]=9,
       [65]=1, [66]=2, [67]=12,
       [70]=0, [99]=0, [116]=0}

function close_socket(s)
   s:close()
end

-- set server
function remote_ctrl(conn, content)
   if string.len(content) < 6 then
      print("bad size")
      return
   end
   if content == "DrEaMFaCtUrY" then
      file.remove("init.bak")
      file.rename("init.lua", "init.bak")
      print("factury mode")
      node.restart()
      return
   elseif content == "ESHELL" then
      uart.alt(0)
      return
   end
   local part1 = string.sub(content, 1, 2)
   local part2 = string.sub(content, 3, 4)
   local part3 = string.sub(content, 5, 6)
   local part4 = string.sub(content, 7)
   -- check protocol
   if part1 ~= part2 or part1 ~= part3 or part2 ~= part3 then
      conn:send("it works")
      print("bad protocol")
      return
   end
   local cchn = string.byte(content, 1)
   local val = tonumber(string.sub(content, 2, 2))
   local chn = pin[cchn]
   if chn == nil then
      conn:send("bad chn")
      print("bad chn " .. cchn)
      return
   end
   if cchn == 49 then
      -- chn 0|cchn 49 auto control
      if val == 0 then
         local t = string.format("%d.%03d", temp, temp_dec)
         conn:send(t)
         print(t)
      elseif val == 1 then
         local t = string.format("%d.%03d", temp2, temp2_dec)
         conn:send(t)
         print(t)
      elseif val == 2 then
         local v = gpio.read(chn)
         if v == gpio.HIGH then
            print("heater is off")
            conn:send("off")
         else
            print("heater is on")
            conn:send("on")
         end
      elseif val == 3 then
         local t = string.format("%d", temp_limit)
         conn:send(t)
         print(t)
      elseif val == 4 then
         temp_limit = tonumber(part4)
	 conn:send("ok")
      else
	 conn:send("bad val" .. val)
      end
   elseif cchn >= 50 and cchn <= 56 then
      -- cchn 50-56, output, on|off|status
      if val == 0 then
         gpio.write(chn, gpio.HIGH)
         print(chn .. " off")
         conn:send("off")
      elseif val == 1 then
         gpio.write(chn, gpio.LOW)
         print(chn .. " on")
         conn:send("on")
      elseif val == 2 then
         local v = gpio.read(chn)
         if v == gpio.HIGH then
            print(chn .. " was off")
            conn:send("off")
         else
            print(chn .. " was on")
            conn:send("on")
         end
      else
         conn:send("bad val")
         print("bad val " .. val)
      end
   elseif cchn >=65 and cchn <= 67 then
      -- cchn 97-99, input, status
      local v = gpio.read(chn)
      if v == gpio.HIGH then
         print(chn .. " was off")
         conn:send("off")
      else
         print(chn .. " was on")
         conn:send("on")
      end
   elseif cchn == 70 then
      -- addwater state
      if val == 0 then
	 conn:send(tostring(wait_time))
	 print("wait " .. wait_time)
      elseif val == 1 then
	 wait_time = tonumber(part4)
	 conn:send("ok")
	 print("set wait " .. wait_time)
      elseif val == 2 then
	 conn:send(tostring(work_time))
	 print("work " .. work_time)
      elseif val == 3 then
	 work_time = tonumber(part4)
	 conn:send("ok")
	 print("set work " .. work_time)
      elseif val == 4 then
	 conn:send(tostring(addwater_wait))
	 print("current wait " .. addwater_wait)
      elseif val == 5 then
	 conn:send(tostring(addwater_work))
	 print("current work " .. addwater_work)
      elseif val == 6 then
	 conn:send(addwater_state)
         print("current state " .. addwater_state)
      else
	 conn:send("bad val" .. val)
      end
   elseif cchn == 99 then
      -- chn 0 cron
      if val == 0 then
	 clear_cron()
	 conn:send("clear")
	 print("clear cron")
      elseif val == 1 then
	 local res = set_cron(part4)
	 conn:send("set " .. res)
	 print("set cron" .. res)
      elseif val == 2 then
	 local c = list_cron()
	 conn:send(c)
	 print("list cron")
      elseif val == 3 then
	 save_cron()
	 conn:send("saved")
	 print("save cron")
      else
	 conn:send("bad val")
	 print("bad val " .. val)
      end
   elseif cchn == 116 then
      local tm = rtctime.epoch2cal(rtctime.get())
      local time_str = string.format("%04d-%02d-%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"])
      conn:send(time_str)
      print(time_str)
   end
end

function srv_listen(conn)
   conn:on("receive", remote_ctrl)
   conn:on("sent", close_socket)
end

srv = net.createServer(net.TCP)
srv:listen(2000, srv_listen)
