print('server\n')

server_chn = {h=1, s=-1, c=-1, t=-1}

function close_socket(s)
   s:close()
end

-- set server
function remote_ctrl(conn, content)
   if string.len(content) < 6 then
      print("bad size")
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
   local cchn = string.sub(content, 1, 1)
   local val = tonumber(string.sub(content, 2, 2))
   local chn = server_chn[cchn]
   if chn == nil then
      conn:send("bad chn")
      print("bad chn " .. cchn)
      return
   end
   if cchn == 'c' then
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
   elseif cchn == 'h' then
      -- chn 1, output on|off|status
      -- not support 0 and 1, control by temp_limit
      if val == 2 then
         local v = gpio.read(chn)
         if v == gpio.HIGH then
            print("heater was on")
            conn:send("on")
         else
            print("heater was off")
            conn:send("off")
         end
      elseif val == 3 then
	 conn:send(tostring(wait_time))
	 print("wait " .. wait_time)
      elseif val == 4 then
	 wait_time = tonumber(part4)
	 conn:send("ok")
	 print("set wait " .. wait_time)
      elseif val == 5 then
	 conn:send(tostring(work_time))
	 print("work " .. work_time)
      elseif val == 6 then
	 work_time = tonumber(part4)
	 conn:send("ok")
	 print("set work " .. work_time)
      elseif val == 7 then
	 conn:send(tostring(heater_wait))
	 print("current wait " .. heater_wait)
      elseif val == 8 then
	 conn:send(tostring(heater_work))
	 print("current work " .. heater_work)
      elseif val == 9 then
	 if burn == true then
	    conn:send('on')
	 else
	    conn:send('off')
	 end
      else
         conn:send("bad val")
         print("bad val " .. val)
      end
   elseif cchn == 's' then
      if val == 2 then
	 conn:send(tostring(temp_limit))
	 print("temp set " .. temp_limit)
      elseif val == 3 then
	 local v = string.format("%d.%03d", temp, temp_dec)
	 conn:send(v)
	 print("temp now " .. v)
      else
         conn:send("bad val")
         print("bad val " .. val)
      end
   elseif cchn == 't' then
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
