local ir_call

ir_call = function(device_code, o_device_code, key_code)
   if device_code == 0 and key_code == 21 or device_code == 4 and key_code == 99 then
      curtain_up()
   elseif device_code == 0 and key_code == 22 or device_code == 4 and key_code == 97 then
      curtain_down()
   end
end

do
   --config network
   local wifi_id = {ssid = "DFS", pwd = "aishidongfang", auto = true}
   local ipgw = {ip = "192.168.1.243", netmask="255.255.255.0", gateway="192.168.1.1"}
   local host = "curtain"
   local ns = "192.168.1.1"
   wifi.setmode(wifi.STATION)
   wifi.sta.config(wifi_id)
   wifi.sta.sethostname(host)
   wifi.sta.setip(ipgw)
   net.dns.setdnsserver(ns, 0)
   sntp.sync(nil, nil, nil, 1)
   --load lfs
   node.flashindex("_init")()
   LFS.client()
   LFS.temp(1)
   LFS.curtain(4, 5, 6, 7)
   LFS.clock(11, 12)
   LFS.cron()
   LFS.ir(2, ir_call)
   LFS.server(2000)
end
