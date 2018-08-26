function isnull(obj)
	if obj == ngx.null or obj == nil then
		return 1
	end
	
	if type(obj) == "table" then
		if _G.next(obj) == nil then
			return 1
		end
	end
end

local uri = ngx.var.request_uri
if isnull(uri) == 1 then
	ngx.var.upstream = "arrow_dc"
	return		
end

local uri_args = ngx.req.get_uri_args()
if isnull(uri_args) ~= 1 then
	for k, v in pairs(uri_args) do
		if type(v) ~= "table" then
			if k == "key" then
				if v =="20" then
					ngx.var.upstream = "msg_dc"
					return
				end
			end
		end
	end
end

ngx.var.upstream = "arrow_dc"
return