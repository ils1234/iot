print("net\n")

wifi_id = {ssid = "DFS", pwd = "aishidongfang", auto = true}
ipgw = {ip = "192.168.1.242", netmask="255.255.255.0", gateway="192.168.1.1"}
host = "fisher"
ns = "192.168.1.1"
client_host, client_port = "192.168.1.244", 2000
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

-- connect client
function send_client(cmd)
   local soc = net.createConnection(net.TCP, 0)
   soc:on("connection", function(sck, cont)
      sck:send(cmd)
   end)
   soc:on("receive", function(sck, cont)
      sck:close()
   end)
   soc:connect(client_port, client_host)
end

function read_client(cmd, conn)
   local soc = net.createConnection(net.TCP, 0)
   soc:on("connection", function(sck, cont)
      sck:send(cmd)
   end)
   soc:on("receive", function(sck, cont)
      sck:close()
      if cont == 'on' then
         conn:send("off")
      else
	 conn:send("on")
      end
   end)
   soc:connect(client_port, client_host)
end

function client_do(qcmd, oncmd, offcmd)
   local soc = net.createConnection(net.TCP, 0)
   soc:on("connection", function(sck, cont)
      sck:send(qcmd)
   end)
   soc:on("receive", function(sck, cont)
      sck:close()
      local cmd
      if cont == "on" then
          cmd = oncmd
      else
          cmd = offcmd
      end
      local soc2 =  net.createConnection(net.TCP, 0)
      soc2:on("connection", function(sck2, cont2)
         sck2:send(cmd)
      end)
      soc2:on("receive", function(sck2, cont2)
          sck2:close()
	  print(cont2)
      end)
      soc2:connect(client_port, client_host)
   end)
   soc:connect(client_port, client_host)
end

-- tmr set
tmr.alarm(tmr_active, 100000, tmr.ALARM_AUTO, active_net)
