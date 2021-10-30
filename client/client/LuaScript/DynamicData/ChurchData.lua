local ChurchData = class("DynamicData.ChurchData")
local redpoint_control_id = 5

function ChurchData:DoInit()
    self.title_datas = {}
    self.is_worshiped = false
end

function ChurchData:GetAllTitleId()
    local keys = {}
    for key, _ in pairs(self.title_datas) do
        table.insert(keys, key)
    end
    table.sort(keys)
    return keys
end

function ChurchData:GetTitleDataById(title_id)
    if not title_id then
        return
    end
    return self.title_datas[title_id]
end

function ChurchData:GetIsWorshiped()
    return self.is_worshiped
end

----Sproto Define begin----
--打开ChurchUI时调用该方法
function ChurchData:GetChurchData(cb)
    local func = function(response)
        if response.errcode ~= 0 then
            return
        end
        if response.godfather_dict then
            self.title_datas = response.godfather_dict
        end
        cb()
    end
    SpecMgrs.msg_mgr:SendGetChurchData(nil, func)
end

--ChurchUI点击膜拜时调用该方法
function ChurchData:WorshipGodfather(cb)
    SpecMgrs.msg_mgr:SendWorshipGodfather(nil, cb)
end

--膜拜后接收该协议
function ChurchData:NotifyUpdateWorshipData(msg)
    if msg.is_worship ~= nil then
        self.is_worshiped = msg.is_worship
        SpecMgrs.redpoint_mgr:SetControlIdActive(redpoint_control_id, {self.is_worshiped and 0 or 1})
    end
end
----Sproto Define end----
return ChurchData