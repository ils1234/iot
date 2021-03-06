print("cron\n")

--cron call
function light_on(e)
   gpio.write(pin_light, gpio.LOW)
end

function light_off(e)
   gpio.write(pin_light, gpio.HIGH)
end

function wave_on(e)
   gpio.write(pin_wave, gpio.LOW)
end

function wave_off(e)
   gpio.write(pin_wave, gpio.HIGH)
end

function fog_on(e)
   gpio.write(pin_fog, gpio.LOW)
end

function fog_off(e)
   gpio.write(pin_fog, gpio.HIGH)
end

function camera_on(e)
   gpio.write(pin_camera, gpio.HIGH)
end

function camera_off(e)
   gpio.write(pin_camera, gpio.LOW)
end

function feed_fish(e)
   gpio.write(pin_feed, gpio.LOW)
   local feedtmr = tmr.create()
   feedtmr.alarm(400, tmr.ALARM_SINGLE, function(t)
       gpio.write(pin_feed, gpio.HIGH)
   end)
end

cron_list = {}
entry_list = {}

function set_cron(c)
   --split c
   local b,e = string.find(c, ' ', 1)
   if b == nil then
      return 'fail'
   end
   local name = string.sub(c, 1, e - 1)
   local ts = e + 1
   local ctime
   local f
   b,e = string.find(c, ' ', e + 1)
   if b == nil then
      -- delete
      if cron_list[name] == nil then
	 return 'not exist'
      else
	 cron_list[name] = nil
	 entry_list[name].unschedule()
	 entry_list[name] = nil
	 return 'deleted'
      end
   else
      b,e = string.find(c, ' ', e + 1)
      if b == nil then
	 return 'fail'
      end
      b,e = string.find(c, ' ', e + 1)
      if b == nil then
	 return 'fail'
      end
      b,e = string.find(c, ' ', e + 1)
      if b == nil then
	 return 'fail'
      end
      b,e = string.find(c, ' ', e + 1)
      if b == nil then
	 return 'fail'
      end
      ctime = string.sub(c, ts, b - 1)
      f = string.sub(c, e + 1)
      if _G[f] == nil then
	 return 'fail'
      end
      if cron_list[name] == nil then
	 --new
	 cron_list[name] = c
	 entry_list[name] = cron.schedule(ctime, _G[f])
	 return 'created'
      else
	 --update
	 cron_list[name] = c
	 entry_list[name]:schedule(ctime)
	 entry_list[name]:handler(_G[f])
	 return 'updated'
      end
   end   
end

function list_cron()
   local res = ''
   local k,v
   for k,v in pairs(cron_list) do
      res = res .. v .. '\n'
   end
   if res == '' then
      res = 'empty'
   end
   return res
end

function clear_cron()
   cron.reset()
   cron_list = {}
   entry_list = {}
end

function save_cron()
   local fd = file.open('cron.txt', 'w')
   if fd then
      local k,v
      for k,v in pairs(cron_list) do
	 fd:write(v .. "\n")
      end
      fd:close()
   end
end

-- load_cron on boot
do
   local fd = file.open('cron.txt', 'r')
   if fd then
      while true do
	 local s = fd:readline()
	 if s == nil then
	    break
	 end
	 local e = string.find(s, "\n", 1)
	 if e ~= nil then
	    s = string.sub(s, 1, e - 1)
	 end
	 set_cron(s)
      end
   end
end
