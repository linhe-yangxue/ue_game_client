local UIBase = require("UI.UIBase")
local UIConst = require("UI.UIConst")
local ManagementCenterUI = class("UI.ManagementCenterUI",UIBase)
local UIFuncs = require("UI.UIFuncs")
local UnitConst = require("Unit.UnitConst")
local SoundConst = require("Sound.SoundConst")
ManagementCenterUI.need_sync_load = true

local kDiffLayoutCount = 3 --lover seat大于3个就是另外一种排版
local kLoverSeatEachLine = 4 -- lover seat每行放3个
local grade_add_attr = {
    "business", -- 商业
    "management", -- 技术
    "renown", -- 声望
    "fight", -- 战力
    "add_child_flair", -- 孩子加成资质
}

local lover_attr = {
    "etiquette", -- 礼仪
    "culture", -- 修养
    "charm", -- 魅力
    "planning", -- 心计
    "level", -- 亲密等级
    "attr_sum", -- 属性总和
}

function ManagementCenterUI:DoInit()
    ManagementCenterUI.super.DoInit(self)
    self.prefab_path = "UI/Common/ManagementCenterUI"
    self.star_limit = SpecMgrs.data_mgr:GetParamData("hero_star_lv_limit").f_value
    --数据
    self.dy_lover_data = ComMgrs.dy_data_mgr.lover_data
    self.grade_data_list = self.dy_lover_data:GetAllGradeData()
    self.max_grade = #self.grade_data_list
    self.lowest_grade = 1
    self.lover_data_list = self.dy_lover_data:GetAllLoverData()
    --存放go
    self.grade_item_temp_list = {}
    self.grade_item_list = {} -- 动态生成的一个等级的lover的面板
    self.grade_to_lover_seat_list = {} --{[等级ID]= ｛lover_item，lover_item｝}
    for i = 1, self.max_grade do
        self.grade_to_lover_seat_list[i] = {}
    end
    self.lover_item_parent_list = {} -- 每个等级产生的lover_item挂的父物体
    self.lover_count_text_list = {} -- max_count >3 and <6 才会存
    self.slp_lover_id_to_go = {} -- 选择妃子面板｛[lover_id] = lover_item｝
    self.slp_lover_id_to_unit = {}
    self.grade_to_prev_red_point = {} -- [1] = 1 上次红点位置
end

function ManagementCenterUI:OnGoLoadedOk(res_go)
    ManagementCenterUI.super.OnGoLoadedOk(self,res_go)
    self:InitRes()
    self:InitUI()
end

