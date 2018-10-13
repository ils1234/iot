print('temperature\n')

tmr_ds18b20 = 1
pin_ds18b20 = 11

ds_addr = {"28:FF:89:42:75:16:03:E9"}

-- set ds18b20
ds18b20.setup(pin_ds18b20)
ds18b20.setting(ds_addr, 12)

temp, temp_dec = 26, 300

-- temp read callback
function pt(index, rom, res, t, td, par)
    temp = t
    temp_dec = td
end

function temp_read()
   ds18b20.read(pt, ds_addr)
end

-- tmr set
tmr.alarm(tmr_ds18b20, 1000, tmr.ALARM_AUTO, temp_read)
