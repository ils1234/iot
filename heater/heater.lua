print('heater\n')

-- 4-led, 1-relay, 3-key

-- by button
function switch_turn(v)
    v = v or nil
    if v == nil then
        v = gpio.read(pin_led)
    end
    if v == gpio.HIGH then
        gpio.write(pin_led, gpio.LOW)
	gpio.write(pin_relay, gpio.HIGH)
        tmr.start(tmr_autooff)
        print("on")
    else
	gpio.write(pin_led, gpio.HIGH)
	gpio.write(pin_relay, gpio.LOW)
	tmr.stop(tmr_autooff)
        print("off")
    end
end

function button_trig(level, when)
    gpio.trig(pin_key)
    switch_turn()
    tmr.alarm(tmr_btn, 500, tmr.ALARM_SINGLE, function()
        gpio.trig(pin_key, "down", button_trig)
    end)
end

gpio.trig(pin_key, "down", button_trig)

tmr.alarm(tmr_autooff, 1200000, tmr.ALARM_SEMI, function()
     switch_turn(gpio.LOW)
     print("autooff")
end)
