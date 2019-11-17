local cron_value = {}
local set_Cron

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
   local fd,s
   fd = file.open('cron.txt', 'r')
   if fd then
      while true do
         s = fd:readline()
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
