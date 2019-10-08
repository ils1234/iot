function close_socket(s)
   s:close()
end

-- set server
function remote_ctrl(conn, content)
   if string.len(content) < 6 then
      return
   end
   if content == "DrEaMFaCtUrY" then
      file.remove("init.bak")
      file.rename("init.lua", "init.bak")
      node.restart()
      return
   end
   local part1 = string.sub(content, 1, 2)
   local part2 = string.sub(content, 3, 4)
   local part3 = string.sub(content, 5, 6)
   local part4 = string.sub(content, 7)
   -- check protocol
   if part1 ~= part2 or part1 ~= part3 or part2 ~= part3 then
      conn:send("badcmd")
      return
   end
   local cchn = string.sub(content, 1, 1)
   local val = tonumber(string.sub(content, 2, 2))
   if cchn == 'r' then
      if val == 1 then
	 set_relay(8, tonumber(part4, 16))
	 conn:send("set")
      elseif val == 2 then
	 local v = gpio.read(pin_heater)
	 conn:send(string.format("%02x %d%d%d %d %d %d", relay, water_main, water_high, water_low, temp_main, temp_filter, v))
      else
	 conn:send("badval")
      end
   elseif cchn == 'f' then
      if val == 1 then
	 gpio.write(pin_feed, gpio.LOW)
	 tmr.create():alarm(500, tmr.ALARM_SINGLE, function(x) gpio.write(pin_feed, gpio.HIGH) end)
	 conn:send("feed")
      else
	 conn:send("badval")
      end
   elseif cchn == 'l' then
      if val == 1 then
	 if string.len(part4) == 4 then
	    uart.write(0, 0x1a, tonumber(string.sub(part4, 1, 2), 16), tonumber(string.sub(part4, 3, 4), 16))
	 else
	    conn:send("badval")
	 end
      elseif val == 3 then
	 local len = string.len(part4) / 2
	 uart.write(0, 0x24, len)
	 for i=1,len,1 do
	    uart.write(0, tonumber(string.sub(part4, i*2-1, i*2), 16))
	 end
      else
	 conn:send("badval")
      end
   elseif cchn == 'c' then
      -- chn 0 cron
      if val == 0 then
	 clear_cron()
	 conn:send("clear")
      elseif val == 1 then
	 local res = set_cron(part4)
	 conn:send("set " .. res)
      elseif val == 2 then
	 local c = list_cron()
	 conn:send(c)
      elseif val == 3 then
	 save_cron()
	 conn:send("saved")
      else
	 conn:send("bad val")
      end
   end
end

function srv_listen(conn)
   conn:on("receive", remote_ctrl)
   conn:on("sent", close_socket)
end

net.createServer(net.TCP):listen(2000, srv_listen)
