local ws=require "wsclient"

local Hander={}

function login_loginresult(msg)
	print(msg.error)
	if msg.error=="login success" or msg.result == 0 then
		ws.create_room("gp")
		--ws.enter_room("gp")
	else 
		print("account:"..msg.account..",login err:",msg.error)
	end

end

function create_room(msg)
	print("create_room ret:"..msg.result)
	ws.enter_room('gp', msg.room_id)
end


function enter_room(msg)
	print("enter_room ret:"..msg.result)
	--ws.leave_room()
end

function leave_room(msg)
	print("leave_room ret:"..msg.result)
end

function game_start(msg)
	print("ddz game start")
end

function Hander.CallBack(msg)
	if msg._cmd then
		funcname=string.gsub(msg._cmd,"%.","_")
		if _G[funcname] then
			_G[funcname](msg)
		end
	end
end

ws.init(nil,nil,Hander)
ws.login("kang","111111")
ws.start()


