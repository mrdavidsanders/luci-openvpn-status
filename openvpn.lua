  filesize = require "filesize"
  require "io"
  require "string"
  local cjson = require "cjson"
  local test = assert(io.open("./openvpn_test.json", "r"))
  local parsedata = cjson.decode(test:read("*all"))
  test:close()
  local conns = {}
  local pairset = {}
  local spair={}
  __DEBUG__=1

  function dprint(...)
	date = os.date("%x %X")
	local args="[dbg] ["..date.."] "
  	if __DEBUG__ == 1 then	
		for i,v in ipairs(arg) do
 			args = args .. tostring(v) .. " "
		end
	print(args)
	end
  end 
 
  dprint("*************START**************")
  for k, v in pairs(parsedata) do
      for kk, vv in pairs(v) do
  	for kkk, vvv in pairs(vv) do
  		pairset[kkk] = vvv
          end
  	spair[kk] = pairset
      	conns[k] = spair
   	pairset = {}  
      end
      spair={}
  end
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
					ips['IPv6'] = _x
					ip_row[_k] = ips
				else		
					dprint("(ipv4)", el, _x)
					ips['IPv4'] = _x
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
  
  dprint("***********START**************")
  dprint("Beginning HTML Generation")
  local rows = {}
  cnt=1
  io.output(assert(io.open("/tmp/test_openvpn_new.htm", "w"))) 
  for _z,_v in pairs(data) do
		dprint("(data) 1", _z, _v)
			rows = _v
			dprint("Rows[Common Name]=", rows["Common Name"])
			dprint("Data=", _z)
			dprint("_M=", _m)
			if _z == rows["Common Name"] then
				dprint("(data) 2", _m, rows, lastrow)
				dprint("******BEGIN ROW******")
				for __m, __row in pairs(rows) do	
					dprint("(data) 3", __m, __row)
				end
				dprint("******END ROW******")
		        	io.write("<tr class='tr cbi-rowstyle-",cnt,"'>")
       		                io.write("<td class='td' data-sortable-row='true'>", rows["Common Name"] ,"</td>")
       		                io.write("<td class='td' data-sortable-row='true'>", rows["IPv4"],"</td>")
       		                io.write("<td class='td' data-sortable-row='true'>", rows["IPv6"],"</td>")
       		                io.write("<td class='td' data-sortable-row='true'>", rows["Real Address"] ,"</td>")
       		                io.write("<td class='td' data-sortable-row='true'>", rows["Bytes Sent"], "</td>")
       		                io.write("<td class='td' data-sortable-row='true'>", rows["Bytes Received"] ,"</td>")
       		                io.write("<td class='td' data-sortable-row='true'>", rows["Connected Since"], "</td>")
       	       		        io.write("<td class='td' data-sortable-row='true'>", rows["Last Ref"] ,"</td>")
      			        io.write("</tr>")
                		if cnt > 2 then
                			cnt = 1
                		end
       				cnt = cnt + 1
			end
  end
  dprint("*************END**************")
--[[

  local client_output = luci.sys.exec("cat /tmp/openvpn_new.htm")
  

  -%>

<div class="cbi-section">
        <h3><%:Active OpenVPN Clients%></h3>
        <table class="table">
                <tr class="tr table-titles">
                        <th class="th" data-sortable-row="true"><%:Common Name%></th>
                        <th class="th" data-sortable-row="true"><%:VPN v4%></th>
                        <th class="th" data-sortable-row="true"><%:VPN v6%></th>
                        <th class="th" data-sortable-row="true"><%:Remote Address%></th>
                        <th class="th" data-sortable-row="true"><%:Bytes Out%></th>
                        <th class="th" data-sortable-row="true"><%:Bytes In%></th>
                        <th class="th" data-sortable-row="true"><%:Connected%></th>
                        <th class="th" data-sortable-row="true"><%:Refreshed%></th>
                </tr>
                <%=client_output%>
        </table>
</div>
--]]
