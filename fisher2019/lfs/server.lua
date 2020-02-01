local port, pin_feed = ...

local close_socket, remote_ctrl
local v,i,fd

close_socket = function(s)
   s:close()
end

-- set server
remote_ctrl = function(conn, data)
   if string.len(data) < 6 then
      return
   end
   local part1 = string.sub(data, 1, 2)
   local part2 = string.sub(data, 3, 4)
   local part3 = string.sub(data, 5, 6)
   local content = string.sub(data, 7)
   -- check protocol
   if part1 ~= part2 or part1 ~= part3 or part2 ~= part3 then
      conn:send("badarg", close_socket)
      return
   end
   part1 = nil
   part2 = nil
   part3 = nil
   local cmd = string.sub(data, 1, 1)
   local arg = tonumber(string.sub(data, 2, 2))
   if cmd == 'r' then
      if arg == 1 then
         set_relay(8, tonumber(content, 16))
         conn:send("done", close_socket)
      elseif arg == 2 then
         local relay,water_main,water_high,water_low = get_atmega16()
         local temp_main,temp_filter,heater_status = get_temp()
         conn:send(string.format("%02x %d%d%d %d %d %d", relay, water_main, water_high, water_low, temp_main, temp_filter, heater_status), close_socket)
      elseif arg == 3 or arg == 4 then
         v = tonumber(content)
         if v >= 0 and v < 8 then
            set_relay(v, arg - 3)
            conn:send("done", close_socket)
         else
            conn:send("badarg", close_socket)
         end
      elseif arg == 5 or arg == 6 then
         v = tonumber(content)
         if v >= 0 and v < 8 then
            toggle_relay(v)
            if arg == 6 then
               tmr.create():alarm(800, tmr.ALARM_SINGLE, function() toggle_relay(v) end)
            end
         end
         conn:send("done", close_socket)
      else
         conn:send("badarg", close_socket)
      end
   elseif cmd == 'f' then
      gpio.write(pin_feed, gpio.LOW)
      tmr.create():alarm(500, tmr.ALARM_SINGLE, function(x) gpio.write(pin_feed, gpio.HIGH) end)
      conn:send("done", close_socket)
   elseif cmd == 'l' then
      if arg == 1 then
         if string.len(content) == 4 then
            uart.write(0, 0x1a, tonumber(string.sub(content, 1, 2), 16), tonumber(string.sub(content, 3, 4), 16))
         else
            conn:send("badarg", close_socket)
         end
      elseif arg == 3 then
         v = string.len(content) / 2
         uart.write(0, 0x24, v)
         for i=1,v,1 do
            uart.write(0, tonumber(string.sub(content, i*2-1, i*2), 16))
         end
      else
         conn:send("badarg", close_socket)
      end
   elseif cmd == 'O' then
      if arg == 0 then
         --open file
         fd = file.open(content, 'w')
      elseif arg == 1 then
         --write line
         fd:write(content .. "\n")
      elseif arg == 2 then
         --read file 
         fd = file.open(content, 'r')
         if fd then
            while true do
               local s = fd:readline()
               if s == nil then
                  break
               end
               conn:send(s)
            end
            fd:close()
         end
         fd = nil
         conn:send('@', close_socket)
      elseif arg == 3 then
         --close file
         fd:close()
         fd = nil
      elseif arg == 4 then
         --read size
         v = file.stat(content)
         if v == nil then
            conn:send("0")
         else
            conn:send(string.format("%d", v.size), close_socket)
         end
      elseif arg == 5 then
         --remove file
         file.remove(content)
         conn:send('@')
      elseif arg == 8 then
         reload_cron()
         conn:send('@')
      elseif arg == 9 then
         --rename init
         file.remove("init0.lua")
         file.rename("init.lua", "init0.lua")
         node.restart()
         return
      else
         conn:send("badarg", close_socket)
      end
   else
      conn:send("badarg", close_socket);
   end
end

do
   gpio.mode(pin_feed, gpio.OUTPUT)
   gpio.write(pin_feed, gpio.HIGH)
   net.createServer(net.TCP):listen(port, function(conn)
                                       conn:on("receive", remote_ctrl)
                                          end)
end
