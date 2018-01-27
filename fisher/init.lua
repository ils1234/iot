print('\nDF Fisher\n')

-- set wifi
wifi.setmode(wifi.STATION)
wifi.sta.config({ssid = "DFS", pwd = "aishidongfang", auto = true})
wifi.sta.sethostname("fisher")
wifi.sta.setip({ip = "192.168.1.242", netmask="255.255.255.0", gateway="192.168.1.1"})
net.dns.setdnsserver("192.168.1.1", 0)

tmr_active = 0
tmr_ds18b20 = 1
tmr_heater = 2

-- active network
function http_get(code, data)
    print(data)
end

tmr.alarm(tmr_active, 100000, tmr.ALARM_AUTO, function()
    http.get("http://192.168.1.12/active.php", nil, http_get)
end)

-- set io
gpio.mode(0, gpio.OUTPUT)
gpio.mode(1, gpio.OUTPUT)
gpio.mode(2, gpio.OUTPUT)
gpio.mode(3, gpio.OUTPUT)
gpio.mode(4, gpio.OUTPUT)
gpio.mode(5, gpio.OUTPUT)
gpio.mode(6, gpio.OUTPUT)
gpio.mode(7, gpio.OUTPUT)
gpio.write(0, gpio.HIGH)
gpio.write(1, gpio.HIGH)
gpio.write(2, gpio.HIGH)
gpio.write(3, gpio.HIGH)
gpio.write(4, gpio.HIGH)
gpio.write(5, gpio.HIGH)
gpio.write(6, gpio.HIGH)
gpio.write(7, gpio.HIGH)
ds18b20.setup(11)
ds18b20.setting({}, 12)

ds_current = 0
ds_addr = "28:FF:5F:7F:A6:16:03:03"
ds2_addr = "28:FF:53:F0:C1:17:04:F9"
temp = 26
temp_dec = 300
temp2 = 26
temp2_dec = 300

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
        if chn > 7 then
            conn:send("bad chn")
            print("bad chn " .. chn)
            return
        end
	if val == 0 then
            if chn ==0 then
	        t = string.format("%d.%03d", temp, temp_dec)
	        conn:send(t)
                print(t)
            else
                gpio.write(chn, gpio.HIGH)
                print(chn .. " off")
                conn:send("off")
	    end
        elseif val == 1 then
            if chn ==0 then
	        t = string.format("%d.%03d", temp2, temp2_dec)
	        conn:send(t)
                print(t)
            else
                gpio.write(chn, gpio.LOW)
                print(chn .. " on")
                conn:send("on")
            end
	elseif val == 2 then
	    v = gpio.read(chn)
            if v == gpio.HIGH then
	        print(chn .. " was off")
	        conn:send("off")
	    else
	        print(chn .. " was on")
	        conn:send("on")
	    end
	else
            conn:send("bad val")
            print("bad val " .. val)
            return
        end
    end)
    conn:on("sent", function(conn)
        conn:close()
    end)
end)

function pt(index, rom, res, t, td, par)
    temp = t
    temp_dec = td
end

function pt2(index, rom, res, t, td, par)
    temp2 = t
    temp2_dec = td
end

tmr.alarm(tmr_ds18b20, 2000, tmr.ALARM_AUTO, function()
    addr = {}
    if ds_current == 0 then
        addr[1] = ds_addr
	ds_current = 1
        ds18b20.read(pt, addr)
    else
        addr[1] = ds2_addr
	ds_current = 0
        ds18b20.read(pt2, addr)
    end
end)

tmr.alarm(tmr_heater, 5000, tmr.ALARM_AUTO, function()
    if temp > 26 or temp == 26 and temp_dec >= 300 then
        p0 = gpio.read(0)
	if p0 ~= gpio.HIGH then
            gpio.write(0, gpio.HIGH)
            print("heater off")
	end
    elseif temp < 25 or temp == 25 and temp_dec <= 700 then
        p0 = gpio.read(0)
	if p0 ~= gpio.LOW then
            gpio.write(0, gpio.LOW)
            print("heater on")
	end
    end
end)