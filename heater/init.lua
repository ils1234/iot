print('\nDF Fisher\n')

-- set io
-- 1 to relay
-- 3 to key
-- 4 to light
pin_relay = 1
pin_key = 3
pin_led = 4

-- set tmr
tmr_active = 0
tmr_heater = 1
tmr_btn = 2
tmr_readtemp = 3

gpio.mode(pin_relay, gpio.OUTPUT)
gpio.mode(pin_key, gpio.INT, gpio.PULLUP)
gpio.mode(pin_led, gpio.OUTPUT)
gpio.write(pin_relay, gpio.LOW)
gpio.write(pin_led, gpio.HIGH)

dofile("net.lua")
dofile("heater.lua")
dofile("cron.lua")
dofile("server.lua")
