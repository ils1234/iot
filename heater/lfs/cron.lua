local set_Cron

--cron call
cron_0 = function(e)
   backlight_off()
end

cron_1 = function(e)
   backlight_on()
end

cron_10 = function(e)
   temp_limit = 10
end

cron_22 = function(e)
   temp_limit = 22
end

cron_23 = function(e)
   temp_limit = 23
end

cron_24 = function(e)
   temp_limit = 24
end

cron_25 = function(e)
   temp_limit = 25
end

cron_26 = function(e)
   temp_limit = 26
end

set_cron = function(c)
   --split c
   local b,ctime,f
   b,_,ctime,f = string.find(c, '([/,%*%d]+%s[/,%*%d]+%s[/,%*%d]+%s[/,%*%d]+%s[/,%*%d]+)%s(%d+)')
   if b == nil then
      return
   end
   f = 'cron_' .. f
   if _G[f] == nil then
      return
   end
   cron.schedule(ctime, _G[f])
end

reload_cron = function()
   cron.reset()
   local fd,s

   fd = file.open('cron.txt', 'r')
   if fd then
      while true do
         local s = fd:readline()
         if s == nil then
            break
         end
         set_cron(s)
      end
      fd:close()
   end
   fd = nil
end

do
   reload_cron()
end
