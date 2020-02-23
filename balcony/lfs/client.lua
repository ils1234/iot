active_net = function()
   local active_url = "http://dfserver/active.php"
   http.get(active_url, nil, function (code, data) end)
end

fisher_request = function(method, code)
   local url = "http://dfserver/index.php?r=fisher/" .. method .. "&v=" .. code
   http.get(url, nil, function (code, data) end)
end

do
   tmr.create():alarm(100000, tmr.ALARM_AUTO, active_net)
end
