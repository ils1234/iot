pin_ir = 2

-- set gpio mode
gpio.mode(pin_ir, gpio.INT, gpio.PULLUP)

-- read ir
last_fall = 0
device_code = 0
o_device_code = 0
key_code = 0
o_key_code = 0
bit_count = 0

function ir_trig(level, when)
    fall_during = when - last_fall
    last_fall = when
    if fall_during > 13400 and fall_during < 13600 then
	bit_count = 0
	device_code = 0
	key_code = 0
	o_key_code = 0
	return
    elseif fall_during > 1024 and fall_during < 1225 then
        bit_value = 0
    elseif fall_during > 2145 and fall_during < 2345 then
        bit_value = 128
    else
        bit_count = 33
	return
    end
    bit_count = bit_count + 1
    if bit_count >=1 and bit_count <= 8 then
        device_code = bit.bor(bit.rshift(device_code, 1), bit_value)
    elseif bit_count >=9 and bit_count <= 16 then
        o_device_code = bit.bor(bit.rshift(o_device_code, 1), bit_value)
    elseif bit_count >=17 and bit_count <=24 then
        key_code = bit.bor(bit.rshift(key_code, 1), bit_value)
    elseif bit_count >=25 and bit_count <=32 then
        o_key_code = bit.bor(bit.rshift(o_key_code, 1), bit_value)
    end
    if bit_count == 32 then
       t = string.format("device %d, key %d %d", device_code, key_code, o_key_code)
       print(t)
    end
end

gpio.trig(pin_ir, "down", ir_trig)