function ManagementCenterUI:InitRes()
    -- 初始化主面板
    local main_panel = self.main_panel
    -- Topbar
    local top_bar = main_panel:FindChild("Content/TopBar")
    UIFuncs.InitTopBar(self, top_bar, "ManagementCenterPanel")
    local grade_item_parent = main_panel:FindChild("Content/Scroll View/Viewport/ItemList")
    local grade_item_temp_list = self.grade_item_temp_list
    table.insert(grade_item_temp_list, grade_item_parent:FindChild("OneSeatItem"))
    table.insert(grade_item_temp_list, grade_item_parent:FindChild("TwoSeatItem"))
    table.insert(grade_item_temp_list, grade_item_parent:FindChild("ThreeSeatItem"))
    table.insert(grade_item_temp_list, grade_item_parent:FindChild("ThreeMoreSeatItem"))
    self.no_seat_item = grade_item_parent:FindChild("NoSeatItem")
    self.no_seat_item:SetActive(false)
    self.lowest_grade_lover_temp = self.no_seat_item:FindChild("Lover")
    UIFuncs.GetIconGo(self, self.lowest_grade_lover_temp, nil, UIConst.PrefabResPath.LoverIcon)
    self.lowest_grade_lover_temp:SetActive(false)
    self.lover_item_temp = grade_item_parent:FindChild("ThreeMoreSeatItem/Lover")
    self.lover_item_temp:SetActive(false)

    for _,v in ipairs(self.grade_item_temp_list) do
        v:SetActive(false)
    end

    for grade_id = self.max_grade, self.lowest_grade, -1 do -- 皇后显示在最上面
        local max_count = self.grade_data_list[grade_id].max_count
        local item_temp = self:_GetGradeItemTemp(max_count, grade_id)
        local item = self:GetUIObject(item_temp, grade_item_parent)
        self:_InitGradeItem(item, self.grade_data_list[grade_id])
        self.grade_item_list[grade_id] = item
    end
    -- SelectLoverPanle 以下简称slp
    self.select_lover_panel = main_panel:FindChild("ChildPanel/SelectLoverPanel")
    self.select_lover_panel:FindChild("Content/Top/Text"):GetComponent("Text").text = UIConst.Text.SELECT_LOVER
    self.select_lover_panel:FindChild("Content/Description"):GetComponent("Text").text = UIConst.Text.SELECT_LOVER_TO_GRANT
    self.select_lover_panel:FindChild("Content/Description/Text"):GetComponent("Text").text = UIConst.Text.GRANT_TEXT
    self.slp_grade_name_text = self.select_lover_panel:FindChild("Content/Description/Text/Text"):GetComponent("Text")
    self.slp_item_parent = self.select_lover_panel:FindChild("Content/Scroll View/Viewport/ItemList")
    self.slp_item_temp = self.slp_item_parent:FindChild("Item")
    self.slp_item_temp:FindChild("AttributePart/BtnList/PromoteBtn/Text"):GetComponent("Text").text = UIConst.Text.PROMOTE
    self.slp_item_temp:FindChild("AttributePart/BtnList/RewardBtn/Text"):GetComponent("Text").text = UIConst.Text.REWARD1
    self.slp_item_temp:SetActive(false)
    self:AddClick(self.select_lover_panel:FindChild("Content/Top/CloseBtn"), function ()
        self:HideSelectLoverPanel()
    end, SoundConst.SoundID.SID_CloseBtnClick)

    -- GradePreviewPanel 以下简称gpp
    self.grade_preview_panel = main_panel:FindChild("ChildPanel/GradePreviewPanel")
    self.grade_preview_panel:FindChild("PreviewPart/Content/LevelPreview/Title"):GetComponent("Text").text = UIConst.Text.PROMOTE_TITLE
    self.grade_preview_panel:FindChild("PreviewPart/Content/AttributePreview/Title"):GetComponent("Text").text = UIConst.Text.PROMOTE_ADDTION
    self.grade_preview_panel:FindChild("PreviewPart/Content/PromoteItemPreview/Title"):GetComponent("Text").text = UIConst.Text.PROMOTE_ITEM
    self.gpp_lover_parent = self.grade_preview_panel:FindChild("LoverPart")
    self.gpp_now_grade_image = self.grade_preview_panel:FindChild("PreviewPart/Content/LevelPreview/Content/NowIcon"):GetComponent("Image")
    self.gpp_now_grade_text = self.grade_preview_panel:FindChild("PreviewPart/Content/LevelPreview/Content/NowIcon/Text"):GetComponent("Text")
    self.gpp_next_grade_image = self.grade_preview_panel:FindChild("PreviewPart/Content/LevelPreview/Content/NextIcon"):GetComponent("Image")
    self.gpp_next_grade_text = self.grade_preview_panel:FindChild("PreviewPart/Content/LevelPreview/Content/NextIcon/Text"):GetComponent("Text")
    local attr_parent = self.grade_preview_panel:FindChild("PreviewPart/Content/AttributePreview/Content")
    self.gpp_attr_text_list = {}
    for _, v in ipairs(grade_add_attr) do
        local str
        if v == "add_child_flair" then
            str = UIConst.Text.ADD_CHILD_FLAIR1
        else
            local attr_data = SpecMgrs.data_mgr:GetAttributeData(v)
            str = string.format(UIConst.Text.GRADE_ADD_ATTR2, attr_data.name, v)
        end
        attr_parent:FindChild(v .. "/Text (1)"):GetComponent("Text").text = str
        self.gpp_attr_text_list[v] = attr_parent:FindChild(v .. "/Text"):GetComponent("Text")
    end

    self.gpp_promote_item = self.grade_preview_panel:FindChild("PreviewPart/Content/PromoteItemPreview/Content/ItemIcon")
    self.gpp_promote_item_text = self.grade_preview_panel:FindChild("PreviewPart/Content/PromoteItemPreview/Content/ItemIcon/ItemCount"):GetComponent("Text")
    self.gpp_promote_btn = self.grade_preview_panel:FindChild("PreviewPart/Content/PromoteItemPreview/PromoteBtn")
    self.gpp_promote_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.PROMOTE
    self:AddClick(self.grade_preview_panel:FindChild("CloseBg"),function ()
        self:HideGradePreviewPanel()
    end,SoundConst.SoundID.SID_CloseBtnClick)
    self:AddClick(self.grade_preview_panel:FindChild("CloseBtn"),function ()
        self:HideGradePreviewPanel()
    end,SoundConst.SoundID.SID_CloseBtnClick)

    -- ChangeGradePanle 以下简称cgp
    self.change_grade_panel = main_panel:FindChild("ChildPanel/ChangeGradePanel")
    self.change_grade_panel:FindChild("DescriptionPart/Content/LevelPreview/Title"):GetComponent("Text").text = UIConst.Text.CUR_GRADE
    self.change_grade_panel:FindChild("DescriptionPart/Content/LoverAttribute/Title"):GetComponent("Text").text = UIConst.Text.LOVER_DETAIL
    self.change_grade_panel:FindChild("DescriptionPart/Content/GradeChangePreview/Title"):GetComponent("Text").text = UIConst.Text.CHANGE_GRADE

    self.cgp_lover_parent = self.change_grade_panel:FindChild("LoverPart")
    self.cgp_now_grade_image = self.change_grade_panel:FindChild("DescriptionPart/Content/LevelPreview/Content/NowIcon"):GetComponent("Image")
    self.cgp_now_grade_text = self.change_grade_panel:FindChild("DescriptionPart/Content/LevelPreview/Content/NowIcon/Text"):GetComponent("Text")
    attr_parent = self.change_grade_panel:FindChild("DescriptionPart/Content/LoverAttribute/Content")
    self.cgp_attr_text_list = {}
    for _, v in ipairs(lover_attr) do
        local str
        if v == "level" then
            str = UIConst.Text.GRADE_LOVER_LEVEL2
        elseif v == "attr_sum" then
            str = UIConst.Text.GRADE_ATTR_SUM2
        else
            local attr_data = SpecMgrs.data_mgr:GetAttributeData(v)
            str = string.format(UIConst.Text.GRADE_ADD_ATTR2, attr_data.name, v)
        end
        attr_parent:FindChild(v .. "/Text (1)"):GetComponent("Text").text = str
        self.cgp_attr_text_list[v] = attr_parent:FindChild(v .. "/Text"):GetComponent("Text")
    end
    self.cgp_already_loweset_go = self.change_grade_panel:FindChild("DescriptionPart/Content/GradeChangePreview/AlreadyLowest")
    self.cgp_already_loweset_go:GetComponent("Text").text = UIConst.Text.ALREADY_LOWEST_GRADE
    self:AddClick(self.change_grade_panel:FindChild("CloseBg"),function ()
        self:HideChangeGradePanel()
    end, SoundConst.SoundID.SID_CloseBtnClick)
    self:AddClick(self.change_grade_panel:FindChild("CloseBtn"),function ()
        self:HideChangeGradePanel()
    end, SoundConst.SoundID.SID_CloseBtnClick)
    self.cgp_grade_down_btn = self.change_grade_panel:FindChild("DescriptionPart/Content/GradeChangePreview/GrodeDownBtn")
    self.cgp_grade_down_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.DOWN_GRADE
    self:AddClick(self.cgp_grade_down_btn, function ()
        self:_GradeDownBtnOnClick()
    end)
    self.cgp_down_grade_content = self.change_grade_panel:FindChild("DescriptionPart/Content/GradeChangePreview/Content")
    self.cgp_now_grade_image2 = self.cgp_down_grade_content:FindChild("NowIcon"):GetComponent("Image")
    self.cgp_now_grade_text2 = self.cgp_down_grade_content:FindChild("NowIcon/Text"):GetComponent("Text")

    self.cgp_next_grade_image = self.cgp_down_grade_content:FindChild("NextIcon"):GetComponent("Image")
    self.cgp_next_grade_text = self.cgp_down_grade_content:FindChild("NextIcon/Text"):GetComponent("Text")
    self.change_grade_panel:FindChild("DescriptionPart/Content/AwardBtn/Text"):GetComponent("Text").text = UIConst.Text.REWARD1
    self:AddClick(self.change_grade_panel:FindChild("DescriptionPart/Content/AwardBtn"),function ()
        if not self.show_sgp_lover_id then return end
        local param_tb = {
            lover_id = self.show_sgp_lover_id,
            is_show_award = true,
        }
        self:HideChangeGradePanel()
        SpecMgrs.ui_mgr:ShowUI("LoverDetailUI", param_tb)
    end)
    -- GradeUpPanel 以下简称gup
    self.grade_up_panel = main_panel:FindChild("ChildPanel/GradeUpPanel")
    self.gup_lover_parent = self.grade_up_panel:FindChild("LoverPart")
    attr_parent = self.grade_up_panel:FindChild("Content/AttributeChangePart/PrevAttribute")
    self.gup_prev_grade_name_text = attr_parent:FindChild("Titel/Text"):GetComponent("Text")
    self.gup_prev_attr_text_list = {}
    for _,v in ipairs(grade_add_attr) do
        self.gup_prev_attr_text_list[v] = attr_parent:FindChild(v):GetComponent("Text")
    end

    attr_parent = self.grade_up_panel:FindChild("Content/AttributeChangePart/NowAttribute")
    self.gup_now_grade_name_text = attr_parent:FindChild("Titel/Text"):GetComponent("Text")
    self.gup_now_attr_text_list = {}
    for _,v in ipairs(grade_add_attr) do
        self.gup_now_attr_text_list[v] = attr_parent:FindChild(v):GetComponent("Text")
    end
    self:AddClick(self.grade_up_panel:FindChild("CloseBg"),function ()
        self:HideGradeUpPanel()
    end)

    --GradeDownPanel 以下简称gdp
    self.grade_down_panel = main_panel:FindChild("ChildPanel/GradeDownPanel")
    self.gdp_lover_parent = self.grade_down_panel:FindChild("LoverPart")
    attr_parent = self.grade_down_panel:FindChild("Content/AttributeChangePart/PrevAttribute")
    self.gdp_prev_grade_name_text = attr_parent:FindChild("Titel/Text"):GetComponent("Text")
    self.gdp_prev_attr_text_list = {}
    for _,v in ipairs(grade_add_attr) do
        self.gdp_prev_attr_text_list[v] = attr_parent:FindChild(v):GetComponent("Text")
    end
    attr_parent = self.grade_down_panel:FindChild("Content/AttributeChangePart/NowAttribute")
    self.gdp_now_grade_name_text = attr_parent:FindChild("Titel/Text"):GetComponent("Text")
    self.gdp_now_attr_text_list = {}
    for _,v in ipairs(grade_add_attr) do
        self.gdp_now_attr_text_list[v] = attr_parent:FindChild(v):GetComponent("Text")
    end
    self:AddClick(self.grade_down_panel:FindChild("CloseBg"),function ()
        self:HideGradeDownPanel()
    end)
