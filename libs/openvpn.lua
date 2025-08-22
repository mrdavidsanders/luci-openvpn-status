filesize = require "filesize"
require "io"
require "string"

local function dprint(...)
    if __DEBUG__ == 1 then
        date = os.date("%x %X")
        local args = "[dbg] [" .. date .. "] "

        for i, v in ipairs(arg) do
            args = args .. tostring(v) .. " "
        end
        print(args)
    end
end

local function openvpn()
    if isdebug == true then
        __DEBUG__ = 1
        test = assert(io.open("./test/openvpn_test.json", "r"))
        dprint("DEBUG ON")
    else
        __DEBUG__ = 0
        test = assert(io.open("/tmp/openvpn_new.json", "r"))
    end

    if isluci == false then
        local cjson = require "cjson"
        parsedata = cjson.decode(test:read("*all"))
        test:close()
    else
        require "luci.sys"
        require "luci.jsonc"
        parsedata = luci.jsonc.parse(test:read("*all"))
        test:close()
    end


    dprint("*************START**************")
    local data = {}
    local row = {}
    local line = {}
	-- Parse the JSON
    for k, v in pairs(parsedata) do
        local row = {}
        local line = {}
        cn = v['Common Name']
        dprint("CN: ", cn)
        data[cn] = {}
    -- first level is just more tables
        for kk, vv in pairs(v) do
            -- Sort IP Addresses by type
            if kk == "Virtual Address" then
                for _, vvv in pairs(vv) do
                     if string.match(vvv, "%a")  then
                        line["IPv6"]=vvv   
                        dprint("adding", vvv)
                    else
                        line["IPv4"]=vvv
                        dprint("adding", vvv)
                    end
                end
                table.insert(row, line)
            else
                line[kk]=vv
                dprint("adding", kk, vv, "to", cn)
            end
        end
        table.insert(data[cn], line)
    end
	
    
	-- Generate the Luci-fied HTML
    dprint("***********START**************")
    dprint("Beginning HTML Generation")
    local rows = {}
    local cnt = 1
    local chtml = ""
    for _z, _v in pairs(data) do
        dprint("(data) 1", _z, _v)
        for key, row in pairs(_v) do
            dprint("Table is: ", row)
            rows = row
            dprint("******BEGIN ROW******")
            dprint(rows['Common Name'])
            chtml = chtml 
            .. "<tr class='openvpntr tr cbi-rowstyle-" .. tostring(cnt) .. "'>"
            .. "<td class='openvpntd td' data-title='Common Name'>" .. rows["Common Name"] .. "</td>"
            .. "<td class='openvpntd td' data-title='VPN v4 / v6'>" .. rows["IPv4"] .. " / " .. rows["IPv6"] .. "</td>"
            .. "<td class='openvpntd td' data-title='Remote Address'>" .. rows["Real Address"] .. "</td>"
            .. "<td class='openvpntd td' data-title='RX / TX'>" 
            .. filesize(rows["Bytes Sent"]) .. " / " .. filesize(rows["Bytes Received"]) .. "</td>"
            .. "<td class='openvpntd td' data-title='Connected'>" .. rows["Connected Since"] .. "</td>"
            .. "<td class='openvpntd td' data-title='Refreshed'>" .. rows["Last Ref"] .. "</td>"
            .. "</tr>"
            if cnt > 2 then
                cnt = 1
            end
            cnt = cnt + 1
            dprint("******END ROW******")
        end                      
    end
    dprint("*************END**************")
    if __DEBUG__ == 0 then
        return chtml
    else
        return
    end
end

return openvpn
