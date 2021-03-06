local redis_host_ip = '10.46.100.26'  --wg redis
local redis_host_port = '6400'

local redis_blance_host_ip = '10.46.100.132' --local redis
local redis_blance_host_port = '6400'

--local redis_host_ip = '10.60.81.34'
--local redis_host_port = '6401'

local function get_ip_number(ip)
    local o1,o2,o3,o4 = ip:match("(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)" )
    local num = 2^24*o1 + 2^16*o2 + 2^8*o3 + o4
    return num
end


local function close_redis(red)
    if not red then
        return
    end

    local pool_max_idle_time = 20000
    local pool_size = 1000
    local ok, err = red:set_keepalive(pool_max_idle_time, pool_size)

    if not ok then
        ngx.log(ngx_ERR, "set redis keepalive error : ", err)
    end
end

function isnull(obj)
    if obj == ngx.null or obj == nil then
        return 1;
    end

    if type(obj) == "table" then
        if _G.next(obj) == nil then
            return 1
        end
    end
end

--split string to get roomid
function lua_string_split(str, split_char)
    local sub_str_tab = {}

    while (true) do
        local pos = string.find(str, split_char)
        if (not pos) then
            local size_t = table.getn(sub_str_tab)
            table.insert(sub_str_tab,size_t+1,str)
            break
        end

        local sub_str = string.sub(str, 1, pos - 1)
        local size_t = table.getn(sub_str_tab)
        table.insert(sub_str_tab,size_t+1,sub_str)
        local t = string.len(str)
        str = string.sub(str, pos + 1, t)
    end

    return sub_str_tab
end

--for clear a timeout netty
function clearnetty(nettyip, redis_local)
    local netty_room = redis_local:hgetall('netty_router_'..nettyip)
    if isnull(netty_room) == 1 then
        return
    end

    ngx.log(ngx.ERR, "netty_room:", 'netty_router_'..nettyip)
    ngx.log(ngx.ERR, "size:", table.getn(netty_room))
    for key, value in pairs(netty_room) do
        if key % 2 == 1 then
            ngx.log(ngx.ERR, "del:", value)
            redis_local:del('netty_room_'..value)
        end
    end
    ngx.log(ngx.ERR, "del:", 'netty_router_'..nettyip)
    redis_local:del('netty_router_'..nettyip)
    redis_local:hdel('netty_ip_list', nettyip)
end

--get a exist room netty id
function getroomnetty(roomid, redis_local)
    local room_key = 'netty_room_'..roomid
    ngx.log(ngx.ERR, "room key:", room_key)
    local room_netty, err = redis_local:get(room_key)
    ngx.log(ngx.ERR, "room netty:", room_netty)
    if isnull(room_netty) == 1 then
        return ngx.null
    end

    ngx.log(ngx.ERR, "return netty key:", room_netty)
    return room_netty
end

function lock(redis_local, roomid)
    local st = os.time()
    while(1) do
        local lockstr = "local ok = redis.call('setnx', 'nginx_netty_lock_"..roomid.."', 'lock');if ok == 1 then redis.call('expire', 'nginx_netty_lock_"..roomid.."', 2) end; return ok";
        ngx.log(ngx.ERR, "lockstr: ", lockstr)
        local lockok = redis_local:eval(lockstr, 0);
        if lockok == 1 then
            return
        end
        os.execute("usleep 1000")
        if (os.difftime(os.time(), st) > 5) then
            st = os.time()
            redis_local:del("nginx_netty_lock_"..roomid);
            ngx.log(ngx.ERR, "found a time out", os.clock())
        end
    end
end

function unlock(redis_local, roomid)
    local lockstr = "nginx_netty_lock_"..roomid
    ngx.log(ngx.ERR, "unlockstr: ", lockstr)
    redis_local:del(lockstr);
end

--init a redis
local redis = require "redis"

--split uri for get roomid
local args = lua_string_split(ngx.var.uri, '/')
local size = table.getn(args)

--uri arg number size error
if (size < 3) then
    ngx.exit(503)
    return
end

--get roomid
local roomid = args[2]
ngx.log(ngx.ERR, "roomid:", roomid)

--get the netty for exist roomid
if (tonumber(roomid) >= 0) then

    local red_blance_global = redis.new()
    local ok, err = red_blance_global.connect(red_blance_global, redis_blance_host_ip, redis_blance_host_port)
    red_blance_global:set_timeout(20000)

    --get redis connect error
    if not ok then
        ngx.log(ngx.ERR, "connect rdis error : ", redis_blance_host_ip.." "..redis_blance_host_port)
        ngx.exit(503)
        return
    end

    local redis_ip = getroomnetty(roomid, red_blance_global)
    ngx.log(ngx.ERR, "get netty ip :", redis_ip)

    --get the netty for exist roomid ok
    if isnull(redis_ip) ~= 1 then
        ngx.log(ngx.ERR, "redis_ip :", redis_ip)
        ngx.var.upstream = redis_ip
        close_redis(red_blance_global)
        return
    end
    ngx.log(ngx.ERR, "redis_ip is null", "")
    close_redis(red_blance_global)

else
    local red_global = redis.new()
    local ok, err = red_global.connect(red_global, redis_host_ip, redis_host_port)
    red_global:set_timeout(20000)

    --get redis connect error
    if not ok then
        ngx.log(ngx.ERR, "connect local redis error : ", redis_host_ip.." "..redis_host_port)
        ngx.exit(503)
        return
    end

    local netty_list = red_global:hkeys('netty_ip_list')
    for key, value in pairs(netty_list) do
        local redis_ip = value

        local ip_args = lua_string_split(redis_ip, ':')
        ngx.log(ngx.ERR, "check redis_ip:", redis_ip..' '..table.getn(ip_args))
        if (table.getn(ip_args) == 2) then
            ngx.log(ngx.ERR, "check ip_number :", ip_args[1])

            local ipnumber = get_ip_number(ip_args[1]) * -1
            ngx.log(ngx.ERR, "check ipnumber :", ipnumber..' '..roomid)
            if (ipnumber == tonumber(roomid)) then
                ngx.log(ngx.ERR, "redis_ip:", redis_ip)
                ngx.var.upstream = redis_ip
                close_redis(red_global)
                return
            end
        end
    end

    close_redis(red_global)
    ngx.exit(503)

end

ngx.exit(503)

return