end

function ManagementCenterUI:_GetGradeItemTemp(max_count, grade_id)
    if grade_id == self.lowest_grade then
        return self.no_seat_item
    else
        max_count = max_count < 0 and #self.grade_item_temp_list or max_count --无限就取最后一个模版
        local index = math.clamp(max_count, 1, #self.grade_item_temp_list)
        return self.grade_item_temp_list[index]
    end
end

function ManagementCenterUI:_InitGradeItem(item, data)
    local add_child_flair = item:FindChild("Content/AddChildFlair")
    if add_child_flair then
        add_child_flair:GetComponent("Text").text = string.format(UIConst.Text.ADD_CHILD_FLAIR, data.add_child_flair or 0)
    end
    local desccription = item:FindChild("Content/Description")
    if desccription then
        local desc_str = string.format(UIConst.Text.GRADE_DESCRIPTION, data.name)
        desccription:GetComponent("Text").text = desc_str
    end
    local add_attr_parent = item:FindChild("Content/AddAttr")
    if add_attr_parent then
        for i, attr_id in ipairs(data.add_attr_list) do
            local name = SpecMgrs.data_mgr:GetAttributeData(attr_id).name
            local count = data.add_attr_num_list[i]
            local str = string.format(UIConst.Text.GRADE_ADD_ATTR, name, count)
            add_attr_parent:FindChild(attr_id):GetComponent("Text").text = str
        end
    end
    if data.max_count > kDiffLayoutCount or data.max_count < 0 then
        self.lover_item_parent_list[data.id] = item
    end
    -- 皇后额外征收加成
    local add_levy_list = data.add_levy_list
    if add_levy_list then
        for i, v in ipairs(add_levy_list) do
            local name = SpecMgrs.data_mgr:GetLevyData(v).name
            local precent = data.add_levy_percent_list[i]
            local add_levy_str = string.format(UIConst.Text.GRADE_ADD_LEVY, name, precent)

            item:FindChild("Content/LoverPart/AddLevyAttr/" .. i):GetComponent("Text").text = add_levy_str
        end
    end
    local max_count = data.max_count

    -- 直接取预制体里提前放好的lover_item，不再动态生成
    if max_count > 0 and max_count <= kDiffLayoutCount then
        self.grade_to_lover_seat_list[data.id] = {}
        local tb = self.grade_to_lover_seat_list[data.id]
        for seat_index = 1, max_count do
            local go = item:FindChild("Content/LoverPart/Lover" .. seat_index)
            self:AddClick(go, function ()
                self:_LoverItemOnClick(data.id, seat_index)
            end)
            table.insert(tb, go)
        end
    end
    self:_InitItemTitle(item, data)
end

function ManagementCenterUI:_InitItemTitle(item, data)
    local name_text
    local image
    if data.max_count > 0 and data.max_count <= kDiffLayoutCount then
        name_text = item:FindChild("Grade/Image/Text"):GetComponent("Text")
        image = item:FindChild("Grade"):GetComponent("Image")
    elseif data.id == self.lowest_grade then
        name_text = item:FindChild("Image/Grade/Text"):GetComponent("Text")
    else
        image = item:FindChild("Image/Grade/Icon"):GetComponent("Image")
        name_text = item:FindChild("Image/Grade/Text"):GetComponent("Text")
    end
    if image then
        self:AssignSpriteByIconID(data.icon, image)
    end
    name_text.text = data.name

    --todo 后续
    --local text_comp = item:FindChild("Content/AddChildFlair/Left/Count"):GetComponent("Text")
    --if data.max_count < 0 then
    --    text_comp.text = string.format(UIConst.Text.SPRIT, 0, data.max_count) -- 初始化就赋值一次后面没有lover就不改变了
    --    self.lover_count_text_list[data.id] = text_comp
    --else
    --    text_comp.text = UIConst.Text.INFINITE
    --end
end

function ManagementCenterUI:InitUI()
    self.dy_lover_data:RegisterUpdateRedPointEvent("ManagementCenterUI", function (_, grade,is_red_point_on)
        self:_UpdateRedPoint(grade, is_red_point_on)
    end)
    self.dy_lover_data:RegisterUpdateLoverGradeEvent("ManagementCenterUI", function (_, lover_data)
        self:_UpdateOneGradeLover(lover_data.old_grade)
        self:_UpdateOneGradeLover(lover_data.grade)
    end)
    self.dy_lover_data:RegisterUpdateLoverInfoEvent("ManagementCenterUI", function (_, lover_id)
        if self.is_slp_show  then
            local lover_item = self.slp_lover_id_to_go[lover_id]
            if lover_item then
                self:UpdateSelectLoverItem(lover_item, lover_id, self.slp_grade_id)
            end
        end
    end)
    self:_UpdateMainPanelItem()
    for grade_id = self.lowest_grade + 1, self.max_grade do
        local is_red_point_on = self.dy_lover_data:CheckLoverGradeUpByGradeId(grade_id)
        self:_UpdateRedPoint(grade_id,is_red_point_on)
    end
end

function ManagementCenterUI:Show()
    if self.is_res_ok then
        self:InitUI()
    end
    ManagementCenterUI.super.Show(self)
end

function ManagementCenterUI:Hide()
    self.dy_lover_data:UnregisterUpdateRedPointEvent("ManagementCenterUI")
    self.dy_lover_data:UnregisterUpdateLoverGradeEvent("ManagementCenterUI")
    self.dy_lover_data:UnregisterUpdateLoverAttrEvent("ManagementCenterUI")
    ManagementCenterUI.super.Hide(self)
end

function ManagementCenterUI:_UpdateRedPoint(grade, is_red_point_on)
    if grade == self.lowest_grade then return end -- 未册封不需要红点
    local change_seat = self.dy_lover_data:GetRedPointSeat(grade)
    for index, go in ipairs(self.grade_to_lover_seat_list[grade]) do
        local lover_info = self.dy_lover_data:GetLoverInfoBySeat(grade, index)
        local is_lover_on = lover_info and true or false
        self:SwitchLoverRedPoint(go, index == change_seat and is_red_point_on or false, is_lover_on)
    end
end

function ManagementCenterUI:SwitchLoverRedPoint(lover_go, is_red_point_on, is_lover_on)
    if not lover_go then return end
    local red_point_go = lover_go:FindChild("RedPoint")
    local effect_anim = red_point_go:GetComponent("EffectColorAnim")
    red_point_go:SetActive(not is_lover_on)
    if is_lover_on then return end
    if is_red_point_on then
        effect_anim.enabled = true
    else
        effect_anim:SetTime(0)
        effect_anim.enabled = false
    end
end

function ManagementCenterUI:_UpdateMainPanelItem()
    for grade_id,_ in ipairs(self.grade_data_list) do
        self:_UpdateOneGradeLover(grade_id)
    end
end

-- 更新一个阶级的所有位置上是否有lover以及lover的位置
function ManagementCenterUI:_UpdateOneGradeLover(grade_id)
    local lover_list = self.dy_lover_data:GetLoverListByGrade(grade_id)
    local is_need_clean, final_seat_count = self:_CheckNeedChangeLoverItem(grade_id, lover_list)
    if is_need_clean then
        if self.grade_to_lover_seat_list[grade_id] then
            for _, lover_item in ipairs(self.grade_to_lover_seat_list[grade_id]) do
                self:DelUIObject(lover_item)
            end
        end
        self.grade_to_lover_seat_list[grade_id] = {}
        for i = 1, final_seat_count  do
            local lover_item_temp = self:GetLoverItemTemp(grade_id)
            local go = self:GetUIObject(lover_item_temp, self.lover_item_parent_list[grade_id])
            table.insert(self.grade_to_lover_seat_list[grade_id], go)
        end
    end

    local seat_go_list = self.grade_to_lover_seat_list[grade_id]
    for seat_index, lover_go in ipairs(seat_go_list) do
        local lover_data = self.dy_lover_data:GetLoverInfoBySeat(grade_id, seat_index)
        self:_UpdateLoverItem(lover_go, lover_data, grade_id)
        self:AddClick(lover_go, function ()
            self:_LoverItemOnClick(grade_id, seat_index)
        end)
    end
    --self:_UpdateGradeLoverCount() -- 可能要改回来
end

function ManagementCenterUI:GetLoverItemTemp(grade_id)
    if grade_id == self.lowest_grade then
        return self.lowest_grade_lover_temp
    else
        return self.lover_item_temp
    end
end

function ManagementCenterUI:_LoverItemOnClick(grade_id, seat_index)
    local lover_data = self.dy_lover_data:GetLoverInfoBySeat(grade_id, seat_index)
    if lover_data then
        self:ShowChangeGradePanel(lover_data.lover_id)
    else
        self:ShowSelectLoverPanel(grade_id)
    end
end

function ManagementCenterUI:_UpdateLoverItem(item, serv_lover_data, grade_id)
    local is_show_lover = serv_lover_data and true or false
    if grade_id > self.max_grade - kDiffLayoutCount then
        item:FindChild("LoverOn"):SetActive(is_show_lover)
    end
    if grade_id == self.lowest_grade then
        local param_tb = {go = item:FindChild("Item"), lover_id = serv_lover_data.lover_id}
        UIFuncs.InitLoverGo(param_tb)
    else
        local icon = item:FindChild("Icon")
        icon:SetActive(is_show_lover)
        if is_show_lover then
            local lover_data = self.lover_data_list[serv_lover_data.lover_id]
            local unit_data = SpecMgrs.data_mgr:GetUnitData(lover_data.unit_id)
            self:AssignSpriteByIconID(unit_data.icon, icon:GetComponent("Image"))
        end
        local ver_str
        if serv_lover_data then
            local lover_data = self.lover_data_list[serv_lover_data.lover_id]
            ver_str = lover_data.name
        else
            ver_str = UIConst.Text.NOLOVER
        end
        item:FindChild("Name/Text"):GetComponent("Text").text = ver_str
    end
end

function ManagementCenterUI:_CheckNeedChangeLoverItem(grade_id, lover_list)
    local max_count = self.grade_data_list[grade_id].max_count
    local lover_count = #lover_list
    if max_count > 0 then -- 负数代表无限个
        if max_count <= kDiffLayoutCount then
            return false
        end
        return true, max_count
    else
        if grade_id == self.lowest_grade then
            return true, lover_count
        else
            return true, self:_GetFinalSeatCount(lover_count)
        end
    end
end

function ManagementCenterUI:_GetFinalSeatCount(lover_count)
    if lover_count < kLoverSeatEachLine then
        return kLoverSeatEachLine
    elseif lover_count % kLoverSeatEachLine == 0 then
        return lover_count + 1
    else
        return math.ceil(lover_count / kLoverSeatEachLine) * kLoverSeatEachLine
    end
end

function ManagementCenterUI:_UpdateGradeLoverCount(grade_id)
    local text_comp = self.lover_count_text_list[grade_id]
    if text_comp then
        local max_count = self.grade_data_list[grade_id].max_count
        local lover_count = self.dy_lover_data:GetLoverCountByGrade(grade_id)
        text_comp.text = string.format(UIConst.Text.SPRIT, lover_count, max_count)
    end
end

-- SelectLoverPanel begin
function ManagementCenterUI:ShowSelectLoverPanel(grade_id)
    if not grade_id then return end
    local serv_lover_id_list = self.dy_lover_data:GetSelectLoverDataList(grade_id)
    if not next(serv_lover_id_list) then
        SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.NO_LOVER_CAN_GRANT)
        return
    end
    self:ClearUnitDict("slp_lover_id_to_unit")
    self:ClearGoDict("slp_lover_id_to_go")
    self.slp_grade_name_text.text = self.grade_data_list[grade_id].name
    for _, lover_id in ipairs(serv_lover_id_list) do
        local item = self:GetUIObject(self.slp_item_temp, self.slp_item_parent)
        self:UpdateSelectLoverItem(item, lover_id, grade_id)
        local lover_data = self.lover_data_list[lover_id]
        local lover_parent = item:FindChild("LoverPart/UnitParent")
        local lover_unit = self:AddCardUnit(lover_data.unit_id, lover_parent)
        lover_unit:StopAllAnimationToCurPos()
        item:FindChild("LoverPart/NameText"):GetComponent("Text").text = lover_data.name
        self.slp_lover_id_to_unit[lover_id] = lover_unit
        self.slp_lover_id_to_go[lover_id] = item
        self:AddClick(item:FindChild("AttributePart/BtnList/PromoteBtn"),function ()
            self:_SelectLoverPanelPromoteClick(lover_id, grade_id)
        end)
        self:AddClick(item:FindChild("AttributePart/BtnList/RewardBtn"),function ()
            local param_tb = {
                lover_id = lover_id,
                is_show_award = true,
            }
            SpecMgrs.ui_mgr:ShowUI("LoverDetailUI", param_tb)
        end)
    end
    self.slp_grade_id = grade_id
    self.is_slp_show = true
    self.select_lover_panel:SetActive(true)
