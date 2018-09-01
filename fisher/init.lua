print('\nDF Fisher\n')

-- set io
-- 0,3-9 to relay
-- 1,2,12 from water level
-- 11 from ds18b20
-- 10 com tx left
gpio.mode(0, gpio.OUTPUT)
gpio.mode(3, gpio.OUTPUT)
gpio.mode(4, gpio.OUTPUT)
gpio.mode(5, gpio.OUTPUT)
gpio.mode(6, gpio.OUTPUT)
gpio.mode(7, gpio.OUTPUT)
gpio.mode(8, gpio.OUTPUT)
gpio.mode(9, gpio.OUTPUT)
gpio.mode(1, gpio.INPUT)
gpio.mode(2, gpio.INPUT)
gpio.mode(12, gpio.INPUT)
gpio.write(0, gpio.HIGH)
gpio.write(3, gpio.HIGH)
gpio.write(4, gpio.HIGH)
gpio.write(5, gpio.HIGH)
gpio.write(6, gpio.HIGH)
gpio.write(7, gpio.HIGH)
gpio.write(8, gpio.HIGH)
gpio.write(9, gpio.HIGH)

dofile("net.lua")
dofile("temp.lua")
dofile("server.lua")
dofile("key.lua")
dofile("charge.lua")
