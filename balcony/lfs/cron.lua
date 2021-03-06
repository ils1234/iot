local set_Cron

--cron call, only 1-6
cron_00 = function(e)
   set_switch(0, 0)
end

cron_01 = function(e)
   set_switch(0, 1)
end

cron_10 = function(e)
   set_switch(1, 0)
end

cron_11 = function(e)
   set_switch(1, 1)
end

cron_20 = function(e)
   set_switch(2, 0)
end

cron_21 = function(e)
   set_switch(2, 1)
end

cron_30 = function(e)
   start_charge()
end

set_cron = function(c)
   --split c
   local b,ctime,f,e
   b,_,ctime,f = string.find(c, '([/,%*%d]+%s[/,%*%d]+%s[/,%*%d]+%s[/,%*%d]+%s[/,%*%d]+)%s(%d%d)')
   if b == nil then
      return
   end
   f = 'cron_' .. f
   if _G[f] == nil then
      return
   end
   e = cron.schedule(ctime, _G[f])
   if e == nil then
      print("set cron %s failed", c)
   end
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
