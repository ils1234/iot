local port, pin_feed = ...

local close_socket, remote_ctrl
local v,i

cloase_socket = function(s)
   s:close()
end

-- set server
remote_ctrl = function(conn, content)
   if string.len(content) < 6 then
      return
   end
   if content == "DrEaMFaCtUrY" then
      file.remove("init0.lua")
      file.rename("init.lua", "init0.lua")
      node.restart()
      return
   end
   local part1 = string.sub(content, 1, 2)
   local part2 = string.sub(content, 3, 4)
   local part3 = string.sub(content, 5, 6)
   local part4 = string.sub(content, 7)
   -- check protocol
   if part1 ~= part2 or part1 ~= part3 or part2 ~= part3 then
      conn:send("badval")
      return
   end
   local cchn = string.sub(content, 1, 1)
   local val = tonumber(string.sub(content, 2, 2))
   if cchn == 'r' then
      if val == 1 then
         set_relay(8, tonumber(part4, 16))
         conn:send("done")
      elseif val == 2 then
         local relay,water_main,water_high,water_low = get_atmega16()
         local temp_main,temp_filter,heater_status = get_temp()
         conn:send(string.format("%02x %d%d%d %d %d %d", relay, water_main, water_high, water_low, temp_main, temp_filter, heater_status))
      elseif val == 3 or val == 4 then
         v = tonumber(part4)
         if v >=0 and v < 8 then
            set_relay(v, val - 3)
            conn:send("done")
         else
            conn:send("badval")
         end
      else
         conn:send("badval")
      end
   elseif cchn == 'f' then
      if val == 1 then
         gpio.write(pin_feed, gpio.LOW)
         tmr.create():alarm(500, tmr.ALARM_SINGLE, function(x) gpio.write(pin_feed, gpio.HIGH) end)
         conn:send("done")
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
         v = string.len(part4) / 2
         uart.write(0, 0x24, v)
         for i=1,v,1 do
            uart.write(0, tonumber(string.sub(part4, i*2-1, i*2), 16))
         end
      else
         conn:send("badval")
      end
   elseif cchn == 'c' then
      -- chn 0 cron
      if val == 0 then
         clear_cron()
         conn:send("done")
      elseif val == 1 then
         local res = set_cron(part4)
         conn:send("set " .. res)
      elseif val == 2 then
         local c = list_cron()
         conn:send(c)
      elseif val == 3 then
         save_cron()
         conn:send("done")
      else
         conn:send("badval")
      end
   end
end

do
   gpio.mode(pin_feed, gpio.OUTPUT)
   gpio.write(pin_feed, gpio.HIGH)
   net.createServer(net.TCP):listen(port, function(conn)
                                       conn:on("receive", remote_ctrl)
                                       conn:on("sent", close_socket)
                                          end)
end
