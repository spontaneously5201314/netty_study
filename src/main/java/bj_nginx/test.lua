--not found netty for the exist roomid
local netty_list = red_global:hkeys('netty_ip_list')
local less_num = 10000

--netty list empty
if isnull(netty_list) == 1 then
    unlock(red_global, roomid)
    close_redis(red_global)
    ngx.exit(503)
    return
end

ngx.log(ngx.ERR, "go 2:", "2")

--get the best netty from list
for key, value in pairs(netty_list) do
    local temp_key = 'netty_router_'..value
    local netty_key = 'netty_monitor_'..value
    ngx.log(ngx.ERR, "netty key:", netty_key)
    ngx.log(ngx.ERR, "key:", key)
    local room_netty_state, sate_err = red_global:get(netty_key)
    ngx.log(ngx.ERR, "room_netty_state:", room_netty_state)
    if isnull(room_netty_state) == 1 then
        clearnetty(value, red_global)
    else
        local temp_num = red_global:hlen(temp_key)
        ngx.log(ngx.ERR, ' tk ', temp_key..' tm '..temp_num..' les '..less_num)
        if (temp_num < less_num) then
            ngx.log(ngx.ERR, ' change ', '1')
            redis_ip = value
            less_num = temp_num
        end
    end
end

--not found any netty then exit
if isnull(redis_ip) == 1 then
    unlock(red_global, roomid)
    close_redis(red_global)
    ngx.exit(503)
    return
end

--write to local redis
local red_blance_global = redis.new()
local ok, err = red_blance_global.connect(red_blance_global, redis_blance_host_ip, redis_blance_host_port)
red_blance_global:set_timeout(20000)

if not ok then
    unlock(red_global, roomid)
    close_redis(red_global)
    ngx.log(ngx.ERR, "connect redis error : ", redis_blance_host_ip.." "..redis_blance_host_port)
    ngx.exit(503)
    return
end

red_blance_global:set('netty_room_'..roomid, redis_ip)
close_redis(red_blance_global)

--found netty ok, add to netty_router and set netty_room
red_global:set('netty_room_'..roomid, redis_ip)
red_global:hset('netty_router_'..redis_ip, roomid, 1)

--found ok,return to pass
ngx.log(ngx.ERR, "redis_ip:", redis_ip)
ngx.var.upstream = redis_ip

unlock(red_global, roomid)
close_redis(red_global)

return