end

function ManagementCenterUI:UpdateSelectLoverItem(item, lover_id, grade_id)
    local serv_lover_data = self.dy_lover_data:GetServLoverDataById(lover_id)
    local lover_data = self.lover_data_list[lover_id]
    local lover_unit_data = SpecMgrs.data_mgr:GetUnitData(lover_data.unit_id)
    local quality_data = SpecMgrs.data_mgr:GetQualityData(lover_data.quality)
    local lover_card = item:FindChild("LoverPart")
    self:AssignSpriteByIconID(quality_data.lover_card_bg, lover_card:FindChild("LoverImage"):GetComponent("Image"))
    lover_card:FindChild("Intimacy/IntimacyValText"):GetComponent("Text").text = serv_lover_data.level
    lover_card:FindChild("NameText"):GetComponent("Text").text = lover_data.name
    lover_card:FindChild("PowerText"):GetComponent("Text").text = UIConst.Text.LOVER_POWER_TEXT
    lover_card:FindChild("PowerValText"):GetComponent("Text").text = serv_lover_data.power_value
    local lover_grade_img = lover_card:FindChild("Grade"):GetComponent("Image")
    self:AssignSpriteByIconID(quality_data.grade, lover_grade_img)
    local star_list = lover_card:FindChild("StarList")
    for i = 1, self.star_limit do
        star_list:FindChild("Star" .. i .. "/Active"):SetActive(i <= serv_lover_data.star_lv)
    end

    local level_str = self:GetLoverAttrContrastStr(lover_id, grade_id, "level", true)
    item:FindChild("AttributePart/level"):GetComponent("Text").text = string.format(UIConst.Text.GRADE_LOVER_LEVEL, level_str)
    local attr_sum_str = self:GetLoverAttrContrastStr(lover_id, grade_id, "attr_sum", true)
    item:FindChild("AttributePart/attr_sum"):GetComponent("Text").text = string.format(UIConst.Text.GRADE_ATTR_SUM, attr_sum_str)
    local four_attr_parent = item:FindChild("AttributePart/four_attr")
    for i = 1, 4 do -- 情人4项基本属性
        local attr_name = lover_attr[i]
        local num_str = UIFuncs.AddCountUnit(serv_lover_data.attr_dict[attr_name])
        local str = string.format(UIConst.Text.ADD, SpecMgrs.data_mgr:GetAttributeData(attr_name).name, num_str)
        four_attr_parent:FindChild(attr_name .. "/Image/Text"):GetComponent("Text").text = str
    end
