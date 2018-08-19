print('temperature\n')

tmr_ds18b20, tmr_heater = 1,2
heater_port = 0
ds18b20_port = 11
ds_addr, ds2_addr = "28:FF:5F:7F:A6:16:03:03", "28:FF:53:F0:C1:17:04:F9"

gpio.mode(heater_port, gpio.OUTPUT)
gpio.write(heater_port, gpio.HIGH)

-- set ds18b20
ds18b20.setup(ds18b20_port)
ds18b20.setting({}, 12)

ds_current = 0
temp, temp_dec = 26, 300
temp2, temp2_dec = 26, 300
temp_limit_low, temp_limit = 25, 26

-- temp read callback
function pt(index, rom, res, t, td, par)
    temp = t
    temp_dec = td
end

function pt2(index, rom, res, t, td, par)
    temp2 = t
    temp2_dec = td
end

function temp_read()
   addr = {}
   if ds_current == 0 then
      addr[1] = ds_addr
      ds_current = 1
      ds18b20.read(pt, addr)
   else
      addr[1] = ds2_addr
      ds_current = 0
      ds18b20.read(pt2, addr)
   end
end

function heater_control()
   if temp > temp_limit or temp == temp_limit and temp_dec >= 300 then
      p0 = gpio.read(heater_port)
      if p0 ~= gpio.HIGH then
         gpio.write(heater_port, gpio.HIGH)
         print("heater off")
      end
   elseif temp < temp_limit_low or temp == temp_limit_low and temp_dec <= 700 then
      p0 = gpio.read(heater_port)
      if p0 ~= gpio.LOW then
         gpio.write(heater_port, gpio.LOW)
         print("heater on")
      end
   end
end

-- tmr set
tmr.alarm(tmr_ds18b20, 1000, tmr.ALARM_AUTO, temp_read)
tmr.alarm(tmr_heater, 2000, tmr.ALARM_AUTO, heater_control)

