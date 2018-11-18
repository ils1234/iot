print('temperature\n')

-- set ds18b20
ds18b20.setup(pin_ds18b20)
ds18b20.setting(ds_addr, 12)

ds_current = 0
temp, temp_dec = 26, 300
temp2, temp2_dec = 26, 300
temp_limit = 27

-- temp read callback
function pt(index, rom, res, t, td, par)
   temp = t
   temp_dec = td
   
   local v = gpio.read(pin_heater)
   local limit_low = temp_limit - 1
   if v == gpio.LOW and (t > temp_limit or t == temp_limit and temp_dec > 100) then
      gpio.write(pin_heater, gpio.HIGH)
      print("heater off")
   elseif v == gpio.HIGH and (t < limit_low or t == limit_low and td < 900) then
      gpio.write(pin_heater, gpio.LOW)
      print("heater on")
   end
end

function pt2(index, rom, res, t, td, par)
    temp2 = t
    temp2_dec = td
end

function temp_read()
   local addr = {}
   if ds_current == 0 then
      addr[1] = "28:FF:5F:7F:A6:16:03:03"
      ds_current = 1
      ds18b20.read(pt, addr)
   else
      addr[1] = "28:FF:53:F0:C1:17:04:F9"
      ds_current = 0
      ds18b20.read(pt2, addr)
   end
end

-- tmr set
tmr.alarm(tmr_ds18b20, 1000, tmr.ALARM_AUTO, temp_read)