end

-- 按钮点击回调函数
function ManagementCenterUI:_SelectLoverPanelPromoteClick(lover_id, grade_id)
    local is_can_promote, not_reason = self:CheckLoverCanPromote(lover_id, grade_id)
    if is_can_promote then
        self:ShowGradePreviewPanel(lover_id, grade_id)
    else
        SpecMgrs.ui_mgr:ShowTipMsg(not_reason)
    end
end

function ManagementCenterUI:CheckLoverCanPromote(lover_id, grade_id)
    local serv_lover_data = self.dy_lover_data:GetServLoverDataById(lover_id)
    local attr_sum_limit = self.grade_data_list[grade_id].attr_sum_limit
    local level_limit = self.grade_data_list[grade_id].level_limit
    if not serv_lover_data.level or serv_lover_data.level < level_limit then
        return false, UIConst.Text.LEVEL_NOT_ENOUGH
    end
    if not serv_lover_data.attr_sum or serv_lover_data.attr_sum < attr_sum_limit then
        return false, UIConst.Text.ATTR_SUM_NOT_ENOUGH
    end
    return true
end

function ManagementCenterUI:HideSelectLoverPanel()
    self:ClearUnitDict("slp_lover_id_to_unit")
    self:ClearGoDict("slp_lover_id_to_go")
    self.slp_grade_id = nil
    self.is_slp_show = false
    self.select_lover_panel:SetActive(false)
