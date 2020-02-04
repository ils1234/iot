local cron_value = {}
local set_Cron

--cron call, only 1-6
cron_1 = function(e)
   set_relay(8, cron_value[1])
end

cron_2 = function(e)
   set_relay(8, cron_value[2])
end

cron_3 = function(e)
   set_relay(8, cron_value[3])
end

cron_4 = function(e)
   set_relay(8, cron_value[4])
end

cron_5 = function(e)
   set_relay(8, cron_value[5])
end

cron_6 = function(e)
   set_relay(8, cron_value[6])
end

set_cron = function(c)
   --split c
   local b,ctime,f
   b,_,ctime,f = string.find(c, '([/,%*%d]+%s[/,%*%d]+%s[/,%*%d]+%s[/,%*%d]+%s[/,%*%d]+)%s(%d)')
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
   local b,fd,s,c1,c2,c3,c4,c5,c6
   fd = file.open('cron_value.txt', 'r')
   if fd then
      s = fd:readline()
      b,_,c1,c2,c3,c4,c5,c6 = string.find(s, '(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)')
      cron_value[1] = tonumber(c1)
      cron_value[2] = tonumber(c2)
      cron_value[3] = tonumber(c3)
      cron_value[4] = tonumber(c4)
      cron_value[5] = tonumber(c5)
      cron_value[6] = tonumber(c6)
      fd:close()
   end
 
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
