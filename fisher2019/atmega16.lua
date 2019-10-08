relay = 0
water_main = 0
water_high = 0
water_low = 0

--these am_xxx will be called by atmega16
--donot change function names

function am_relay(data)
   local v = string.byte(data, 1, 1)
   if v >=97 then
      relay = (v-87) * 16
   else
      relay = (v-48) * 16
   end
   v = string.byte(data, 2, 2)
   if v >=97 then
      relay = relay + (v-87)
   else
      relay = relay + (v-48)
   end
end

function am_water(data)
   if string.byte(data, 1, 1) == 0x68 then
      water_main = 1
   else
      water_main = 0
   end
   if string.byte(data, 2, 2) == 0x68 then
      water_high = 1
   else
      water_high = 0
   end
   if string.byte(data, 3, 3) == 0x68 then
      water_low = 1
   else
      water_low = 0
   end
end

function am_freq(data)
end

function am_queue(data)   
end

function am_key(data)
   fisher_request("key", data)
end

function am_ir(data)
   fisher_request("ir", data)
end

function set_relay(pos, val)
   if pos >= 8 then
      relay = val
   else
      if val > 0 then
	 relay = bit.set(relay, pos)
      else
	 relay = bit.clear(relay, pos)
      end
   end
   uart.write(0, 0x10, relay)
end

do
   uart.setup(0, 115200, 8, uart.PARITY_NONE, uart.STOPBITS_1, 0)
   uart.on("data", 0, nil, 1)
   uart.alt(1)
   uart.write(0, 0x0b)
end

last_access = 0
tmr.create():alarm(1000, tmr.ALARM_AUTO, function() if last_access<10 then uart.write(0, 0x0c) last_access=last_access+1 else uart.write(0, 0x0b) last_access=0 end end)
