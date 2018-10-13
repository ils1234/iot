print('\nDF Fisher\n')

-- set io
-- 0-7 to relay
-- 12 charger green light
-- 11 from ds18b20
-- 10 com tx left
gpio.mode(0, gpio.OUTPUT)
gpio.mode(1, gpio.OUTPUT)
gpio.mode(2, gpio.OUTPUT)
gpio.mode(3, gpio.OUTPUT)
gpio.mode(4, gpio.OUTPUT)
gpio.mode(5, gpio.OUTPUT)
gpio.mode(6, gpio.OUTPUT)
gpio.mode(7, gpio.OUTPUT)
gpio.mode(12, gpio.INPUT)
gpio.write(0, gpio.HIGH)
gpio.write(1, gpio.HIGH)
gpio.write(2, gpio.HIGH)
gpio.write(3, gpio.HIGH)
gpio.write(4, gpio.HIGH)
gpio.write(5, gpio.HIGH)
gpio.write(6, gpio.HIGH)
gpio.write(7, gpio.HIGH)

dofile("net.lua")
dofile("temp.lua")
dofile("server.lua")
dofile("charge.lua")
