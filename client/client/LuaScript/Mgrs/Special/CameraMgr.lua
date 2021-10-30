-- 相机管理类，管理下面一大堆相机

local CameraMgr = class("Mgrs.Special.CameraMgr")

function CameraMgr:DoInit()
    self.camera_ui = GameObject.Find("/UICamera")
    self.camera_main = GameObject.Find("/Main Camera")
    GameObject.DontDestroyOnLoad(self.camera_ui)
end

function CameraMgr:Update(delta_time)

end

function CameraMgr:DoDestroy()

end

function CameraMgr:GetUICamera()
    return self.camera_ui
end

function CameraMgr:GetMainCamera()
    return self.camera_main
end


return CameraMgr
