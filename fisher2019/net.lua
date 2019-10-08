-- set wifi
do
   local wifi_id = {ssid = "DFS", pwd = "aishidongfang", auto = true}
   local ipgw = {ip = "192.168.1.245", netmask="255.255.255.0", gateway="192.168.1.1"}
   local host = "fisher"
   local ns = "192.168.1.1"

   wifi.setmode(wifi.STATION)
   wifi.sta.config(wifi_id)
   wifi.sta.sethostname(host)
   wifi.sta.setip(ipgw)
   net.dns.setdnsserver(ns, 0)
   sntp.sync(nil, nil, nil, 1)
end

function active_net()
   local active_url = "http://dfserver/active.php"
   http.get(active_url, nil, function (code, data) end)
end

function fisher_request(method, code)
   local url = "http://dfserver/index.php?r=fisher/" .. method .. "&v=" .. code
   http.get(url, nil, function (code, data) end)
end

tmr.create():alarm(100000, tmr.ALARM_AUTO, active_net)