end

-- SelectLoverPanel end

function ManagementCenterUI:ShowGradePreviewPanel(lover_id, next_grade_id)
    if not lover_id or not next_grade_id then return end
    local lover_data = self.lover_data_list[lover_id]
    local next_grade_data = self.grade_data_list[next_grade_id]
    local lover_grade_id = self.dy_lover_data:GetServLoverDataById(lover_id).grade
    local cur_grage_data = self.grade_data_list[lover_grade_id]
    self.gpp_lover_model = ComMgrs.unit_mgr:CreateUnitAutoGuid({unit_id = lover_data.unit_id, parent = self.gpp_lover_parent})
    self.gpp_lover_model:SetPositionByRectName({parent = self.gpp_lover_parent, name = UnitConst.UnitRect.Full})
    self.gpp_now_grade_text.text = cur_grage_data.name
    self:AssignSpriteByIconID(cur_grage_data.icon, self.gpp_now_grade_image)
    self.gpp_next_grade_text.text = next_grade_data.name
    self:AssignSpriteByIconID(next_grade_data.icon, self.gpp_next_grade_image)
    for i, attr_name in ipairs(next_grade_data.add_attr_list) do
        local attr_data = SpecMgrs.data_mgr:GetAttributeData(attr_name)
        self.gpp_attr_text_list[attr_name].text = UIFuncs.ChangeStrColor(next_grade_data.add_attr_num_list[i], "Green1")
    end
    self.gpp_attr_text_list["add_child_flair"].text = UIFuncs.ChangeStrColor(next_grade_data.add_child_flair, "Green1")
    local promote_item_id = next_grade_data.promote_item_id
    local item_data = SpecMgrs.data_mgr:GetItemData(promote_item_id)
    local param_tb = {go = self.gpp_promote_item, item_data = item_data, ui = self}
    UIFuncs.InitItemGo(param_tb)
    local item_count = ComMgrs.dy_data_mgr:ExGetItemCount(promote_item_id)
    local str = string.format(UIConst.Text.SPRIT, item_count, next_grade_data.promote_item_count)
    local color = item_count >= next_grade_data.promote_item_count and "Green1" or "Red1"
    self.gpp_promote_item_text.text = UIFuncs.ChangeStrColor(str, color)
    self:AddClick(self.gpp_promote_btn, function ()
        if not self.dy_lover_data:CheckPromoteItemEnough(next_grade_id) then
            SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.GRADE_ITEM_NOT_ENOUGH)
            return
        end
        -- 不能跳级提升
        if self.dy_lover_data:GetLoverInfo(lover_id).grade + 1 < next_grade_id then
            SpecMgrs.ui_mgr:ShowTipMsg(string.format(UIConst.Text.CAN_NOT_CHANGE_GRADE, self.grade_data_list[next_grade_id - 1].name))
            return
        end
        SpecMgrs.msg_mgr:SendChangeLoverGrade({lover_id = lover_id, grade = next_grade_id}, function (resp)
            if resp.errcode == 0 then
                self:ShowGradeUpPanel(lover_id, lover_grade_id, next_grade_id, self.gpp_lover_model)
                self.gpp_lover_model = nil
                self:HideSelectLoverPanel()
                self:HideGradePreviewPanel()
            end
        end)
    end)
    self.grade_preview_panel:SetActive(true)
