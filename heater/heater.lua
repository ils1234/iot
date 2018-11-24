print('heater\n')

temp, temp_dec = 26, 300
temp_limit = 23
wait_time = 20
work_time = 20
heater_work = 0
heater_wait = 0
burn = false

function heater_force_on()
   heater_work = work_time
   gpio.write(pin_led, gpio.LOW)
   gpio.write(pin_relay, gpio.HIGH)
end

function heater_force_off()
   heater_work = 0
   gpio.write(pin_led, gpio.HIGH)
   gpio.write(pin_relay, gpio.LOW)
end

function heater_on()
   gpio.write(pin_led, gpio.LOW)
   gpio.write(pin_relay, gpio.HIGH)
end

function heater_off()
   gpio.write(pin_led, gpio.HIGH)
   gpio.write(pin_relay, gpio.LOW)
end

function heater_ctrl()
   -- keep heat when work
   if heater_work > 0 then
      heater_work = heater_work - 1
      if heater_work == 0 then
	 heater_off()
	 heater_wait = 0
      end
      return
   end
   -- wait count
   heater_wait = heater_wait + 1
   if heater_wait > wait_time and burn == true then
      heater_work = work_time
      heater_on()
      return
   end
end

tmr.alarm(tmr_heater, 60000, tmr.ALARM_AUTO, heater_ctrl)

-- update temp every minute, and set burn target
function temp_ctrl()
   local soc = net.createConnection(net.TCP, 0)
   soc:on("connection", function(sck, cont)
      sck:send("020202")
   end)
   soc:on("receive", function(sck, cont)
      sck:close()
      local b = string.find(cont, '%.')
      local temp_limit_low = temp_limit - 1
      temp = tonumber(string.sub(cont, 1, b - 1))
      temp_dec = tonumber(string.sub(cont, b + 1))
      if temp < temp_limit_low or temp == temp_limit_low and temp_dec <= 500 then
	 burn = true
      elseif temp >= temp_limit then
	 burn = false
      end
   end)
   soc:connect(client_port, client_host)
end

tmr.alarm(tmr_readtemp, 60000, tmr.ALARM_AUTO, temp_ctrl)

-- access key press
function switch_turn()
   local v = gpio.read(pin_led)
   if v == gpio.HIGH then
      heater_force_on()
      print("on")
   else
      heater_force_off()
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
