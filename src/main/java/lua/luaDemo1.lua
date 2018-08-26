local function get_ip_number(ip)
    local o1,o2,o3,o4 = ip:match("(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)" )
    local num = 2^24*o1 + 2^16*o2 + 2^8*o3 + o4
    return num
end
print(get_ip_number("10.46.100.104:9007"))
--
--local o1,o2,o3,o4 = "10.46.100.104":match("(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)" )
--local num = 2^24*o1 + 2^16*o2 + 2^8*o3 + o4
--return num