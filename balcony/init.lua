-- set wifi
do
   --config network
   local wifi_id = {ssid = "DFS", pwd = "aishidongfang", auto = true}
   local ipgw = {ip = "192.168.1.244", netmask="255.255.255.0", gateway="192.168.1.1"}
   local host = "balcony"
   local ns = "192.168.1.1"
   wifi.setmode(wifi.STATION)
   wifi.sta.config(wifi_id)
   wifi.sta.sethostname(host)
   wifi.sta.setip(ipgw)
   net.dns.setdnsserver(ns, 0)
   sntp.sync(nil, nil, nil, 1)
   --load lfs
   node.flashindex("_init")()
   LFS.charge(3, 12)
   LFS.switch(0, 1, 2)
   LFS.cron()
   LFS.server(2000)
   tmr.create():alarm(1000, tmr.ALARM_SINGLE, function()
                         LFS.temp(11)
                                              end)

end
