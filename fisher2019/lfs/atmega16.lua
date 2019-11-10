local relay = 0
local water_main = 0
local water_high = 0
local water_low = 0

get_atmega16 = function()
   return relay,water_main,water_high,water_low
end

--these am_xxx will be called by atmega16
--donot change function names

am_relay = function(data)
   relay = tonumber(data, 16);
end

am_water = function(data)
   local v = tonumber(data, 16);
   if bit.isset(v, 0) then
      water_main = 1
   else
      water_main = 0
   end
   if bit.isset(v, 1) then
      water_high = 1
   else
      water_high = 0
   end
   if bit.isset(v, 2) then
      water_low = 1
   else
      water_low = 0
   end
end

am_freq = function(data)
end

am_queue = function(data)   
end

am_key = function(data)
   fisher_request("key", data)
end

am_ir = function(data)
   fisher_request("ir", data)
end

set_relay = function(pos, val)
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

toggle_relay = function(pos)
   if pos < 8 then
      if bit.isclear(relay, pos) then
         relay = bit.set(relay, pos)
      else
         relay = bit.clear(relay, pos)
      end
      uart.write(0, 0x10, relay)
   end
end

do
   uart.setup(0, 115200, 8, uart.PARITY_NONE, uart.STOPBITS_1, 0)
   uart.alt(1)
   tmr.create():alarm(2000, tmr.ALARM_SINGLE, function() uart.write(0, 0x0b) end)
   tmr.create():alarm(2800, tmr.ALARM_SINGLE, function() uart.write(0, 0x0c) end)                         
end
