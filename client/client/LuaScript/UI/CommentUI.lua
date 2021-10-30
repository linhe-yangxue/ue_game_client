local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local CommentUI = class("UI.CommentUI",UIBase)

--  评论ui
function CommentUI:DoInit()
    CommentUI.super.DoInit(self)
    self.prefab_path = "UI/Common/CommentUI"
end

function CommentUI:OnGoLoadedOk(res_go)
    CommentUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function CommentUI:Show(index)
    self.comment_index = index
    if self.is_res_ok then
        self:InitUI()
    end
    CommentUI.super.Show(self)
end

function CommentUI:InitRes()
    self.tip_comment_panel = self.main_panel:FindChild("TipCommentPanel")
    self.unit_rect = self.main_panel:FindChild("TipCommentPanel/UnitRect")
    self.comment_btn = self.main_panel:FindChild("TipCommentPanel/BtnList/CommentBtn")
    self:AddClick(self.comment_btn, function()
        self:ClickCommentBtn()
    end)
    self.not_comment_btn = self.main_panel:FindChild("TipCommentPanel/BtnList/NotCommentBtn")
    self:AddClick(self.not_comment_btn, function()
        self:ClickNotCommentBtn()
    end)
    self.next_time_btn = self.main_panel:FindChild("TipCommentPanel/BtnList/NextTimeBtn")
    self:AddClick(self.next_time_btn, function()
        SpecMgrs.ui_mgr:HideUI(self)
    end)
    self.comment_tip_text = self.main_panel:FindChild("TipCommentPanel/CommentTipText"):GetComponent("Text")
    self.give_score_panel = self.main_panel:FindChild("GiveScorePanel")
    self.give_score_title = self.main_panel:FindChild("GiveScorePanel/GiveScoreTitle"):GetComponent("Text")
    self.give_score_tip = self.main_panel:FindChild("GiveScorePanel/GiveScoreTip"):GetComponent("Text")
    self.star_list_obj = self.main_panel:FindChild("GiveScorePanel/StarList")
    self.cancel_comment_btn = self.main_panel:FindChild("GiveScorePanel/CancelCommentBtn")
    self:AddClick(self.cancel_comment_btn, function()
        SpecMgrs.ui_mgr:HideUI(self)
    end)
    self.send_comment_btn = self.main_panel:FindChild("GiveScorePanel/SendCommentBtn")
    self:AddClick(self.send_comment_btn, function()
        self:ClickSendCommentBtn()
    end)
    self.send_comment_panel = self.main_panel:FindChild("SendCommentPanel")
    self.send_comment_title = self.main_panel:FindChild("SendCommentPanel/Title"):GetComponent("Text")
    self.send_comment_tip = self.main_panel:FindChild("SendCommentPanel/CommentTip"):GetComponent("Text")
    self.close_btn = self.main_panel:FindChild("SendCommentPanel/CloseBtn")
    self:AddClick(self.close_btn, function()
        SpecMgrs.ui_mgr:HideUI(self)
    end)
    self.send_bad_comment_btn = self.main_panel:FindChild("SendCommentPanel/BadCommentBtn")
    self:AddClick(self.send_bad_comment_btn, function()
        self:ClickBadCommentBtn()
    end)
    self.re_comment_btn = self.main_panel:FindChild("SendCommentPanel/ReCommentBtn")
    self:AddClick(self.re_comment_btn, function()
        self:ShowSendCommentPanel()
    end)
    self.input_field = self.main_panel:FindChild("SendCommentPanel/InputField"):GetComponent("InputField")
    self.placeholder = self.main_panel:FindChild("SendCommentPanel/InputField/Placeholder"):GetComponent("Text")

    self.star_list = {}
    for i = 1, self.star_list_obj.childCount do
        local star = self.star_list_obj:GetChild(i - 1):FindChild("Image")
        table.insert(self.star_list, star)
        self:AddClick(self.star_list_obj:GetChild(i - 1), function()
            self:ClickStar(i)
        end)
    end
end

