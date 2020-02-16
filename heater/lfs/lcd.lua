local pin_cs, pin_sid, pin_clk = ...

local enable = function()
   gpio.write(pin_cs, gpio.HIGH)
end

local disable = function()
   gpio.write(pin_cs, gpio.LOW)
end

local send_byte = function(data)
   for i = 7, 0, -1 do
      if bit.isset(data, i) then
	 gpio.write(pin_sid, gpio.HIGH)
      else
	 gpio.write(pin_sid, gpio.LOW)
      end
      gpio.write(pin_clk, gpio.HIGH)
      gpio.write(pin_clk, gpio.LOW)
   end
end

local write_cmd = function(data)
   local hdata = bit.band(data, 0xf0)
   local ldata = bit.lshift(data, 4)
   send_byte(0xf8)
   send_byte(hdata)
   send_byte(ldata)
end

local write_data = function(data)
   local hdata = bit.band(data, 0xf0)
   local ldata = bit.lshift(data, 4)
   send_byte(0xfa)
   send_byte(hdata)
   send_byte(ldata)
end

local clear_screen = function()
   write_cmd(0x30)
   write_cmd(0x01)
end

local lcd_print = function(y, x, data)
   local addr
   if y == 0 then
      addr = 0x80 + x
   elseif y == 1 then
      addr = 0x90 + x
   elseif y == 2 then
      addr = 0x88 + x
   else
      addr = 0x98 + x
   end
   enable()
   write_cmd(addr)
   for i=1, string.len(data) do
      write_data(string.byte(data,i,i))
   end
   disable()
end

local lcd_init = function()
   enable()
   write_cmd(0x30)
   write_cmd(0x0c)
   write_cmd(0x01)
   disable()
end

local display, display_t, display_h, display_r

display = function()
   local sec = rtctime.get() + 28800
   local tm = rtctime.epoch2cal(sec)
   local date = string.format("%04d-%02d-%02d %02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"])

   lcd_print(0, 0, date)
   tmr.create():alarm(1000, tmr.ALARM_SINGLE, display_t)
end

display_t = function()
   local v
   if temp_dec >= 100 then
      v = temp_dec / 100
   else
      v = 0
   end
   lcd_print(1, 0, string.format('室内温度  %d.%d℃', temp, v))
   tmr.create():alarm(1000, tmr.ALARM_SINGLE, display_h)
end

display_h = function()
   local v
   if humi_dec >= 100 then
      v = humi_dec / 100
   else
      v = 0
   end
   lcd_print(2, 0, string.format('空气湿度  %d.%d％', humi, v))
   tmr.create():alarm(1000, tmr.ALARM_SINGLE, display_r)
end

display_r = function()
   lcd_print(3, 0, string.format('锅炉%4s %5d分', relay, current))
end

do
   gpio.mode(pin_cs, gpio.OUTPUT)
   gpio.mode(pin_sid, gpio.OUTPUT)
   gpio.mode(pin_clk, gpio.OUTPUT)
   gpio.write(pin_cs, gpio.LOW)
   gpio.write(pin_sid, gpio.LOW)
   gpio.write(pin_clk, gpio.LOW)

   lcd_init()
   display()
   tmr.create():alarm(60000, tmr.ALARM_AUTO, display)
end
