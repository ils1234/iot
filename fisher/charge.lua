print("charge\n")

tmr_charge = 5
full_tick = 0

function charge_control()
   local soc = net.createConnection(net.TCP, 0)
   soc:on("connection", function(sck, cont)
      sck:send("828282")
   end)
   soc:on("receive", function(sck, cont)
      sck:close()
      if cont == "on" then
	 full_tick = full_tick + 1
      else
	 full_tick = 0
      end
      if full_tick >= 3 then
         local soc2 =  net.createConnection(net.TCP, 0)
         soc2:on("connection", function(sck2, cont2)
            sck2:send("303030")
         end)
         soc2:on("receive", function(sck2, cont2)
            sck2:close()
         end)
         soc2:connect(client_port, client_host)
      end
   end)
   soc:connect(client_port, client_host)
end

-- tmr set
tmr.alarm(tmr_charge, 600000, tmr.ALARM_AUTO, charge_control)
