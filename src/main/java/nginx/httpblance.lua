local redis_host_ip = '10.46.100.26'
local redis_host_port = '6400'

--local redis_host_ip = '10.60.81.34'
--local redis_host_port = '6401'

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
	
		local netty_key = 'netty_monitor_'..room_netty
	ngx.log(ngx.ERR, "netty key:", netty_key)
		local room_netty_state, sate_err = redis_local:get(netty_key)
	ngx.log(ngx.ERR, "room_netty_state:", room_netty_state)   
		if isnull(room_netty_state) == 1 then
			clearnetty(room_netty, redis_local)
			return ngx.null
		end
	ngx.log(ngx.ERR, "return netty key:", room_netty)
		return room_netty
	end
	
	function lock(redis_local, roomid)
		local st = os.time()
		while(1) do
			local lockstr = "local ok = redis.call('setnx', 'nginx_netty_lock_"..roomid.."', 'lock');if ok == 1 then redis.call('expire', 'nginx_netty_lock', 2) end; return ok";
ngx.log(ngx.ERR, "lockstr: ", lockstr)
			local lockok = redis_local:eval(lockstr, 0);
			if lockok == 1 then
				return
			end
			os.execute("usleep 1000")
			if (os.difftime(os.time(), st) > 5) then
				st = os.time()
				redis_local:del('nginx_netty_lock');
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
local red_global = redis.new()
local ok, err = red_global.connect(red_global, redis_host_ip, redis_host_port)
red_global:set_timeout(20000)

--get redis connect error
if not ok then
	close_redis(red_global)
	ngx.exit(503)
	return
end

--get roomid
local roomid = -1

local uri_args = ngx.req.get_uri_args()
if isnull(uri_args) == 1 then
	close_redis(red_global)
	ngx.exit(503)
	return
end

for k, v in pairs(uri_args) do
	if type(v) ~= "table" then
		if k == "roomId" then
			roomid = v
		end
	end
end

if roomid == -1 then
	close_redis(red_global)
	ngx.exit(503)
	return	
end

ngx.log(ngx.ERR, "roomid:", roomid)

lock(red_global, roomid)

--get the netty for exist roomid
local redis_ip = getroomnetty(roomid, red_global)

--get the netty for exist roomid ok
if isnull(redis_ip) ~= 1 then
ngx.log(ngx.ERR, "redis_ip:", redis_ip)
	ngx.var.upstream = redis_ip
	unlock(red_global, roomid)
	close_redis(red_global)
	return
end

ngx.log(ngx.ERR, "go 1:", "1")

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

--found netty ok, add to netty_router and set netty_room
red_global:set('netty_room_'..roomid, redis_ip)
red_global:hset('netty_router_'..redis_ip, roomid, 1)

--found ok,return to pass
ngx.log(ngx.ERR, "redis_ip:", redis_ip)
ngx.var.upstream = redis_ip

unlock(red_global, roomid)
close_redis(red_global)

return