function CommentUI:InitUI()
    self:ClearRes()
    self.input_field.text = ""
    self.cur_star = nil
    self.tip_comment_panel:SetActive(true)
    self.give_score_panel:SetActive(false)
    self.send_comment_panel:SetActive(false)

    self:UpdateData()
    self:SetTextVal()
    self:UpdateUIInfo()
    self:AddHalfUnit(self.show_unit, self.unit_rect)
    for i = 1, #self.star_list do
        self.star_list[i]:SetActive(false)
    end
end

function CommentUI:ClickCommentBtn()
    if SpecMgrs.system_mgr:IsIOS() then
        SpecMgrs.sdk_mgr:ShowIosComment()
        SpecMgrs.ui_mgr:HideUI(self)
    else
        self.tip_comment_panel:SetActive(false)
        self.give_score_panel:SetActive(true)
    end
end

function CommentUI:ClickStar(index)
    for i = 1, index do
        self.star_list[i]:SetActive(true)
    end
    for i = index + 1, #self.star_list do
        self.star_list[i]:SetActive(false)
    end
    self.cur_star = index
end

function CommentUI:ClickSendCommentBtn()
    if not self.cur_star then
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.CLICK_STAR_TIP)
        return
    end
    if self.cur_star >= self.turn_google_play_star_limit then
        SpecMgrs.sdk_mgr:ShowGooglePlayComment()
         -- 五星评论后不再弹出评论ui
        --SpecMgrs.msg_mgr:SendCommentSetting({not_comment = true}, nil)
        SpecMgrs.ui_mgr:HideUI(self)
    else
        self.give_score_panel:SetActive(false)
        self.send_comment_panel:SetActive(true)
    end
end

function CommentUI:ClickNotCommentBtn()
    SpecMgrs.msg_mgr:SendCommentSetting({not_comment = true}, nil)
    SpecMgrs.ui_mgr:HideUI(self)
end

function CommentUI:ShowSendCommentPanel()
    self.give_score_panel:SetActive(true)
    self.send_comment_panel:SetActive(false)
end

function CommentUI:ClickBadCommentBtn()
    if self.input_field.text == "" then
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.COMMENT_IS_EMPTY_TIP)
        return
    end
    local data = {
        comment_id = self.comment_index,
        star_num = self.cur_star,
        content = self.input_field.text,
    }
    SpecMgrs.msg_mgr:SendSaveComment(data, function(resp)
        if resp.errcode == 0 then
            SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.SEND_SUCCESS_TEXT)
            return
        end
    end)
    SpecMgrs.ui_mgr:HideUI(self)
end

function CommentUI:UpdateData()
    self.show_unit = SpecMgrs.data_mgr:GetParamData("comment_show_unit").unit_id
    self.comment_str_limit = SpecMgrs.data_mgr:GetParamData("comment_str_limit").f_value
    self.turn_google_play_star_limit = SpecMgrs.data_mgr:GetParamData("turn_google_play_star_limit").f_value
end

function CommentUI:UpdateUIInfo()
    self.input_field.characterLimit = self.comment_str_limit
end

function CommentUI:SetTextVal()
    self.comment_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.GOTO_COMMENT
    self.not_comment_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.NOT_SHOW_COMMENT
    self.next_time_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.NEXT_TIME_COMMENT
    self.comment_tip_text.text = UIConst.Text.COMMENT_TIP
    self.give_score_title.text = UIConst.Text.GIVE_SCORE_TITLE
    self.give_score_tip.text = UIConst.Text.GIVE_SCORE_TIP

    self.cancel_comment_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.NOT_PUBLISH_COMMENT
    self.send_comment_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.PUBLISH_COMMENT

    self.send_comment_title.text = UIConst.Text.PUBLISH_COMMENT
    self.send_comment_tip.text = UIConst.Text.BAD_COMMENT_TIP

    self.re_comment_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.ANGIN_COMMENT
    self.send_bad_comment_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.SEND_TEXT
    self.input_field.gameObject:FindChild("Placeholder"):GetComponent("Text").text = UIConst.Text.COMMENT_PLACEHOLDER
end

function CommentUI:ClearRes()
    self:DelAllCreateUIObj()
    self:DestroyAllUnit()
end

function CommentUI:Hide()
    self:ClearRes()
    CommentUI.super.Hide(self)
end

return CommentUI
