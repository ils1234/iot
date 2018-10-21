print('\nDF Fisher\n')

-- set io
-- 0,3-9 to relay
pin_heater = 0
pin_wave = 3
pin_addwater = 4
pin_fog = 5
pin_filter = 6
pin_camera = 7
pin_light = 8
pin_feed = 9

-- 1,2,12 from water level
pin_main_water_level = 1
pin_low_level = 2
pin_high_level = 12

-- 11 from ds18b20
pin_ds18b20 = 11
-- 10 com tx left
tmr_active = 0
tmr_ds18b20 = 1
tmr_heater = 2
tmr_key = 3
tmr_addwater = 4

gpio.mode(pin_heater, gpio.OUTPUT)
gpio.mode(pin_wave, gpio.OUTPUT)
gpio.mode(pin_addwater, gpio.OUTPUT)
gpio.mode(pin_fog, gpio.OUTPUT)
gpio.mode(pin_filter, gpio.OUTPUT)
gpio.mode(pin_camera, gpio.OUTPUT)
gpio.mode(pin_light, gpio.OUTPUT)
gpio.mode(pin_feed, gpio.OUTPUT)
gpio.mode(pin_main_water_level, gpio.INPUT)
gpio.mode(pin_low_level, gpio.INPUT)
gpio.mode(pin_high_level, gpio.INPUT)
gpio.write(pin_heater, gpio.HIGH)
gpio.write(pin_wave, gpio.HIGH)
gpio.write(pin_addwater, gpio.HIGH)
gpio.write(pin_fog, gpio.HIGH)
gpio.write(pin_filter, gpio.HIGH)
gpio.write(pin_camera, gpio.HIGH)
gpio.write(pin_light, gpio.HIGH)
gpio.write(pin_feed, gpio.HIGH)

dofile("net.lua")
dofile("temp.lua")
dofile("server.lua")
dofile("addwater.lua")
dofile("key.lua")
dofile("alarm.lua")
dofile("cron.lua")
