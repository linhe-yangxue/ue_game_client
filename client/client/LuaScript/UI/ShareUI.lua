local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local ShareUI = class("UI.ShareUI",UIBase)

--  分享ui
function ShareUI:DoInit()
    ShareUI.super.DoInit(self)
    self.prefab_path = "UI/Common/ShareUI"
end

function ShareUI:OnGoLoadedOk(res_go)
    ShareUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function ShareUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    ShareUI.super.Show(self)
end

function ShareUI:InitRes()
    self.show_share_btn = self.main_panel:FindChild("ShowShareBtn")
    self:AddClick(self.show_share_btn, function()
        self:ShowSharePanel()
    end)
    self.close_mask = self.main_panel:FindChild("CloseMask")
    self:AddClick(self.close_mask, function()
        self:Hide()
    end)
    self.close_btn = self.main_panel:FindChild("ShareImage/CloseBtn")
    self:AddClick(self.close_btn, function()
        self:Hide()
    end)

    self.mask = self.main_panel:FindChild("Mask")
    self.add_share_obj = self.main_panel:FindChild("AddShareObj")
    self.share_image = self.main_panel:FindChild("ShareImage")
    self.share_image_cmp = self.main_panel:FindChild("ShareImage"):GetComponent("RawImage")
    self.name_text = self.main_panel:FindChild("AddShareObj/NameText"):GetComponent("Text")
    self.server_text = self.main_panel:FindChild("AddShareObj/ServerText"):GetComponent("Text")
    self.save_image_btn = self.main_panel:FindChild("ShareImage/SaveImageBtn")
    self:AddClick(self.save_image_btn, function()
        self:SaveImage()
    end)
    self.share_btn = self.main_panel:FindChild("ShareImage/ShareBtn")
    self:AddClick(self.share_btn, function()
        self:ShareImage()
    end)

    self.ui_capture_screen_comp = self.main_panel:GetComponent("UICaptureScreen")
end

function ShareUI:InitUI()
    self.share_texture = nil  -- 分享的图片
    self.is_shoot = false
    self.share_image:SetActive(false)
    self.mask:SetActive(false)
    self.close_btn:SetActive(false)
    self.show_share_btn:SetActive(false)
    self.add_share_obj:SetActive(false)
    self:SetTextVal()
end

function ShareUI:Update()
    if not self.share_texture and self.is_shoot then
        if self.ui_capture_screen_comp:IsShoot() then
            self.share_texture = self.ui_capture_screen_comp:GetTexture()
            self.share_image_cmp.texture = self.share_texture
            self.mask:SetActive(true)
            self.share_image:SetActive(true)
            self.show_share_btn:SetActive(false)
            self.add_share_obj:SetActive(false)
            self.close_btn:SetActive(true)
        end
    end
end

function ShareUI:SetTextVal()
    self.name_text.text = string.format(UIConst.Text.PLAYER_NAME_FORMAT, ComMgrs.dy_data_mgr:ExGetRoleName())
    self.server_text.text = string.format(UIConst.Text.PLAYER_SERVER_FORMAT, ComMgrs.dy_data_mgr:ExGetServerId())
    self.show_share_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.SHARE_TEXT
end

function ShareUI:ShowSharePanel()
    self.show_share_btn:SetActive(false)
    self.is_shoot = true
    self.add_share_obj:SetActive(true)
    self.ui_capture_screen_comp:StartScreenShoot()
end

function ShareUI:ShareImage() -- 分享
    if not self.share_image then return end
    SpecMgrs.sdk_mgr:ShareImage(self.share_image)
end

function ShareUI:SaveImage()  -- 保存
    if not self.share_image then return end
    SpecMgrs.sdk_mgr:SaveImage(self.share_image)
end

function ShareUI:Hide()
    ShareUI.super.Hide(self)
end

return ShareUI
