local client_host, client_port = ...
temp = 26
temp_full = '26.3'

function active_net()
   local active_url = "http://dfserver/active.php"
   http.get(active_url, nil, function (code, data) end)
end

function fisher_request(method, code)
   local url = "http://dfserver/index.php?r=fisher/" .. method .. "&v=" .. code
   http.get(url, nil, function (code, data) end)
end

local read_temp = function()
   local soc = net.createConnection(net.TCP, 0)
   soc:on("connection", function(sck, cont)
      sck:send("020202")
   end)
   soc:on("receive", function(sck, cont)
             sck:close()
             local b,v
             b,_,v = string.find(cont, '(%d+)%.%d+')
             temp = tonumber(v)
             temp_full = cont
                     end)
   soc:connect(client_port, client_host)
end

do
   tmr.create():alarm(100000, tmr.ALARM_AUTO, active_net)
   tmr.create():alarm(60000, tmr.ALARM_AUTO, read_temp)
end
