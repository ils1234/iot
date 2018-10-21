print('\nDF Fisher\n')

-- set io
-- 1 to relay
-- 3 to key
-- 4 to light

gpio.mode(1, gpio.OUTPUT)
gpio.mode(3, gpio.INT, gpio.PULLUP)
gpio.mode(4, gpio.OUTPUT)
gpio.write(1, gpio.LOW)
gpio.write(4, gpio.HIGH)

dofile("net.lua")
dofile("heater.lua")
dofile("cron.lua")
dofile("server.lua")
