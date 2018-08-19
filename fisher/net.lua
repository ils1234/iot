print("set wifi\n")
-- set wifi
wifi.setmode(wifi.STATION)
wifi.sta.config({ssid = "DFS", pwd = "aishidongfang", auto = true})
wifi.sta.sethostname("fisher")
wifi.sta.setip({ip = "192.168.1.242", netmask="255.255.255.0", gateway="192.168.1.1"})
net.dns.setdnsserver("192.168.1.1", 0)
sntp.sync(nil, nil, nil, 1)

tmr_active = 0

-- active network callback
function http_get(code, data)
    print(data)
end

function active_net()
   http.get("http://192.168.1.12/active.php", nil, http_get)
end

-- tmr set
tmr.alarm(tmr_active, 100000, tmr.ALARM_AUTO, active_net)
