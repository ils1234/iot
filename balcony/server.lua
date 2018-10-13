print('server\n')

-- out 12345678
-- in abc
-- virtual ABCD
pin = {[48]=0, [49]=1, [50]=2, [51]=3, [52]=4, [53]=5, [54]=6, [55]=7,
       [57]=0, [56]=12}

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
   if cchn == 57 then
      -- chn 8|cchn 57 auto control
      local t = string.format("%d.%03d", temp, temp_dec)
      conn:send(t)
      print(t)
   elseif cchn >= 48 and cchn <= 55 then
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
   elseif cchn == 56 then
      -- charge state
      if val == 0 then
	 conn:send(tostring(full_tick))
	 print("tick " .. full_tick)
      elseif val == 1 then
	 conn:send(tostring(charge_tick))
	 print("end 1min*" .. charge_tick)
      elseif val == 2 then
	 local v = gpio.read(chn)
         if v == gpio.HIGH then
            print("light was on")
            conn:send("on")
         else
            print("light was off")
            conn:send("off")
         end
      elseif val == 3 then
	 conn:send(charge_state)
         print(charge_state)
      elseif val == 4 then
         charge_tick = tonumber(part4)
	 conn:send("ok")
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
