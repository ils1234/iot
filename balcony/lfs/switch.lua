local pin_a, pin_b, pin_c = ...

get_switch = function()
   local va = gpio.read(pin_a)
   local vb = gpio.read(pin_b)
   local vc = gpio.read(pin_c)
   return va,vb,vc
end

set_switch = function(pin, val)
   if pin == 0 then
      if val == 0 then
         gpio.write(pin_a, gpio.LOW)
      else
         gpio.write(pin_a, gpio.HIGH)
      end
   elseif pin == 1 then
      if val == 0 then
         gpio.write(pin_b, gpio.LOW)
      else
         gpio.write(pin_b, gpio.HIGH)
      end
   elseif pin == 2 then
      if val == 0 then
         gpio.write(pin_c, gpio.LOW)
      else
         gpio.write(pin_c, gpio.HIGH)
      end
   end
end

toggle_switch = function(pin)
   local val
   if pin == 0 then
      val = gpio.read(pin)
      if val == gpio.HIGH then
         gpio.write(pin_a, gpio.LOW)
      else
         gpio.write(pin_a, gpio.HIGH)
      end
   elseif pin == 1 then
      val = gpio.read(pin)
      if val == gpio.HIGH then
         gpio.write(pin_b, gpio.LOW)
      else
         gpio.write(pin_b, gpio.HIGH)
      end
   elseif pin == 2 then
      val = gpio.read(pin)
      if val == gpio.HIGH then
         gpio.write(pin_c, gpio.LOW)
      else
         gpio.write(pin_c, gpio.HIGH)
      end
   end
end

do
   gpio.mode(pin_a, gpio.OUTPUT)
   gpio.mode(pin_b, gpio.OUTPUT)
   gpio.mode(pin_c, gpio.OUTPUT)
   gpio.write(pin_a, gpio.HIGH)
   gpio.write(pin_b, gpio.HIGH)
   gpio.write(pin_c, gpio.HIGH)
end
