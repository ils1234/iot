local port = ...

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
   if cmd == '0' then
      --keep 020202 response temp for old heater
      local temp,humi = get_temp()
      conn:send(temp, close_socket)
   elseif cmd == 'r' then
      if arg == 0 then
         curtain_up()
         conn:send("up", close_socket)
      elseif arg == 1 then
         curtain_down()
         conn:send("down", close_socket)
      elseif arg == 2 then
         local temp,humi = get_temp()
         local curtain,win = get_curtain()
         conn:send(string.format("%s %s %s %d", temp, humi, curtain, win), close_socket)
      elseif arg == 3 then
         clock_on()
         conn:send("on", close_socket)
      elseif arg == 4 then
         clock_off()
         conn:send("off", close_socket)
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
      elseif arg == 8 then
         reload_cron()
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
   net.createServer(net.TCP):listen(port, function(conn)
                                       conn:on("receive", remote_ctrl)
                                          end)
end
