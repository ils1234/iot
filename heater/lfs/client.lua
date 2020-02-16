local client_host, client_port = ...
temp = 26
temp_dec = 3
humi = 26
humi_dec = 3

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
      sck:send("r2r2r2")
   end)
   soc:on("receive", function(sck, cont)
             sck:close()
             local t,td,h,hd
             _,_,t,td,h,hd = string.find(cont, '(%d+)%.(%d+)%s(%d+)%.(%d+).+')
             temp = tonumber(t)
             temp_dec = tonumber(td)
             humi = tonumber(h)
             humi_dec = tonumber(hd)
                     end)
   soc:connect(client_port, client_host)
end

do
   tmr.create():alarm(100000, tmr.ALARM_AUTO, active_net)
   tmr.create():alarm(60000, tmr.ALARM_AUTO, read_temp)
end
