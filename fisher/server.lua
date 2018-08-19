print('server\n')

-- out 12345678
-- in abc
-- virtual uvwx
pin = {[49]=0, [50]=3, [51]=4, [52]=5, [53]=6, [54]=7, [55]=8, [56]=9,
       [97]=1, [98]=2, [99]=12,
       [117]=0, [118]=1, [119]=2, [120]=3}

-- proxy client
client_host, client_port = "192.168.1.59", 2000

function close_socket(s)
   s:close()
end

function write_client(chn, val)
   soc = net.createConnection(net.TCP, 0)
   soc:connect(client_port, client_host)
   soc:send(string.char(chn,val,chn,val,chn,val), close_socket)
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
   part1 = string.sub(content, 1, 2)
   part2 = string.sub(content, 3, 4)
   part3 = string.sub(content, 5, 6)
   part4 = string.sub(content, 7)
   -- check protocol
   if part1 ~= part2 or part1 ~= part3 or part2 ~= part3 then
      conn:send("it works")
      print("bad protocol")
      return
   end
   cchn = string.byte(content, 1)
   val = tonumber(string.sub(content, 2, 2))
   chn = pin[cchn]
   if chn == nil then
      conn:send("bad chn")
      print("bad chn " .. cchn)
      return
   end
   if cchn == 49 then
      -- chn 0|cchn 49 auto control
      if val == 0 then
         t = string.format("%d.%03d", temp, temp_dec)
         conn:send(t)
         print(t)
      elseif val == 1 then
         t = string.format("%d.%03d", temp2, temp2_dec)
         conn:send(t)
         print(t)
      elseif val == 2 then
         v = gpio.read(chn)
         if v == gpio.HIGH then
            print(chn .. " was off")
            conn:send("off")
         else
            print(chn .. " was on")
            conn:send("on")
         end
      elseif val == 3 then
         t = string.format("%d", temp_limit)
         conn:send(t)
         print(t)
      elseif val == 4 then
         temp_limit = tonumber(part4)
         temp_limit_low = temp_limit - 1
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
         v = gpio.read(chn)
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
      v = gpio.read(chn)
      if v == gpio.HIGH then
         print(chn .. " was off")
         conn:send("off")
      else
         print(chn .. " was on")
         conn:send("on")
      end
   elseif cchn >=117 and cchn <=120 then
      -- cchn 117-120, forward client
      write_client(chn, val)
      print('client called')
      conn:send('called')
   end
   return
end

function srv_listen(conn)
   conn:on("receive", remote_ctrl)
   conn:on("sent", close_socket)
end

srv=net.createServer(net.TCP)
srv:listen(2000, srv_listen)
