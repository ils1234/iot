print('\nDF Fisher\n')

-- set wifi
wifi.setmode(wifi.STATION)
wifi.sta.config({ssid = "DFS", pwd = "aishidongfang", auto = true})
wifi.sta.sethostname("curtain")
wifi.sta.setip({ip = "192.168.1.243", netmask="255.255.255.0", gateway="192.168.1.1"})

-- set io
tmr_active = 0
tmr_env = 1
tmr_autooff = 2
tmr_key = 3
pin_dht = 1
pin_ir = 2
pin_key = 3
pin_led = 4
pin_sw = 5
pin_dir = 6
pin_win = 7

-- active network
function http_get(code, data)
    print(data)
end

tmr.alarm(tmr_active, 100000, tmr.ALARM_AUTO, function()
    http.get("http://192.168.1.12/active.php", nil, http_get )
end)

-- auto read env
temp = 0
temp_dec = 0
humi = 0
humi_dec = 0

tmr.alarm(tmr_env, 5000, tmr.ALARM_AUTO, function()
    status, temp, humi, temp_dec, humi_dec = dht.read(pin_dht)
end)

-- set gpio mode
gpio.mode(pin_ir, gpio.INT, gpio.PULLUP)
gpio.mode(pin_key, gpio.INT, gpio.PULLUP)
gpio.mode(pin_led, gpio.OUTPUT)
gpio.mode(pin_sw, gpio.OUTPUT)
gpio.mode(pin_dir, gpio.OUTPUT)
gpio.mode(pin_win, gpio.INPUT, gpio.PULLUP)
gpio.write(pin_led, gpio.HIGH)
gpio.write(pin_sw, gpio.HIGH)
gpio.write(pin_dir, gpio.HIGH)

-- curtain operate
-- 0-stop, 1-down, 2-up
curtain_status = 0

function curtain_stop()
    curtain_status = 0
    gpio.write(pin_sw, gpio.HIGH)
    gpio.write(pin_dir, gpio.HIGH)
    print("stop")
end

function curtain_down()
    if curtain_status ~= 0 then
        curtain_stop()
	return
    end
    win = gpio.read(pin_win)
    if win == gpio.HIGH then
        print("window open")
        return
    end
    curtain_status = 1
    gpio.write(pin_dir, gpio.LOW)
    gpio.write(pin_sw, gpio.LOW)
    tmr.start(tmr_autooff)
    print("down")
end

function curtain_up()
    if curtain_status ~= 0 then
        curtain_stop()
	return
    end
    win = gpio.read(pin_win)
    if win == gpio.HIGH then
        print("window open")
        return
    end
    curtain_status = 2
    gpio.write(pin_dir, gpio.HIGH)
    gpio.write(pin_sw, gpio.LOW)
    tmr.start(tmr_autooff)
    print("up")
end

tmr.alarm(tmr_autooff, 100000, tmr.ALARM_SEMI, function()
    curtain_stop()
    print("auto stop")
end)

-- read ir
last_fall = 0
device_code = 0
o_device_code = 0
key_code = 0
o_key_code = 0
bit_count = 0

function ir_trig(level, when)
    fall_during = when - last_fall
    last_fall = when
    if fall_during > 13400 and fall_during < 13600 then
	bit_count = 0
	device_code = 0
	key_code = 0
	o_key_code = 0
	return
    elseif fall_during > 1024 and fall_during < 1225 then
        bit_value = 0
    elseif fall_during > 2145 and fall_during < 2345 then
        bit_value = 128
    else
        bit_count = 33
	return
    end
    bit_count = bit_count + 1
    if bit_count >=1 and bit_count <= 8 then
        device_code = bit.bor(bit.rshift(device_code, 1), bit_value)
    elseif bit_count >=9 and bit_count <= 16 then
        o_device_code = bit.bor(bit.rshift(o_device_code, 1), bit_value)
    elseif bit_count >=17 and bit_count <=24 then
        key_code = bit.bor(bit.rshift(key_code, 1), bit_value)
    elseif bit_count >=25 and bit_count <=32 then
        o_key_code = bit.bor(bit.rshift(o_key_code, 1), bit_value)
    end
    if bit_count == 32 then
        if bit.bxor(key_code, o_key_code) == 255 then
	    if device_code == 0 and key_code == 0 or device_code == 4 and key_code == 99 then
	        curtain_up()
	    elseif device_code == 0 and key_code == 2 or device_code == 4 and key_code == 97 then
	        curtain_down()
	    end
	end
    end
end

gpio.trig(pin_ir, "down", ir_trig)

-- set onboard key
-- 0-stop, 1-down, 2-stop, 3-up
last_key = 0

function key_trig()
    gpio.trig(pin_key)
    if last_key == 0 then
	curtain_down()
    elseif last_key == 1 or last_key == 3 then
        curtain_stop()
    elseif last_key == 2 then
        curtain_up()
    end
    last_key = last_key + 1
    if last_key > 3 then
        last_key = 0
    end
    tmr.alarm(tmr_key, 500, tmr.ALARM_SINGLE, function()
        gpio.trig(pin_key, "down", key_trig)
    end)
end

gpio.trig(pin_key, "down", key_trig)

-- start server
srv=net.createServer(net.TCP)
srv:listen(2000, function(conn)
    conn:on("receive", function(conn, content)
        if string.len(content) < 6 then
            print("bad size")
            return
        end
        part1 = string.sub(content, 1, 2)
        part2 = string.sub(content, 3, 4)
        part3 = string.sub(content, 5, 6)
        if part1 ~= part2 or part1 ~= part3 or part2 ~= part3 then
            conn:send("it works")
            print("bad protocol")
            return
        end
        chn = tonumber(string.sub(content, 1, 1))
        val = tonumber(string.sub(content, 2, 2))
	if chn == 0 then
	    t = string.format("%d.%03d", temp, temp_dec)
	    conn:send(t)
            print("temp " .. t)
        elseif chn == 1 then
	    t = string.format("%d.%03d", humi, humi_dec)
	    conn:send(t)
            print("humi " .. t)
	elseif chn == 2 then
            if val == 0 then
	        curtain_stop()
		conn:send("stop")
	    elseif val == 1 then
	        curtain_down()
		if curtain_status == 0 then
		    conn:send("stop")
		else
                    conn:send("down")
		end
	    elseif val == 2 then
	        curtain_up()
		if curtain_status == 0 then
		    conn:send("stop")
                else
		    conn:send("up")
	        end
	    else
	        conn:send("bad val")
                print("bad val " .. val)
                return
	    end
        else
            conn:send("bad chn")
            print("bad chn " .. chn)
            return
        end
    end)
    conn:on("sent", function(conn)
        conn:close()
    end)
end)
