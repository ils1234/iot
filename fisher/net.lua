print("net\n")

tmr_active = 0
wifi_id = {ssid = "DFS", pwd = "aishidongfang", auto = true}
ipgw = {ip = "192.168.1.242", netmask="255.255.255.0", gateway="192.168.1.1"}
host = "fisher"
ns = "192.168.1.1"
client_host, client_port = "192.168.1.59", 2000
active_url = "http://192.168.1.12/active.php"

-- set wifi
wifi.setmode(wifi.STATION)
wifi.sta.config(wifi_id)
wifi.sta.sethostname(host)
wifi.sta.setip(ipgw)
net.dns.setdnsserver(ns, 0)
sntp.sync(nil, nil, nil, 1)

-- active network callback
function http_get(code, data)
    print(data)
end

function active_net()
   http.get(active_url, nil, http_get)
end

-- tmr set
tmr.alarm(tmr_active, 100000, tmr.ALARM_AUTO, active_net)