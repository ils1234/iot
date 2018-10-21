print('server\n')

-- out 12345678
server_chn = {l=0, s=1, b=2, C=3, T=0,
	      t=0, c=0}

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
   elseif cchn == 'T' then
      local t = string.format("%d.%03d", temp, temp_dec)
      conn:send(t)
      print(t)
   elseif cchn == 't' then
      local tm = rtctime.epoch2cal(rtctime.get())
      local time_str = string.format("%04d-%02d-%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"])
      conn:send(time_str)
      print(time_str)
   elseif cchn == 'l' or cchn == 's' or cchn == 'b' then
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
   elseif cchn == 'f' then
      local v = gpio.read(chn)
      if v == gpio.HIGH then
	 print("green light was on")
	 conn:send("on")
      else
	 print("green light was off")
	 conn:send("off")
      end
   elseif cchn == 'C' then
      -- charge state
      if val == 0 then
	 charge_stop()
	 conn:send('stop now')
      elseif val == 1 then
	 charge_start()
	 conn:send('start now')
      elseif val == 2 then
	 local v = gpio.read(pin_charger)
	 if v == gpio.HIGH then
	    conn:send("off")
	 else
	    local f = gpio.read(pin_full)
	    if f == gpio.HIGH then
	       conn:send("full")
	    else
	       conn:send("on")
	    end
	 end
      elseif val == 3 then
	 local v = start_time .. ' ~ ' .. end_time
	 conn:send(v)
         print(v)
      elseif val == 4 then
	 conn:send(tostring(charge_tick))
	 print("end 1min*" .. charge_tick)
      elseif val == 5 then
         charge_tick = tonumber(part4)
	 conn:send("ok")
	 print("set charge full")
      elseif val == 6 then
	 conn:send(tostring(full_tick))
	 print("tick " .. full_tick)
      else
	 conn:send("bad val" .. val)
      end
   end
end

function srv_listen(conn)
   conn:on("receive", remote_ctrl)
   conn:on("sent", close_socket)
end

srv = net.createServer(net.TCP)
srv:listen(2000, srv_listen)