end

function ManagementCenterUI:HideGradePreviewPanel()
    self:RemoveClick(self.gpp_promote_btn)
    if self.gpp_lover_model then
        ComMgrs.unit_mgr:DestroyUnit(self.gpp_lover_model)
    end
    self.grade_preview_panel:SetActive(false)
end

function ManagementCenterUI:ShowChangeGradePanel(lover_id)
    if not lover_id then return end
    self.show_sgp_lover_id = lover_id
    local lover_data = self.lover_data_list[lover_id]
    local serv_lover_data = self.dy_lover_data:GetServLoverDataById(lover_id)
    local lover_grade_id = serv_lover_data.grade
    local cur_grage_data = self.grade_data_list[lover_grade_id]
    self.cgp_lover_model = ComMgrs.unit_mgr:CreateUnitAutoGuid({unit_id = lover_data.unit_id, parent = self.cgp_lover_parent })-- todo 画像
    self.cgp_lover_model:SetPositionByRectName({parent = self.cgp_lover_parent, name = UnitConst.UnitRect.Full})
    self:AssignSpriteByIconID(cur_grage_data.icon, self.cgp_now_grade_image)
    self.cgp_now_grade_text.text = cur_grage_data.name
    local level_str = self:GetLoverAttrContrastStr(lover_id, lover_grade_id + 1, "level", true)
    self.cgp_attr_text_list["level"].text = level_str
    local att_sum_str = self:GetLoverAttrContrastStr(lover_id, lover_grade_id + 1, "attr_sum", true)
    self.cgp_attr_text_list["attr_sum"].text = att_sum_str
    for attr_name, v in pairs(serv_lover_data.attr_dict) do
        --应该是给情人加时装属性时候加进去了，然后服务器都传过来了，这个样先做个处理吧
        if attr_name ~= "max_hp" and attr_name ~= "att" and attr_name ~= "def" then
            local attr_data = SpecMgrs.data_mgr:GetAttributeData(attr_name)
            self.cgp_attr_text_list[attr_name].text = UIFuncs.ChangeStrColor(v, "Green1")
        end
    end
    local target_grade_id = self.dy_lover_data:FindGradeDownTarget(serv_lover_data.grade)
    local is_not_lowest_grade = target_grade_id and true or false
    self.cgp_already_loweset_go:SetActive(not is_not_lowest_grade)
    self.cgp_down_grade_content:SetActive(is_not_lowest_grade)
    self.cgp_grade_down_btn:SetActive(is_not_lowest_grade)
    if is_not_lowest_grade then
        local targe_grade_data = self.grade_data_list[target_grade_id]
        self:AssignSpriteByIconID(cur_grage_data.icon,self.cgp_now_grade_image2)
        self.cgp_now_grade_text2.text = cur_grage_data.name
        self:AssignSpriteByIconID(targe_grade_data.icon, self.cgp_next_grade_image)
        self.cgp_next_grade_text.text = targe_grade_data.name
    end
    self.change_grade_panel:SetActive(true)
end

function ManagementCenterUI:GetLoverAttrContrastStr(lover_id, grade_id, attr_name, is_on_dark_bg)
    local lover_data = self.dy_lover_data:GetServLoverDataById(lover_id)
    local cur_attr = lover_data[attr_name]
    local top_lover_grade = self.dy_lover_data:GetTopLoverGrade()
    local grade_data = self.grade_data_list[grade_id]
    local attr_limit = grade_data and grade_data[attr_name .. "_limit"] or nil
    local is_show_limit = grade_id <= top_lover_grade + 1
    local is_top_grade = grade_id == self.max_grade
    local right_str
    if is_show_limit and attr_limit then
        right_str = UIFuncs.AddCountUnit(attr_limit)
    elseif not is_show_limit then
        right_str = UIConst.Text.SECRET
    else
        right_str = ""
    end
    local color
    if is_on_dark_bg then
        if is_show_limit and attr_limit then
            color = is_show_limit and cur_attr >= attr_limit and "Green1" or "Red1"
        else
            color = "Green1"
        end
    else
        if is_show_limit and attr_limit then
            color = is_show_limit and cur_attr >= attr_limit and "Green" or "Red"
        else
            color = "Green"
        end
    end
    local cur_attr_str = UIFuncs.AddCountUnit(cur_attr)
    local level_str = attr_limit and string.format(UIConst.Text.SPRIT, cur_attr_str, right_str) or cur_attr
    return UIFuncs.ChangeStrColor(level_str, color)
end

