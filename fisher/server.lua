print('server\n')

-- out 12345678
-- in abc
-- virtual uvwx
pin = {[49]=0, [50]=3, [51]=4, [52]=5, [53]=6, [54]=7, [55]=8, [56]=9,
       [97]=1, [98]=2, [99]=12}

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
            print(chn .. " was off")
            conn:send("off")
         else
            print(chn .. " was on")
            conn:send("on")
         end
      elseif val == 3 then
         local t = string.format("%d", temp_limit)
         conn:send(t)
         print(t)
      elseif val == 4 then
         temp_limit = tonumber(part4)
         temp_limit_low = temp_limit - 1
      elseif val == 5 then
         local t = string.format("%d.%03d", temp3, temp3_dec)
         conn:send(t)
         print(t)
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
         return
      end
   elseif cchn >=97 and cchn <= 99 then
      -- cchn 97-99, input, status
      local v = gpio.read(chn)
      if v == gpio.HIGH then
         print(chn .. " was off")
         conn:send("off")
      else
         print(chn .. " was on")
         conn:send("on")
      end
   end
   return
end

function srv_listen(conn)
   conn:on("receive", remote_ctrl)
   conn:on("sent", close_socket)
end

srv = net.createServer(net.TCP)
srv:listen(2000, srv_listen)