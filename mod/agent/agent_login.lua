local skynet = require "skynet"
local env = require "faci.env"
local agent_info = require("agent.agent_info")

function env.login(account)
    -- 从数据库里加载数据
    agent_info:init_agent(account.uid, 0, 1, "", 0, account, skynet.self())
    agent_info:load_agent_info()
    agent_info:update_agent_info()
    agent_info:start_save_agent_info_timer(10)

    return true
end

function env.logout(account)
    agent_info:stop_save_agent_info_timer()
    --是否要 取消 定时保存操作？
end