function ManagementCenterUI:_GradeDownBtnOnClick(serv_lover_data)
    if not self.show_sgp_lover_id then return end
    local serv_lover_data = self.dy_lover_data:GetServLoverDataById(self.show_sgp_lover_id)
    local now_grade_id = serv_lover_data.grade
    local target_grade_id = self.dy_lover_data:FindGradeDownTarget(serv_lover_data.grade)
    if target_grade_id then
        local targe_grade_name = self.grade_data_list[target_grade_id].name
        local lover_id = serv_lover_data.lover_id
        local lover_name = self.lover_data_list[lover_id].name
        local content = string.format(UIConst.Text.GRADE_DOWN_TIP, lover_name, targe_grade_name)
        local confirm_cb = function ()
            SpecMgrs.msg_mgr:SendChangeLoverGrade({lover_id = lover_id, grade = target_grade_id}, function (resp)
                if resp.errcode == 0 then
                    self:ShowGradeDownPanel(lover_id, now_grade_id, target_grade_id, self.cgp_lover_model)
                    self.cgp_lover_model = nil
                    self:HideChangeGradePanel()
                end
            end)
        end
        SpecMgrs.ui_mgr:ShowMsgSelectBox({content = content, confirm_cb = confirm_cb})
    end
end

function ManagementCenterUI:HideChangeGradePanel()
    if self.cgp_lover_model then
        ComMgrs.unit_mgr:DestroyUnit(self.cgp_lover_model)
    end
    self.show_sgp_lover_id = nil
    self.change_grade_panel:SetActive(false)
end

function ManagementCenterUI:ShowGradeUpPanel(lover_id, pre_grade_id, now_grade_id, lover_model)
    if not lover_id or not pre_grade_id or not now_grade_id then return end
    local lover_data = self.lover_data_list[lover_id]
    local prev_grade_data = self.grade_data_list[pre_grade_id]
    local now_grade_data = self.grade_data_list[now_grade_id]
    if lover_model then
        self.gup_lover_model = lover_model
        lover_model:SetParent(self.gup_lover_parent)
    else
        self.gup_lover_model = ComMgrs.unit_mgr:CreateUnitAutoGuid({unit_id = lover_data.unit_id, parent = self.gup_lover_parent})
    end
    self.gup_lover_model:SetPositionByRectName({parent = self.gup_lover_parent, name = UnitConst.UnitRect.Full})
    self.gup_prev_grade_name_text.text = prev_grade_data.name
    for i, v in ipairs(prev_grade_data.add_attr_list) do
        local attr_data = SpecMgrs.data_mgr:GetAttributeData(v)
        self.gup_prev_attr_text_list[v].text = string.format(UIConst.Text.GRADE_ADD_ATTR1, attr_data.name, prev_grade_data.add_attr_num_list[i])
    end
    self.gup_prev_attr_text_list["add_child_flair"].text = string.format(UIConst.Text.ADD_CHILD_FLAIR, prev_grade_data.add_child_flair)

    self.gup_now_grade_name_text.text = now_grade_data.name
    for i,v in ipairs(now_grade_data.add_attr_list) do
        local attr_data = SpecMgrs.data_mgr:GetAttributeData(v)
        self.gup_now_attr_text_list[v].text = string.format(UIConst.Text.GRADE_ADD_ATTR1, attr_data.name, now_grade_data.add_attr_num_list[i])
    end
    self.gup_now_attr_text_list["add_child_flair"].text = string.format(UIConst.Text.ADD_CHILD_FLAIR, now_grade_data.add_child_flair)

    self.grade_up_panel:SetActive(true)
end

function ManagementCenterUI:HideGradeUpPanel()
    if self.gup_lover_model then
        ComMgrs.unit_mgr:DestroyUnit(self.gup_lover_model)
    end
    self.grade_up_panel:SetActive(false)
end

function ManagementCenterUI:ShowGradeDownPanel(lover_id, pre_grade_id, now_grade_id, lover_model)
    if not lover_id or not pre_grade_id or not now_grade_id then return end
    local lover_data = self.lover_data_list[lover_id]
    local prev_grade_data = self.grade_data_list[pre_grade_id]

    local now_grade_data = self.grade_data_list[now_grade_id]
    if lover_model then
        self.gdp_lover_model = lover_model
        lover_model:SetParent(self.gdp_lover_parent)
    else
        self.gdp_lover_model = ComMgrs.unit_mgr:CreateUnitAutoGuid({unit_id = lover_data.unit_id, parent = self.gdp_lover_parent})
    end
    self.gdp_lover_model:SetPositionByRectName({parent = self.gdp_lover_parent, name = UnitConst.UnitRect.Full})
    self.gdp_prev_grade_name_text.text = prev_grade_data.name
    for i, v in ipairs(prev_grade_data.add_attr_list) do
        local attr_data = SpecMgrs.data_mgr:GetAttributeData(v)
        self.gdp_prev_attr_text_list[v].text = string.format(UIConst.Text.GRADE_ADD_ATTR1, attr_data.name, prev_grade_data.add_attr_num_list[i])
    end
    self.gdp_prev_attr_text_list["add_child_flair"].text = string.format(UIConst.Text.ADD_CHILD_FLAIR, prev_grade_data.add_child_flair)

    self.gdp_now_grade_name_text.text = now_grade_data.name
    for i, v in ipairs(now_grade_data.add_attr_list) do
        local attr_data = SpecMgrs.data_mgr:GetAttributeData(v)
        self.gdp_now_attr_text_list[v].text = string.format(UIConst.Text.GRADE_ADD_ATTR1, attr_data.name, now_grade_data.add_attr_num_list[i])
    end
    self.gdp_now_attr_text_list["add_child_flair"].text = string.format(UIConst.Text.ADD_CHILD_FLAIR, now_grade_data.add_child_flair)
    self.grade_down_panel:SetActive(true)
end

function ManagementCenterUI:HideGradeDownPanel()
    if self.gdp_lover_model then
        ComMgrs.unit_mgr:DestroyUnit(self.gdp_lover_model)
    end
    self.grade_down_panel:SetActive(false)
end

return ManagementCenterUI