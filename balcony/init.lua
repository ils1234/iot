print('\nDF Fisher\n')

-- set io
-- 0-7 to relay
-- 12 charger green light
-- 11 from ds18b20
-- 10 com tx left
pin_light = 0
pin_socket = 1
pin_bulb = 2
pin_charger = 3
pin_ds18b20 = 11
pin_full = 12

tmr_active = 0
tmr_ds18b20 = 1
tmr_charge = 5

gpio.mode(pin_light, gpio.OUTPUT)
gpio.mode(pin_socket, gpio.OUTPUT)
gpio.mode(pin_bulb, gpio.OUTPUT)
gpio.mode(pin_charger, gpio.OUTPUT)
gpio.mode(pin_full, gpio.INPUT)
gpio.write(pin_light, gpio.HIGH)
gpio.write(pin_socket, gpio.HIGH)
gpio.write(pin_bulb, gpio.HIGH)
gpio.write(pin_charger, gpio.HIGH)
--gpio.mode(4, gpio.OUTPUT)
--gpio.mode(5, gpio.OUTPUT)
--gpio.mode(6, gpio.OUTPUT)
--gpio.mode(7, gpio.OUTPUT)
--gpio.write(4, gpio.HIGH)
--gpio.write(5, gpio.HIGH)
--gpio.write(6, gpio.HIGH)
--gpio.write(7, gpio.HIGH)

dofile("net.lua")
dofile("temp.lua")
dofile("charge.lua")
dofile("server.lua")
dofile("cron.lua")
