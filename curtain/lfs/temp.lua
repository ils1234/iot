--lua temp ctrl
local pin_dht = ...
local temp,humi

get_temp = function()
   return temp,humi
end

do
   temp = 0
   humi = 0
   local t,tdec,h,hdec,status
   tmr.create():alarm(5000, tmr.ALARM_AUTO, function()
                         status, t, h, tdec, hdec = dht.read(pin_dht)
                         temp = string.format("%d.%03d", t, tdec)
                         humi = string.format("%d.%03d", h, hdec)
                                            end)
end

