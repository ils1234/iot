local pin_relay = 1
local pin_led = 0
local pin_key = 3
local port = 2000

-- simple no use lfs
local button_trig, switch_toggle, switch_on, switch_off, close_socket, remote_ctrl, active_net
local remote_on, remote_off, remote_toggle
local disable_button, delay_enable_button

disable_button = function()
   gpio.trig(pin_key)
end

delay_enable_button = function()
   tmr.create():alarm(500, tmr.ALARM_SINGLE, function()
                         gpio.trig(pin_key, "down", button_trig)
                                             end)
end

switch_on = function()
   gpio.write(pin_led, gpio.LOW)
   gpio.write(pin_relay, gpio.HIGH)
end

switch_off = function()
   gpio.write(pin_led, gpio.HIGH)
   gpio.write(pin_relay, gpio.LOW)
end

switch_toggle = function()
   local v = gpio.read(pin_led)
   if v == gpio.HIGH then
      switch_on()
   else
      switch_off()
   end
end

remote_on = function()
   disable_button()
   switch_on()
   delay_enable_button()
end

remote_off = function()
   disable_button()   
   switch_off()
   delay_enable_button()
end

remote_toggle = function()
   disable_button()
   switch_toggle()
   delay_enable_button()
end

local count,v
button_trig = function(level, when)
   disable_button()
   count = 0
   tmr.create():alarm(30, tmr.ALARM_SINGLE, function()
                         v = gpio.read(pin_key)
                         if v == gpio.LOW then
                            count = count +1
                         end
                                            end)
   tmr.create():alarm(60, tmr.ALARM_SINGLE, function()
                         v = gpio.read(pin_key)
                         if v == gpio.LOW then
                            count = count +1
                         end
                                            end)
   tmr.create():alarm(90, tmr.ALARM_SINGLE, function()
                         v = gpio.read(pin_key)
                         if v == gpio.LOW and count == 2 then
                            switch_toggle()
                         end
                                             end);
   delay_enable_button()
end

close_socket = function(s)
   s:close()
end

remote_ctrl = function(conn, data)
   if string.len(data) < 6 then
      conn:send("badarg", close_socket)
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
      if arg == 0 then
         remote_off()
         conn:send("off", close_socket)
      elseif arg == 1 then
         remote_on()
         conn:send("on", close_socket)
      elseif arg == 2 then
         local v = gpio.read(pin_led)
         if v == gpio.LOW then
            conn:send("on", close_socket)
         else
            conn:send("off", close_socket)
         end
      elseif arg == 5 then
         remote_toggle()
         conn:send("done", close_socket)
      else
         conn:send("badarg", close_socket)
      end
   else
      conn:send("badarg", close_socket);
   end
end

active_net = function()
   local active_url = "http://dfserver/active.php"
   http.get(active_url, nil, function (code, data) end)
end

-- set wifi
do
   --config network
   local wifi_id = {ssid = "DFS", pwd = "aishidongfang", auto = true}
   local ipgw = {ip = "192.168.1.232", netmask="255.255.255.0", gateway="192.168.1.1"}
   local host = "balcony"
   local ns = "192.168.1.1"
   wifi.setmode(wifi.STATION)
   wifi.sta.config(wifi_id)
   wifi.sta.sethostname(host)
   wifi.sta.setip(ipgw)
   net.dns.setdnsserver(ns, 0)
   sntp.sync(nil, nil, nil, 1)

   gpio.mode(pin_relay, gpio.OUTPUT)
   gpio.mode(pin_led, gpio.OUTPUT)
   gpio.mode(pin_key, gpio.INT, gpio.PULLUP)
   switch_off()
   gpio.trig(pin_key, "down", button_trig)

   net.createServer(net.TCP):listen(port, function(conn)
                                       conn:on("receive", remote_ctrl)
                                          end)
   tmr.create():alarm(100000, tmr.ALARM_AUTO, active_net)   
end
