pin_feed = 12
gpio.mode(pin_feed, gpio.OUTPUT)
gpio.write(pin_feed, gpio.HIGH)

dofile("net.lua")
dofile("atmega16.lua")
dofile("temp.lua")
dofile("server.lua")
dofile("cron.lua")
