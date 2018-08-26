print('temperature\n')

tmr_ds18b20, tmr_heater = 1,2
pin_heater = 0
pin_ds18b20 = 11

ds_addr = {"28:FF:5F:7F:A6:16:03:03", "28:FF:53:F0:C1:17:04:F9", "28:FF:B8:F0:C1:17:04:53"}

-- set heater
gpio.mode(pin_heater, gpio.OUTPUT)
gpio.write(pin_heater, gpio.HIGH)

-- set ds18b20
ds18b20.setup(pin_ds18b20)
ds18b20.setting(ds_addr, 12)

ds_current = 0
temp, temp_dec = 26, 300
temp2, temp2_dec = 26, 300
temp3, temp3_dec = 26, 300
temp_limit_low, temp_limit = 26, 27

-- temp read callback
function pt(index, rom, res, t, td, par)
    temp = t
    temp_dec = td
end

function pt2(index, rom, res, t, td, par)
    temp2 = t
    temp2_dec = td
end

function pt3(index, rom, res, t, td, par)
    temp3 = t
    temp3_dec = td
end

function temp_read()
   local addr = {}
   if ds_current == 0 then
      addr[1] = ds_addr[1]
      ds_current = 1
      ds18b20.read(pt, addr)
   elseif ds_current == 1 then
      addr[1] = ds_addr[2]
      ds_current = 2
      ds18b20.read(pt2, addr)
   else
      addr[1] = ds_addr[3]
      ds_current = 0
      ds18b20.read(pt3, addr)
   end
end

function heater_control()
   local p0 = gpio.read(pin_heater)	 
   if temp > temp_limit or temp == temp_limit and temp_dec >= 100 then
      if p0 ~= gpio.HIGH then
         gpio.write(pin_heater, gpio.HIGH)
         print("heater off")
      end
   elseif temp < temp_limit_low or temp == temp_limit_low and temp_dec <= 900 then
      if p0 ~= gpio.LOW then
         gpio.write(pin_heater, gpio.LOW)
         print("heater on")
      end
   end
end

-- tmr set
tmr.alarm(tmr_ds18b20, 1000, tmr.ALARM_AUTO, temp_read)
tmr.alarm(tmr_heater, 2000, tmr.ALARM_AUTO, heater_control)
