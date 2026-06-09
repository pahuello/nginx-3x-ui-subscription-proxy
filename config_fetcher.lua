local http = require "resty.http"

local function trim(s)
    if not s then
        return ""
    end
    return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function is_truthy(value)
    local v = string.lower(trim(value))
    return v == "1" or v == "true" or v == "yes" or v == "on"
end

local function routing_enabled()
    return is_truthy(os.getenv("ROUTING_ENABLE"))
end

local function build_metadata_prefix()
    local lines = {}

    local title = trim(os.getenv("PROFILE_TITLE"))
    if title ~= "" then
        table.insert(lines, "#profile-title: " .. title)
    end

    local interval = trim(os.getenv("PROFILE_UPDATE_INTERVAL"))
    if interval ~= "" then
        table.insert(lines, "#profile-update-interval: " .. interval)
    end

    local announce = trim(os.getenv("ANNOUNCE"))
    if announce ~= "" then
        table.insert(lines, "#announce: " .. announce)
    end

    if routing_enabled() then
        table.insert(lines, "#routing-enable: 1")
    else
        table.insert(lines, "#routing-enable: 0")
    end

    local routing_rules = trim(os.getenv("ROUTING_RULES"))
    if routing_rules ~= "" and routing_enabled() then
        table.insert(lines, routing_rules)
    end

    return table.concat(lines, "\n") .. "\n"
end

local function apply_happ_headers()
    ngx.header["X-Sub-Proxy"] = PATCH_VERSION

    local title = trim(os.getenv("PROFILE_TITLE"))
    if title ~= "" then
        ngx.header["profile-title"] = title
    end

    local interval = trim(os.getenv("PROFILE_UPDATE_INTERVAL"))
    if interval ~= "" then
        ngx.header["profile-update-interval"] = interval
    end

    local announce = trim(os.getenv("ANNOUNCE"))
    if announce ~= "" then
        ngx.header["announce"] = announce
    end

    ngx.header["routing-enable"] = routing_enabled() and "1" or "0"

    local routing_rules = trim(os.getenv("ROUTING_RULES"))
    if routing_rules ~= "" and routing_enabled() then
        ngx.header["routing"] = routing_rules
    end

    ngx.header["Content-Disposition"] = 'attachment; filename="subscription"'
end

local servers_str = os.getenv("SERVERS")
if not servers_str or trim(servers_str) == "" then
    ngx.log(ngx.ERR, "SERVERS environment variable is missing or empty")
    ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

local servers = {}
for server in string.gmatch(servers_str, "%S+") do
    table.insert(servers, server)
end

local httpc = http.new()
local configs = {}

for _, base_url in ipairs(servers) do
    local url = base_url .. ngx.var.sub_id
    local res, err = httpc:request_uri(url, {
        method = "GET",
        ssl_verify = false,
    })

    if res and res.status == 200 then
        local decoded_config = ngx.decode_base64(res.body)
        if decoded_config then
            table.insert(configs, decoded_config)
        else
            ngx.log(ngx.ERR, "Failed to decode base64 from ", url)
        end
    else
        local status = res and res.status or "nil"
        ngx.log(ngx.ERR, "Error fetching from ", url, ": ", err or ("HTTP " .. tostring(status)))
    end
end

if #configs > 0 then
    local metadata_prefix = build_metadata_prefix()
    local combined_configs = metadata_prefix .. table.concat(configs)
    local encoded_combined_configs = ngx.encode_base64(combined_configs)

    ngx.header.content_type = "text/plain; charset=utf-8"
    apply_happ_headers()
    ngx.print(encoded_combined_configs)
else
    ngx.status = ngx.HTTP_BAD_GATEWAY
    ngx.say("No configs available")
end
