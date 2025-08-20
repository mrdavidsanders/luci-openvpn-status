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

    local conns = {}
    local pairset = {}
    local spair = {}
    dprint("*************START**************")

	-- Parse Table-ised JSON into new flat table per client
    for k, v in pairs(parsedata) do
        for kk, vv in pairs(v) do
            for kkk, vvv in pairs(vv) do
                pairset[kkk] = vvv
            end
            spair[kk] = pairset
            conns[k] = spair
            pairset = {}
        end
        spair = {}
    end

	-- For each flat Table entry, extract data from stats 
    local data = {}
    data = conns
    local row = {}
    local el = {}
    local newdata = {}
    for _k, _v in pairs(data) do
        dprint("(data) 1", _k, _v)
        for __k, __v in pairs(_v) do
            for ___k, ___v in pairs(__v) do
                dprint("\t(data) 2", __k, __v)
                if ___k == "Bytes Sent" then
                    el = {}
                    for _z, _x in pairs(__v) do
                        dprint("\t\t(el)", _z, _x)
                        el[_z] = _x
                    end
                end
                row[__k] = el
            end
            newdata[_k] = row
        end
        row = {}
    end
    dprint("*************END**************")

	-- For each flat Table entry, add IPv4 and IPv6 addrs 
    dprint("*************START************")
    el = {}
    ips = {}
    ip_row = {}
    row = {}
    for _k, _v in pairs(data) do
        dprint("(data) 1", _k, _v)
        for __k, __v in pairs(_v) do
            dprint("\t(data) 2", __k, __v)
            for _z, _x in pairs(newdata[_k]) do
                for __z, __x in pairs(_x) do
                    el[__z] = __x
                end
            end
            for _z, _x in pairs(__v) do
                if _z == "Virtual Address" then
                    if string.match(_x, "%a") then
                        dprint("(ipv6)", el, _x)
                        ips["IPv6"] = _x
                        ip_row[_k] = ips
                    else
                        dprint("(ipv4)", el, _x)
                        ips["IPv4"] = _x
                        ip_row[_k] = ips
                    end
                else
                    el[_z] = _x
                end
            end
        end
        ips = {}

        for _p, _q in pairs(row) do
            dprint("\t\t(el)", _p, _q)
        end
        for _ik, _iv in pairs(ip_row) do
            if _ik == _k then
                el["IPv4"] = _iv["IPv4"]
                el["IPv6"] = _iv["IPv6"]
            end
        end
        if el["IPv4"] ~= nil and el["IPv6"] ~= nil then
            row[_k] = el
        end
        el = {}
        data[_k] = row[_k]
    end

    for _k, _v in pairs(ip_row) do
        dprint("(ip_row) ", _k, _v)
        for __k, __v in pairs(_v) do
            dprint("(ip_row) ", __k, __v)
        end
    end
    dprint("*************END**************")

	-- Generate the Luci-fied HTML
    dprint("***********START**************")
    dprint("Beginning HTML Generation")
    local rows = {}
    local cnt = 1
    local chtml = ""
    for _z, _v in pairs(data) do
        dprint("(data) 1", _z, _v)
        rows = _v
        dprint("Rows[Common Name]=", rows["Common Name"])
        dprint("Data=", _z)
        dprint("_M=", _m)
        if _z == rows["Common Name"] then
            dprint("(CNT)", cnt)
            dprint("(data) 2", _m, rows, lastrow)
            dprint("******BEGIN ROW******")
            for __m, __row in pairs(rows) do
                dprint("(data) 3", __m, __row)
            end
            dprint("******END ROW******")
            chtml = chtml .. "<tr class='openvpntr tr cbi-rowstyle-" .. tostring(cnt) .. "'>"
            chtml = chtml .. "<td class='openvpntd td' data-title='Common Name'>" .. rows["Common Name"] .. "</td>"
            chtml =
                chtml ..
                "<td class='openvpntd td' data-title='VPN v4 / v6'>" .. rows["IPv4"] .. " / " .. rows["IPv6"] .. "</td>"
            chtml = chtml .. "<td class='openvpntd td' data-title='Remote Address'>" .. rows["Real Address"] .. "</td>"
            chtml =
                chtml ..
                "<td class='openvpntd td' data-title='RX / TX'>" ..
                    filesize(rows["Bytes Sent"]) .. " / " .. filesize(rows["Bytes Received"]) .. "</td>"
            chtml = chtml .. "<td class='openvpntd td' data-title='Connected'>" .. rows["Connected Since"] .. "</td>"
            chtml = chtml .. "<td class='openvpntd td' data-title='Refreshed'>" .. rows["Last Ref"] .. "</td>"
            chtml = chtml .. "</tr>"
            if cnt > 2 then
                cnt = 1
            end
            cnt = cnt + 1
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
