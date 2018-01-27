print('\nDF Fisher\n')

-- set wifi
wifi.setmode(wifi.STATION)
wifi.sta.config({ssid = "DFS", pwd = "aishidongfang", auto = true})
wifi.sta.sethostname("house-heater")
wifi.sta.setip({ip = "192.168.1.241", netmask="255.255.255.0", gateway="192.168.1.1"})
net.dns.setdnsserver("192.168.1.1", 0)

-- 4-led, 1-relay, 3-key
pin_relay = 1
pin_key = 3
pin_led = 4
tmr_active = 0
tmr_autooff = 1
tmr_btn = 2

-- active network
function http_get(code, data)
    print(data)
end

tmr.alarm(tmr_active, 100000, tmr.ALARM_AUTO, function()
    http.get("http://192.168.1.12/active.php", nil, http_get )
end)

tmr.alarm(tmr_autooff, 1200000, tmr.ALARM_SEMI, function()
     gpio.write(pin_relay, gpio.LOW)
     gpio.write(pin_led, gpio.HIGH)
     print("autooff")
end)

-- set io
gpio.mode(pin_relay, gpio.OUTPUT)
gpio.mode(pin_key, gpio.INT, gpio.PULLUP)
gpio.mode(pin_led, gpio.OUTPUT)
gpio.write(pin_relay, gpio.LOW)
gpio.write(pin_led, gpio.HIGH)

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


-- start server
srv=net.createServer(net.TCP)
srv:listen(2000, function(conn)
    conn:on("receive",function(conn, content)
        if string.len(content) < 6 then
            print("bad size")
            return
        end
	payload = string.sub(content, 1, 6)
        if payload == "000000" then
	    switch_turn(gpio.LOW)
            conn:send("off")
        elseif payload == "010101" then
            switch_turn(gpio.HIGH)
            conn:send("on")
        elseif payload == "020202" then
     	    v = gpio.read(pin_relay)
	    if v == gpio.HIGH then
	        print("on")
                conn:send("on")
	    else
	        print("off")
                conn:send("off")
	    end
        else
            print(payload .. "bad")
            conn:send("unknown")
        end
    end)
    conn:on("sent", function(conn) conn:close() end)
end)
