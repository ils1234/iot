print("alarm\n")

alarm_filter_overflow = false
alarm_filter_dry = false
alarm_main_dry = false
alarm_main_cold = false
alarm_main_hot = false

alarm_url = "http://192.168.1.12/index.php?r=site/alarm&id="

local v
v = gpio.read(pin_high_level)
if v == gpio.HIGH then
   if alarm_filter_overflow == false then
      alarm_filter_overflow = true
      http.get(alarm_url .. '1', nil, http_get)
   end
else
   if alarm_filter_overflow == true then
      alarm_filter_overflow = false
      http.get(alarm_url .. '2', nil, http_get)
   end
end
v = gpio.read(pin_low_level)
if v == gpio.LOW then
   if alarm_filter_dry == false then
      alarm_filter_dry = true
      http.get(alarm_url .. '3', nil, http_get)
   end
else
   if alarm_filter_dry == true then
      alarm_filter_dry = false
      http.get(alarm_url .. '4', nil, http_get)
   end
end
v = gpio.read(pin_main_water_level)
if v == gpio.LOW then
   if alarm_main_dry == false then
      alarm_main_dry = true
      http.get(alarm_url .. '5', nil, http_get)
   end
else
   if alarm_main_dry == true then
      alarm_main_dry = false
      http.get(alarm_url .. '6', nil, http_get)
   end
end
if temp < 25 then
   if alarm_main_cold == false then
      alarm_main_cold = true
      http.get(alarm_url .. '7', nil, http_get)
   end
else
   if alarm_main_cold  == true then
      alarm_main_cold = false
      http.get(alarm_url .. '8', nil, http_get)
   end
end
if temp > 29 then
   if alarm_main_hot == false then
      alarm_main_hot = true
      http.get(alarm_url .. '9', nil, http_get)
   end
else
   if alarm_main_hot  == true then
      alarm_main_hot = false
      http.get(alarm_url .. '10', nil, http_get)
   end
end
