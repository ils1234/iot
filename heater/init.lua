-- set wifi
do
   --config network
   local wifi_id = {ssid = "DFS", pwd = "aishidongfang", auto = true}
   local ipgw = {ip = "192.168.1.241", netmask="255.255.255.0", gateway="192.168.1.1"}
   local host = "fisher"
   local ns = "192.168.1.1"
   wifi.setmode(wifi.STATION)
   wifi.sta.config(wifi_id)
   wifi.sta.sethostname(host)
   wifi.sta.setip(ipgw)
   net.dns.setdnsserver(ns, 0)
   sntp.sync(nil, nil, nil, 1)
   --load lfs
   node.flashindex("_init")()
   LFS.client("192.168.1.243", 2000)
   LFS.heater(1, 3, 0, 4)
   LFS.cron()
   LFS.server(2000, 1)
end
