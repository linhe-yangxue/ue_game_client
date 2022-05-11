local UIFuncs = DECLARE_MODULE("UI.UIFuncs")
local UIConst = require("UI.UIConst")
local CSConst = require("CSCommon.CSConst")
local ItemUtil = require("BaseUtilities.ItemUtil")
local UIListSelector = require("UI.UIListSelector")
local CSFunction = require("CSCommon.CSFunction")
local kThousand = 1000
local kMillion = 1000000
local kBillion = 1000000000

function UIFuncs.AssignSpriteByItemID(item_id, cmp, load_active, field_name, cb, is_sync)
    local icon_id = SpecMgrs.data_mgr:GetItemData(item_id).icon
    UIFuncs.AssignSpriteByIconID(icon_id, cmp, load_active, field_name, cb, is_sync)
end

function UIFuncs.AssignSpriteByIconID(icon_id, cmp, load_active, field_name, cb, is_sync)
    is_sync = is_sync == nil and true or is_sync
    local icon_data = SpecMgrs.data_mgr:GetIconData(icon_id)
    if icon_data then
        if is_sync then
            UIFuncs.AssignUISpriteSync(icon_data.res_path, icon_data.res_name, cmp, load_active, field_name, cb)
        else
            UIFuncs.AssignUISpriteAsync(icon_data.res_path, icon_data.res_name, cmp, load_active, field_name, cb)
        end
    else
        PrintError("UIFuncs: not icon data",icon_id)
    end
end

function UIFuncs.AssignUISpriteSync(res_path, res_name, cmp, load_active, field_name, cb)
    field_name = field_name or "sprite"
    local sprite = SpecMgrs.res_mgr:GetSpriteSync(res_path, res_name)
    if not IsNil(cmp) then
        cmp[field_name] = sprite
        if load_active then
            cmp.gameObject:SetActive(true)
        end
        if cb then
            cb()
        end
    end
end

function UIFuncs.AssignUISpriteAsync(res_path, res_name, cmp, load_active, field_name, cb)
    field_name = field_name or "sprite"
    if not UIFuncs._assign_sprite_co_record then
        UIFuncs._assign_sprite_co_record = {}
    end
    local key = cmp:GetInstanceID() .. field_name
    if UIFuncs._assign_sprite_co_record[key] then
        coroutine.clear(UIFuncs._assign_sprite_co_record[key])
        UIFuncs._assign_sprite_co_record[key] = nil
    end
    UIFuncs._assign_sprite_co_record[key] = coroutine.start(UIFuncs._CoAssignUISprite, res_path, res_name, cmp, load_active, field_name, cb, key)
end

function UIFuncs._CoAssignUISprite(res_path, res_name, cmp, load_active, field_name, cb, key)
    local sprite = SpecMgrs.res_mgr:CoGetSprite(res_path, res_name)
    if not IsNil(cmp) then
        cmp[field_name] = sprite
        if load_active then
            cmp.gameObject:SetActive(true)
        end
        if cb then
            cb()
        end
    end
    UIFuncs._assign_sprite_co_record[key] = nil
end

function UIFuncs.AssignItemMes(obj, item_id, item_num, is_set_native)  -- 通用 物品信息
    local icon_id = SpecMgrs.data_mgr:GetItemData(item_id).icon
    local icon_data = SpecMgrs.data_mgr:GetIconData(icon_id)
    if obj:FindChild("ItemImage") then
        local image_cmp = obj:FindChild("ItemImage"):GetComponent("Image")
        UIFuncs.AssignUISpriteSync(icon_data.res_path, icon_data.res_name, image_cmp)
        if is_set_native then
            image_cmp:SetNativeSize()
        end
    end
    if obj:FindChild("ItemValText") then
        obj:FindChild("ItemValText"):GetComponent("Text").text = item_num or ItemUtil.GetItemNum(item_id)
    end
    if obj:FindChild("ItemText") then
        obj:FindChild("ItemText"):GetComponent("Text").text = SpecMgrs.data_mgr:GetItemData(item_id).name
    end
end

function UIFuncs.HexToRGBColor(hex)
    local r = string.sub(hex, 1, 2)
    local g = string.sub(hex, 3, 4)
    local b = string.sub(hex, 5, 6)
    r = tonumber(r, 16) / 255
    g = tonumber(g, 16) / 255
    b = tonumber(b, 16) / 255
    return Color.New(r, g, b)
end

function UIFuncs.RGBColorToHex(color)
    local r = math.ceil(color.r * 255)
    local g = math.ceil(color.g * 255)
    local b = math.ceil(color.b * 255)
    return string.format("%.2x",r) .. string.format("%.2x", g) .. string.format("%.2x", b)
end

function UIFuncs.TextIndent(str, count)
    count = count or 2
    local text = ""
    for i = 1,count do
        text = text .. "　"
    end
    text = text .. str
    return text
end

-- 拆解超链接
function UIFuncs.ParseTextHref(text)
    local front_match_idx = 1
    local tmp_tb = {}
    local match_str = string.match(text,"<.-><.->%b[]<.-><.->")
    while match_str do
        tmp_tb[front_match_idx] = tmp_tb[front_match_idx] or {}
        table.insert(tmp_tb[front_match_idx], match_str)
        match_str = string.match(match_str,"%b[]")
        text = string.gsub(text, "<.-><.->%b[]<.-><.->", match_str, 1)
        table.insert(tmp_tb[front_match_idx], match_str)
        front_match_idx = front_match_idx + 1
        match_str = string.match(text,"<.-><.->%b[]<.-><.->")
    end
    return text, tmp_tb
end

-- 添加打字效果的文本
function UIFuncs.AddTypeEffectText(ui_cls, text_go ,content, type_interval, end_cb)
    local word_tb = UTF8.Split(content)
    local index = 1
    text_go:GetComponent("Text").text = ""
    ui_cls:AddDynamicUI(text_go,function ()
        text_go:GetComponent("Text").text = text_go:GetComponent("Text").text .. word_tb[index]
        index = index + 1
        if index > #word_tb and end_cb then end_cb() end
    end, type_interval, #word_tb - 1)
end

--  时间
function UIFuncs.TimeDelta2Table(time_delta, level)
    level = math.clamp(level, 1, 6)
    time_delta = math.floor(time_delta)
    if time_delta < 0 then
        time_delta = 0
    end
    local radix = {60,60,24,30,12}
    local left_time = {0,0,0,0,0,0}  --[1]=sec,[2]=min,[3]=hour,[4]=day,[5]=month,[6]=year
    for i = 1,level do
        if time_delta <= 0 then
            break
        end
        if radix[i] and i < level then
            left_time[i] = time_delta % radix[i]
            time_delta = math.floor(time_delta / radix[i])
        else
            left_time[i] = time_delta
        end
    end
    return left_time
end

function UIFuncs.TimeDelta2Str(time_delta, level, format)
    if not time_delta then
        PrintError("time_delta is nil")
        return
    end
    format = format and format or UIConst.ShortCDRemainFormat
    local replace_word = {"SS", "MM", "HH", "dd", "mm", "yy", "S", "M", "H", "d", "m", "y"}
    level = level or 3
    local time_table = UIFuncs.TimeDelta2Table(time_delta, level)
    local ret = format
    local index = 1
    for i = 1, 6 do
        time_table[6 + i] = time_table[i]
        if i <= 3 and time_table[i] < 10 then
            time_table[i] = "0" .. time_table[i]
        end
    end
    for i = 1, #replace_word do
        ret = string.gsub(ret, replace_word[i], time_table[i])
    end
    return ret
end

function UIFuncs.TimeToFormatStr(time, time_format)
    time_format = time_format or UIConst.Text.TIME_FORMAT
    return os.date(time_format, time)
end

function UIFuncs.DateToFormatStr(time)
    return UIFuncs.TimeToFormatStr(time, UIConst.DATE_FORMAT)
end

function UIFuncs.GetCountDownDayStr(time_delta, day_format, hour_format)
    local m_day_format = day_format and day_format or UIConst.LongCDRemainFormat
    local m_hour_format = hour_format and hour_format or UIConst.ShortCDRemainFormat
    local one_day = 86400
    local ret
    if time_delta > one_day then
        ret = UIFuncs.TimeDelta2Str(time_delta, 4, m_day_format)
    else
        ret = UIFuncs.TimeDelta2Str(time_delta, 4, m_hour_format)
    end
    return ret
end

function UIFuncs.GetReaminTime(start_time, max_cool_time)
    local next_cooldown_time = start_time + max_cool_time
    local remain_time = next_cooldown_time - Time:GetServerTime()
    if remain_time < 0 then return 0 end
    return remain_time
end

--  根据时间戳获取月份日期 如3.21
function UIFuncs.GetMonthDate(time, format)
    format = format or UIConst.Text.MONTH_DAY_FORMAT
    local date_time = os.date("*t", time)
    local str = string.format(format, date_time.month, date_time.day)
    return str
end

--  根据时间戳获取小时分钟 如19:51
function UIFuncs.GetHourMinDate(time, format)
    format = format or UIConst.HourMinFormat
    return os.date(format, time)
end

--  时间end

-- 获取 go 在画布上的坐标，返回值为vector2
function UIFuncs.GetGoPositionV2(ui_class, go)
    local canvas = ui_class.canvas
    local RectTransformUtility = UnityEngine.RectTransformUtility
    local rect_transform = canvas:GetComponent("RectTransform")
    local camera = canvas:GetComponent("Camera")
    local _, pos = RectTransformUtility.ScreenPointToLocalPointInRectangle(rect_transform, go.position, nil)
    return pos
end

function UIFuncs.GetVerticalText(str)
    local str_tb = UTF8.Split(str or "")
    return table.concat(str_tb, "\n")
end

-- Example UIFuncs.ChangeStrColor("hahs","Green")
function UIFuncs.ChangeStrColor(str, color)
    return string.format(UIConst.Text.SIMPLE_COLOR, UIConst.Color[color], str)
end

function UIFuncs.DataToSortedList(data, sort_func)
    sort_func = sort_func or function (a,b)
        return a.id < b.id
    end
    local sorted_table = {}
    for _, v in pairs(data) do
        table.insert(sorted_table, v)
    end
    table.sort(sorted_table, sort_func)
    return sorted_table
end
function UIFuncs.GetCoolDownTimeDelta(start_time, cd_time)
    local past_time = Time:GetServerTime() - start_time
    return cd_time - past_time
end

function UIFuncs.CreateSelector(ui, obj_list, select_func)
    local selector = UIListSelector.New()
    selector:DoInit(ui, obj_list, select_func)
    return selector
end

-- 添加数量的单位 1000 => 1.0k
function UIFuncs.AddCountUnit(count)
    if count > 0 then
        local ret = math.floor(count / kBillion)
        if ret >= 1000 then return string.format(UIConst.Text.BILLION_COUNT, ret) end
        ret = math.floor(count / kMillion)
        if ret >= 1000 then return string.format(UIConst.Text.MILLION_COUNT, ret) end
        ret = math.floor(count / kThousand)
        if ret >= 1000 then return string.format(UIConst.Text.THOUSAND_COUNT, ret) end
        return math.floor(count)
    else
        return 0
    end
end

-- 拼接缘分描述文本
function UIFuncs.GetFateDescStr(fate, active)
    local fate_data = SpecMgrs.data_mgr:GetFateData(fate)
    local format = active and UIConst.Text.SPELL_TEXT_FORMAT or UIConst.Text.UNACTIVE_SPELL_TEXT_FORMAT
    if not fate_data.fate_hero and not fate_data.fate_item then
        PrintError("Get Fate Desc: missing fate_hero or fate_item")
        return
    end
    local format_tb = {}
    if fate_data.fate_hero then
        table.insert(format_tb, SpecMgrs.data_mgr:GetHeroData(fate_data.fate_hero).name)
    elseif fate_data.fate_item then
        table.insert(format_tb, SpecMgrs.data_mgr:GetItemData(fate_data.fate_item).name)
    end
    for i, attr in ipairs(fate_data.attr_list) do
        local attr_data = SpecMgrs.data_mgr:GetAttributeData(attr)
        table.insert(format_tb, attr_data.name)
        table.insert(format_tb, attr_data.is_pct and string.format(UIConst.Text.PERCENT, fate_data.attr_value_list[i]) or fate_data.attr_value_list[i])
    end
    local desc = string.format(fate_data.desc, table.unpack(format_tb))
    return string.format(format, fate_data.name, desc)
end

function UIFuncs.GetHeroTalentDescWithName(talent, break_lv, active)
    local talent_data = SpecMgrs.data_mgr:GetTalentData(talent)
    local format = active and UIConst.Text.SPELL_TEXT_FORMAT or UIConst.Text.UNACTIVE_SPELL_TEXT_FORMAT
    local talent_name = string.format(talent_data.name, break_lv)
    local talent_desc = UIFuncs.GetHeroTalentDesc(talent_data, break_lv)
    return string.format(format, talent_name, talent_desc)
end

function UIFuncs.GetHeroTalentDesc(talent_data, break_lv)
    local format_tb = {}
    for i, attr in ipairs(talent_data.attr_list) do
        local attr_data = SpecMgrs.data_mgr:GetAttributeData(attr)
        table.insert(format_tb, attr_data.name)
        table.insert(format_tb, attr_data.is_pct and string.format(UIConst.Text.PERCENT, talent_data.attr_value_list[i]) or talent_data.attr_value_list[i])
    end
    table.insert(format_tb, break_lv)
    return string.format(talent_data.desc, table.unpack(format_tb))
end

function UIFuncs.GetEquipSpellDesc(spell_id, refine_lv, active)
    local spell_data = SpecMgrs.data_mgr:GetRefineSpellData(spell_id)
    local format = active and UIConst.Text.SPELL_TEXT_FORMAT or UIConst.Text.UNACTIVE_SPELL_TEXT_FORMAT
    local format_tb = {}
    if spell_data.attr_list then
        for i, attr in ipairs(spell_data.attr_list) do
            local attr_data = SpecMgrs.data_mgr:GetAttributeData(attr)
            table.insert(format_tb, attr_data.name)
            table.insert(format_tb, attr_data.is_pct and string.format(UIConst.Text.PERCENT, spell_data.attr_value_list[i]) or spell_data.attr_value_list[i])
        end
    end
    if spell_data.buff_id then
        local buff_data = SpecMgrs.data_mgr:GetBuffData(spell_data.buff_id)
        if buff_data.trigger_rate then table.insert(format_tb, string.format(UIConst.Text.PERCENT, math.floor(buff_data.trigger_rate * 100))) end
        if buff_data.buff_value then
            table.insert(format_tb, buff_data.is_pct and string.format(UIConst.Text.PERCENT, buff_data.buff_value) or buff_data.buff_value)
        end
    end
    table.insert(format_tb, refine_lv)
    local spell_desc = string.format(spell_data.desc, table.unpack(format_tb))
    return string.format(format, spell_data.name, spell_desc)
end

function UIFuncs.GetBuffEffectText(effect_dict)
    local pct_effect_value = effect_dict.att_pct_hurt or effect_dict.attr_value_pct
    if pct_effect_value then return string.format(UIConst.Text.PERCENT, pct_effect_value) end
    local fixed_effect_value = effect_dict.att_pct_hurt or effect_dict.attr_value_pct
end

-- 通过关卡id获取关卡名
function UIFuncs.GetStageNameById(stage_id)
    local default_bg_num = UIConst.CityDefaultBgNum
    local stage_data = SpecMgrs.data_mgr:GetStageData(stage_id)
    local city_data = SpecMgrs.data_mgr:GetCityData(stage_data.city_id)
    local map_type_data = SpecMgrs.data_mgr:GetCityMapTypeData(city_data.city_map_type)
    local bg_build_num = #(SpecMgrs.data_mgr:GetInfiMapBuildNameData(map_type_data.bg_index).name_list)
    local start_build_index = map_type_data.build_index
    start_build_index = math.clamp(start_build_index, 1, bg_build_num)
    local stage_list = SpecMgrs.data_mgr:GetStageListByCityId(stage_data.city_id)
    local stage_num = #stage_list
    local bg_start_idx = default_bg_num + 1 - map_type_data.bg_index
    local bg_end_idx = 0

    for i = 1, default_bg_num do
        local index = bg_start_idx + i - 1
        local bg_index = default_bg_num - (index - 1) % default_bg_num
        local build_num = #(SpecMgrs.data_mgr:GetInfiMapBuildNameData(bg_index).name_list)
        if i == 1 then
            stage_num = stage_num - (build_num - start_build_index + 1)
        else
            stage_num = stage_num - build_num
        end
        if stage_num <= 0 then
            bg_end_idx = index
            break
        end
    end

    local stage_idx = 1
    for idx, i_stage_id in ipairs(stage_list) do
        if stage_id == i_stage_id then
            stage_idx = idx
            break
        end
    end

    local stage_index = stage_idx
    local cur_bg_idx, cur_build_idx = 0, 0
    for index = bg_start_idx, bg_end_idx do
        local bg_index = default_bg_num - (index - 1) % default_bg_num
        local build_num = #(SpecMgrs.data_mgr:GetInfiMapBuildNameData(bg_index).name_list)
        if index == bg_start_idx then
            local start_build_index = map_type_data.build_index
            local remain_build_num = build_num - start_build_index + 1
            if stage_index > remain_build_num then
                stage_index = stage_index - remain_build_num
            else
                cur_bg_idx, cur_build_idx = bg_index, start_build_index + stage_index - 1
                break
            end
        else
            if stage_index > build_num then
                stage_index = stage_index - build_num
            else
                cur_bg_idx, cur_build_idx = bg_index, stage_index
                break
            end
        end
    end

    local first_name = stage_data.name
    local build_name_list = SpecMgrs.data_mgr:GetInfiMapBuildNameData(cur_bg_idx).name_list
    local second_name = build_name_list[cur_build_idx] or build_name_list[1]
    local name = first_name .. second_name
    return name
end

-- 显示帮助当前帮助文档暂时放在UI内容表里
function UIFuncs.ShowPanelHelp(panel_name)
    local ui_content_data = SpecMgrs.data_mgr:GetUIContentData(panel_name)
    if ui_content_data then
        SpecMgrs.ui_mgr:ShowUI("HelpUI", ui_content_data)
    end
end

function UIFuncs.SetTextVal(obj, val)
    if obj then
        if obj:GetComponent("Text") then
            obj:GetComponent("Text").text = val
        end
    end
end

function UIFuncs.AssignItem(go, item_id, count)
    UIFuncs.InitItemGo({go = go, item_id = item_id, count = count})
end

function UIFuncs.GetInitItemGoByTb(param_tb)
    local go = UIFuncs.GetIconGo(param_tb.ui, param_tb.parent, param_tb.size)
    param_tb.go = go
    UIFuncs.InitItemGo(param_tb)
    return go
end

function UIFuncs.GetIconGo(ui, parent, size, item_path, icon_name)
    item_path = item_path or UIConst.PrefabResPath.Item
    local prefab = SpecMgrs.res_mgr:GetPrefabSync(item_path)
    local go = ui:GetUIObject(prefab, parent)
    go.name = icon_name or "Item"
    go:SetAsFirstSibling()
    local rect = go:GetComponent("RectTransform")
    if size then -- 传了size就居中 不传就平铺
        rect.anchorMin = Vector2.New(0.5, 0.5)
        rect.anchorMax = Vector2.New(0.5, 0.5)
        rect.pivot = Vector2.New(0.5, 0.5)
        rect.sizeDelta = size
    else
        rect.pivot = Vector2.New(0.5, 0.5)
        rect.anchorMin = Vector2.New(0, 0)
        rect.anchorMax = Vector2.New(1, 1)
        rect.offsetMin = Vector2.New(0, 0)
        rect.offsetMax = Vector2.New(0, 0)
    end
    return go
end

function UIFuncs.ChangeItemBgAndFarme(item_quality_id, bg_image, frame_image, icon_type)
    item_quality_id = item_quality_id or CSConst.LowestQuality -- 没有品质就是最低品质
    local icon_type = icon_type or UIConst.IconType.Item

    local quality_data = SpecMgrs.data_mgr:GetQualityData(item_quality_id)
    local bg_icon
    local frame_icon
    if icon_type == UIConst.IconType.Hero then
        bg_icon = quality_data.hero_bg
        frame_icon = quality_data.hero_frame
    elseif icon_type == UIConst.IconType.Lover then
        bg_icon = quality_data.lover_card_bg
        frame_icon = quality_data.lover_frame
    end
    bg_icon = bg_icon or quality_data.bg -- 默认道具框
    frame_icon = frame_icon or quality_data.frame
    UIFuncs.AssignSpriteByIconID(bg_icon, bg_image)
    frame_image = frame_image or bg_image.gameObject:FindChild("Frame"):GetComponent("Image")
    UIFuncs.AssignSpriteByIconID(frame_icon, frame_image)
end

function UIFuncs.GetItemQuality(item_id, item_data)
    local item_data = item_data or SpecMgrs.data_mgr:GetItemData(item_id)
    return item_data.quality or CSConst.LowestQuality
end

function UIFuncs.GetHeroQuality(hero_id, hero_data)
    local hero_data = hero_data or SpecMgrs.data_mgr:GetHeroData(hero_id)
    return hero_data.quality or CSConst.LowestQuality
end

function UIFuncs.ChangeItemFrag(item_quality_id, frag_image)
    local item_quality_data = SpecMgrs.data_mgr:GetQualityData(item_quality_id)
    UIFuncs.AssignSpriteByIconID(item_quality_data.frag, frag_image)
end

function UIFuncs.GetRoleIcon(role_id)
    local role_data = SpecMgrs.data_mgr:GetRoleLookData(role_id)
    return SpecMgrs.data_mgr:GetUnitData(role_data.unit_id).icon
end

function UIFuncs.InitRoleGo(param_tb)
    UIFuncs.InitRoleIcon(param_tb)
    local go = param_tb.go
    local name_go = param_tb.name_go or go:FindChild("PlarInfo/VipAndName/Name")
    if name_go then
        local name = param_tb.name
        if name then
            name_go:GetComponent("Text").text = name
        end
        name_go:SetActive(name and true or false)
    end

    local vip_go = param_tb.vip_go or go:FindChild("PlarInfo/VipAndName/Vip")
    if vip_go then
        local vip = param_tb.vip
        local is_show_vip = vip and vip > 0 or false
        if is_show_vip then
            local vip_icon = SpecMgrs.data_mgr:GetVipData(vip).icon
            UIFuncs.AssignSpriteByIconID(vip_icon, vip_go:FindChild("Image"):GetComponent("Image"))
        end
        vip_go:SetActive(is_show_vip)
    end

    local dynasty_go = param_tb.dynasty_go or go:FindChild("PlarInfo/Dynasty")
    if dynasty_go then
        local dynasty_name = param_tb.dynasty_name
        if dynasty_name then
            dynasty_go:GetComponent("Text").text = dynasty_name
        end
        dynasty_go:SetActive(dynasty_name and true or false)
    end

    local server_go = param_tb.server_go or go:FindChild("PlarInfo/Server")
    if server_go then
        local server_id = param_tb.server_id
        if server_id then
            server_go:GetComponent("Text").text = UIFuncs.GetServerName(server_id)
        end
        server_go:SetActive(server_id and true or false)
    end
    -- todo 添加点击弹出人物详情界面
end

function UIFuncs.InitRoleIcon(param_tb)
    local icon_id = UIFuncs.GetRoleIcon(param_tb.role_id)
    local go = param_tb.go
    UIFuncs.AssignSpriteByIconID(icon_id, go:FindChild("Icon"):GetComponent("Image"))
end

function UIFuncs.GetRoleNameWhihServerName(role_name, serv_id, format)
    format = format or UIConst.Text.MONTH_DAY_FORMAT
    local serv_neme = UIFuncs.GetServerName(serv_id)
    return string.format(format, serv_name, role_name)
end

--Example : UIFuncs.InitItemGo({go = , item_id = or item_data = , count = , name_go = , level = , })
--更换道具 道具框 背景 数量 等级, 名称 .. 更多自定义行为请自行添加
function UIFuncs.InitItemGo(param_tb)
    local item_go = param_tb.go
    param_tb.item_data = param_tb.item_data or SpecMgrs.data_mgr:GetItemData(param_tb.item_id)
    local item_id = param_tb.item_id or param_tb.item_data.id
    local item_data = param_tb.item_data

    local count = param_tb.count
    local count_go = param_tb.count_go or item_go:FindChild("Count")
    if count_go then count_go:SetActive(count ~= nil) end
    if count then
        count = type(count) == "number" and UIFuncs.AddCountUnit(count) or count
        count_go:FindChild("Text"):GetComponent("Text").text = count
    end

    local level = param_tb.level
    if level then
        local level_go = param_tb.level_go or item_go:FindChild("Level")
        level_go:GetComponent("Text").text = string.format(UIConst.Text.LV_TEXT, level)
    end

    local name_go = param_tb.name_go or item_go:FindChild("Name")
    local name_str = UIFuncs.GetItemName(param_tb)
    UIFuncs.UpdateText(name_go, name_str)

    
    local icon
    local quality_id
    if item_data.item_type == CSConst.ItemType.Hero then
        local hero_item = item_data.hero and SpecMgrs.data_mgr:GetItemData(item_data.hero) or item_data
        local hero_data = SpecMgrs.data_mgr:GetHeroData(hero_item.hero_id)
        local unit_data = SpecMgrs.data_mgr:GetUnitData(hero_data.unit_id)
        quality_id = UIFuncs.GetHeroQuality(nil, hero_data)
        icon = unit_data.icon
    elseif item_data.sub_type == CSConst.ItemSubType.EquipmentFragment then
        local equip_data = SpecMgrs.data_mgr:GetItemData(item_data.equipment)
        quality_id = UIFuncs.GetItemQuality(nil, equip_data)
        icon = equip_data.icon
    elseif item_data.item_type == CSConst.ItemType.Lover then
        local lover_item = item_data.lover and SpecMgrs.data_mgr:GetItemData(item_data.lover) or item_data
        local lover_data = SpecMgrs.data_mgr:GetLoverData(lover_item.lover_id)
        local unit_data = SpecMgrs.data_mgr:GetUnitData(lover_data.unit_id)
        quality_id = lover_data.quality
        icon = unit_data.icon
    else
        quality_id = UIFuncs.GetItemQuality(nil, item_data)
        icon = item_data.icon
    end
    if not param_tb.ignore_bg_and_frame then
        local frame_image = item_go:FindChild("Frame"):GetComponent("Image")
        UIFuncs.ChangeItemBgAndFarme(quality_id, item_go:GetComponent("Image"), frame_image, UIConst.IconType.Item)
    end

    print('-----------------------------------')
    print(item_data)
    
    --碎片处理
    if item_data.sub_type == CSConst.ItemSubType.EquipmentFragment or item_data.sub_type == CSConst.ItemSubType.LoverFragment or item_data.sub_type == CSConst.ItemSubType.HeroFragment then
        item_go:FindChild("Icon"):SetActive(false)

        local fragIcon = item_go:FindChild("FragIcon")
        if(fragIcon) then
            fragIcon:SetActive(true)
            local fragIconImage = fragIcon:GetComponent("Image")
            fragIconImage.material = nil
            local iconImage = item_go:FindChild("FragIcon/Icon"):GetComponent("Image")
            UIFuncs.AssignSpriteByIconID(icon, iconImage) 

            local frag_go = item_go:FindChild("Frag")
            if frag_go then
                if item_data.sub_type == CSConst.ItemSubType.EquipmentFragment or
                    item_data.sub_type == CSConst.ItemSubType.HeroFragment then
                    frag_go:SetActive(true)
                    UIFuncs.ChangeItemFrag(quality_id, frag_go:GetComponent("Image"))
                    fragIconImage.material = SpecMgrs.res_mgr:GetMaterialSync(UIConst.MaterialResPath.FragMask)
                else
                    frag_go:SetActive(false)
                end
            end
            local lover_frag_go = item_go:FindChild("LoverFrag")
            if lover_frag_go then
                lover_frag_go:SetActive(item_data.lover ~= nil)
                if item_data.sub_type == CSConst.ItemSubType.LoverFragment then
                    fragIconImage.material = SpecMgrs.res_mgr:GetMaterialSync(UIConst.MaterialResPath.LoverFragMask)
                end
            end
        end
    else
        item_go:FindChild("Icon"):SetActive(true)
        local icon_image = item_go:FindChild("Icon"):GetComponent("Image")
        icon_image.material = nil
        local fragIcon = item_go:FindChild("FragIcon")
        if(fragIcon) then
            fragIcon:SetActive(false)
        end
        item_go:FindChild("Frag"):SetActive(false)
        item_go:FindChild("LoverFrag"):SetActive(false)
        UIFuncs.AssignSpriteByIconID(icon, icon_image)          
    end     

    local can_click = param_tb.can_click == nil or param_tb.can_click -- 默认开启点击
    if can_click and param_tb.ui then
        UIFuncs.AddItemClick(param_tb.ui, item_go, item_id, param_tb.click_cb)
    end
end

function UIFuncs.GetItemIconId(item_data)
    if item_data.item_type == CSConst.ItemType.Hero then
        local hero_item_data = item_data.hero and SpecMgrs.data_mgr:GetItemData(item_data.hero) or item_data
        local hero_data = SpecMgrs.data_mgr:GetHeroData(hero_item_data.hero_id)
        return SpecMgrs.data_mgr:GetUnitData(hero_data.unit_id).icon
    else
        return item_data.icon
    end
end

--Example : UIFuncs.InitLoverGo({go = , lover_id = or lover_data = )
function UIFuncs.InitLoverGo(param_tb)
    local item_go = param_tb.go
    local lover_data = param_tb.lover_data or SpecMgrs.data_mgr:GetLoverData(param_tb.lover_id)
    local unit_data = SpecMgrs.data_mgr:GetUnitData(lover_data.unit_id)
    UIFuncs.AssignSpriteByIconID(unit_data.icon, item_go:FindChild("Icon"):GetComponent("Image"))
    local quality_data = SpecMgrs.data_mgr:GetQualityData(lover_data.quality)
    local grade_go = item_go:FindChild("Grade")
    if grade_go then
        UIFuncs.AssignSpriteByIconID(quality_data.grade, grade_go:GetComponent("Image"))
        grade_go:SetActive(true)
    end
    UIFuncs.ChangeItemBgAndFarme(lover_data.quality, item_go:GetComponent("Image"), item_go:FindChild("Frame"):GetComponent("Image"), UIConst.IconType.Lover)
    UIFuncs.UpdateText(item_go:FindChild("Name"), lover_data.name)
end

-- 结婚后儿女头像
function UIFuncs.InitMarriedChildGo(param_tb)
    local go = param_tb.go
    local child_data = ComMgrs.dy_data_mgr.child_center_data:GetChildData(param_tb.child_id)
    local _, unit_list = ComMgrs.dy_data_mgr.child_center_data:GetChildUnitId(child_data)
    local boy_icon_id = SpecMgrs.data_mgr:GetUnitData(unit_list[1]).icon
    local girl_icon_id = SpecMgrs.data_mgr:GetUnitData(unit_list[2]).icon
    UIFuncs.AssignSpriteByIconID(girl_icon_id, go:FindChild("GirlIcon"):GetComponent("Image"))
    UIFuncs.AssignSpriteByIconID(boy_icon_id, go:FindChild("BoyIcon"):GetComponent("Image"))
end

function UIFuncs.UpdateText(go, str)
    if not go then return end
    go:GetComponent("Text").text = str
end

function UIFuncs.AddItemClick(ui, go, item_id, click_cb)
    click_cb = click_cb or function ()
        SpecMgrs.ui_mgr:ShowItemPreviewUI(item_id)
    end
    ui:AddClick(go, click_cb)
end

--Example : 初始化 道具名称：图标 数量
--UIFuncs.InitGetItem({go = , item_id = or item_data = , count = ,})
function UIFuncs.InitGetItemGo(param_tb)
    local item_go = param_tb.go
    param_tb.item_data = param_tb.item_data or SpecMgrs.data_mgr:GetItemData(param_tb.item_id)
    local item_data = param_tb.item_data
    local count = param_tb.count or 0
    item_go:GetComponent("Text").text = string.format(UIConst.Text.COLON, item_data.name)
    UIFuncs.AssignSpriteByIconID(item_data.icon, item_go:FindChild("Image"):GetComponent("Image"))
    item_go:FindChild("Image/Text"):GetComponent("Text").text = count
end

--  change_name_color item_id
-- 获取带品质颜色物品名字
function UIFuncs.GetItemName(param_tb)
    local item_data = param_tb.item_data or SpecMgrs.data_mgr:GetItemData(param_tb.item_id)
    local name_str = item_data.name or UIConst.ItemNameDefaultFormat[item_data.sub_type]
    if item_data.sub_type == CSConst.ItemSubType.Hero then
        local hero_data = SpecMgrs.data_mgr:GetHeroData(item_data.hero_id)
        param_tb.quality = hero_data.quality
        name_str = hero_data.name
    elseif item_data.sub_type == CSConst.ItemSubType.HeroFragment then
        local hero_item = SpecMgrs.data_mgr:GetItemData(item_data.hero)
        local hero_data = SpecMgrs.data_mgr:GetHeroData(hero_item.hero_id)
        param_tb.quality = hero_data.quality
        name_str = string.format(name_str, hero_data.name)
    elseif item_data.sub_type == CSConst.ItemSubType.EquipmentFragment then
        local equip_item = SpecMgrs.data_mgr:GetItemData(item_data.equipment)
        param_tb.quality = equip_item.quality
        if equip_item.is_treasure then
            name_str = string.format(name_str, equip_item.name, item_data.frag_index)
        else
            name_str = string.format(name_str, equip_item.name)
        end
    elseif item_data.sub_type == CSConst.ItemSubType.Lover then
        local lover_data = SpecMgrs.data_mgr:GetLoverData(item_data.lover_id)
        param_tb.quality = lover_data.quality
        name_str = lover_data.name
    elseif item_data.sub_type == CSConst.ItemSubType.LoverFragment then
        local lover_item = SpecMgrs.data_mgr:GetItemData(item_data.lover)
        local lover_data = SpecMgrs.data_mgr:GetLoverData(lover_item.lover_id)
        param_tb.quality = lover_data.quality
        name_str = string.format(name_str, lover_data.name)
    else
        param_tb.quality = item_data.quality
    end
    if param_tb.change_name_color then
        param_tb.is_on_dark_bg = param_tb.is_on_dark_bg == nil or param_tb.is_on_dark_bg -- 现在默认都是黑色底了
        local color_str = UIFuncs.GetQualityColorStr(param_tb)
        name_str = string.format(UIConst.Text.SIMPLE_COLOR, color_str, name_str)
    end
    return name_str
end

function UIFuncs.GetItemDesc(item_id)
    local item_data = SpecMgrs.data_mgr:GetItemData(item_id)
    local desc = item_data.desc or UIConst.Text.ITEM_DEFAULT_DESC
    if item_data.sub_type == CSConst.ItemSubType.LoverFragment then
        local lover_item = SpecMgrs.data_mgr:GetItemData(item_data.lover)
        local lover_data = SpecMgrs.data_mgr:GetLoverData(lover_item.lover_id)
        desc = string.format(desc, lover_data.name)
    elseif item_data.sub_type == CSConst.ItemSubType.EquipmentFragment then
        local equip_data = SpecMgrs.data_mgr:GetItemData(item_data.equipment)
        if equip_data.is_treasure then
            desc = string.format(desc, #equip_data.fragment_list, equip_data.name, equip_data.name)
        else
            desc = string.format(desc, item_data.synthesize_count, equip_data.name)
        end
    elseif item_data.sub_type == CSConst.ItemSubType.HeroFragment then
        local hero_item = SpecMgrs.data_mgr:GetItemData(item_data.hero)
        local hero_data = SpecMgrs.data_mgr:GetHeroData(hero_item.hero_id)
        desc = string.format(desc, item_data.synthesize_count, hero_data.name, hero_data.name)
    elseif item_data.random_attr_value_list then
        desc = string.format(desc, item_data.random_attr_value_list[1])
    else
        desc = string.format(desc, item_data.recover_count or item_data.add_exp or item_data.attr_value)
    end
    return desc
end

--获取装备品质颜色 如a0103c
function UIFuncs.GetQualityColorStr(param_tb)
    local quality_id = param_tb.quality or SpecMgrs.data_mgr:GetItemData(param_tb.item_id).quality
    local quality_data = SpecMgrs.data_mgr:GetQualityData(quality_id)
    local is_on_dark_bg = param_tb.is_on_dark_bg == nil or param_tb.is_on_dark_bg
    local color_str = is_on_dark_bg and quality_data.color1 or quality_data.color
    return color_str
end

-- 根据装备显示装备部位名字
function UIFuncs.GetEquipPartName(param_tb)
    local item_data = param_tb.item_data or SpecMgrs.data_mgr:GetItemData(param_tb.item_id)
    local equip_data = SpecMgrs.data_mgr:GetEquipPartData(item_data.part_index)
    local is_change_color = param_tb.is_change_color == nil and true or param_tb.is_change_color
    if is_change_color then
        param_tb.quality = item_data.quality
        local color_str = UIFuncs.GetQualityColorStr(param_tb)
        return string.format(UIConst.Text.SIMPLE_COLOR, color_str, equip_data.name)
    else
        return equip_data.name
    end
end

function UIFuncs.CreateHeroItem(ui, parent, hero_id)
    local prefab = SpecMgrs.res_mgr:GetPrefabSync(UIConst.PrefabResPath.HeroItem)
    local obj = ui:GetUIObject(prefab, parent)
    obj:GetComponent("RectTransform").sizeDelta = parent:GetComponent("RectTransform").sizeDelta
    UIFuncs.InitHeroGo({go = obj, hero_id = hero_id})
    return obj
end

--Example : UIFuncs.InitEquipGo({go = , role_item = )
function UIFuncs.InitEquipGo(param_tb)
    local go = param_tb.go
    local role_item = param_tb.role_item
    UIFuncs.InitItemGo({go = go, item_id = role_item.item_id})
    go:FindChild("StrengthenText"):GetComponent("Text").text = string.format(UIConst.Text.LEVEL, role_item.strengthen_lv)
end

--Example : UIFuncs.InitHeroGo({go = , hero_id = or hero_data = )
function UIFuncs.InitHeroGo(param_tb)
    local item_go = param_tb.go
    local hero_data = param_tb.hero_data or SpecMgrs.data_mgr:GetHeroData(param_tb.hero_id)
    local unit_data = SpecMgrs.data_mgr:GetUnitData(hero_data.unit_id)
    UIFuncs.AssignSpriteByIconID(unit_data.icon, item_go:FindChild("Icon"):GetComponent("Image"))
    local quality_data = SpecMgrs.data_mgr:GetQualityData(hero_data.quality)
    local grade_go = item_go:FindChild("Grade")
    if grade_go then
        UIFuncs.AssignSpriteByIconID(quality_data.grade, grade_go:GetComponent("Image"))
        grade_go:SetActive(true)
    end
    UIFuncs.ChangeItemBgAndFarme(hero_data.quality, item_go:GetComponent("Image"), item_go:FindChild("Frame"):GetComponent("Image"), UIConst.IconType.Hero)
    UIFuncs.UpdateText(item_go:FindChild("Name"), hero_data.name)
end

-- 根据属性是否是百分比返回字符串
function UIFuncs.GetAttrStr(attr_key, attr_add_num, change_color)
    local attr_format = change_color and UIConst.Text.NEXT_ATTR_FORMAT or UIConst.Text.ATTR_VALUE_FORMAT
    local attr_data = SpecMgrs.data_mgr:GetAttributeData(attr_key)
    local attr_add_num = attr_data.is_pct and string.format(UIConst.Text.PERCENT, attr_add_num) or UIFuncs.AddCountUnit(attr_add_num)
    return string.format(attr_format, attr_data.name, attr_add_num)
end

function UIFuncs.GetAttrValue(attr_key, attr_add_num)
    local attr_data = SpecMgrs.data_mgr:GetAttributeData(attr_key)
    local attr_value = attr_data.is_pct and string.format(UIConst.Text.PERCENT, attr_add_num) or UIFuncs.AddCountUnit(attr_add_num)
    return attr_value
end

function UIFuncs.GetPercentStr(num, format)
    local num  = math.floor(num * 100)
    format = format or UIConst.Text.PERCENT
    return string.format(format, num)
end

-- 0.1 => +10%
function UIFuncs.GetAddPercentStr(num)
    local num  = math.floor(num * 100)
    return string.format(UIConst.Text.ADD_PERCENT, num)
end

-- 10 => +10
function UIFuncs.GetAddStr(num)
    return string.format(UIConst.Text.ADD_VALUE_FORMAL, num)
end

function UIFuncs.GetUseItemStr(item_id, count, desc)
    local item_data = SpecMgrs.data_mgr:GetItemData(item_id)
    return string.format(UIConst.Text.CONFIRM_USE_ITEM, count, item_data.name, desc)
end

function UIFuncs.SetItemNumTextPic(ui, text_go, item_id, num, format)
    local icon_id = SpecMgrs.data_mgr:GetItemData(item_id).icon
    local str = string.format(format or UIConst.Text.ITEM_ICON_NUM_FORMAT, icon_id, num)
    UIFuncs.SetTextPic(ui, text_go, str)
end

-- 图文混排 格式 "<quad id=9 size=40/>" 需要加上TextPic组件
function UIFuncs.SetTextPic(ui, text_go, str)
    local text_cmp = text_go:GetComponent("TextPic")
    if not text_cmp then
        PrintError("No TextPic Component")
    end
    local item_id_list = text_cmp:SetTextPicValue(str)
    local item_size_list = text_cmp:GetImageSize()
    local front_size = text_cmp.fontSize
    local image_obj_list = {}

    local image_count = 0
    if text_go.childCount > 0 then
        for i = 0, text_go.childCount - 1 do
            local image = text_go:GetChild(i)
            if item_id_list.Length > i then
                image:SetActive(true)
                UIFuncs.AssignSpriteByIconID(tonumber(item_id_list[i]), image:GetComponent("Image"))
                image:GetComponent("RectTransform").sizeDelta = Vector2.New(item_size_list[i], item_size_list[i])
                image_count = image_count + 1
            else
                image:SetActive(false)
            end
        end
    end

    local text_image = SpecMgrs.res_mgr:GetPrefabSync("UI/UIBtnPrefab/TextImage")
    for i = image_count, item_id_list.Length - 1 do
        local image = GameObject.Instantiate(text_image)
        image:SetActive(true)
        image:SetParent(text_go)
        image.localScale = Vector3.one
        local image_cmp = image:GetComponent("Image")
        UIFuncs.AssignSpriteByIconID(tonumber(item_id_list[i]), image_cmp)
        image:GetComponent("RectTransform").sizeDelta = Vector2.New(item_size_list[i], item_size_list[i])
    end
end

function UIFuncs.GetMonsterGroupScore(monster_group_id)
    return CSFunction.get_monster_group_score(monster_group_id)
end

function UIFuncs.GetMonsterGroupScoreSuggestStr(monster_group_id, level)
    local score = CSFunction.get_monster_group_score(monster_group_id, level)
    local self_score = ComMgrs.dy_data_mgr:ExGetFightScore()
    local color = self_score >= score and "Green1" or "Red1"
    local score_str = UIFuncs.AddCountUnit(score)
    score_str = UIFuncs.ChangeStrColor(score_str, color)
    return string.format(UIConst.Text.SUGGEST_SCORE, score_str)
end

function UIFuncs.RegisterUpdateBattlePoint(ui, tag, text_obj)
    text_obj.text = UIFuncs.AddCountUnit(ComMgrs.dy_data_mgr:ExGetBattleScore())
    ComMgrs.dy_data_mgr:RegisterUpdateBattleScoreEvent(tag, function(_, val)
        text_obj.text = UIFuncs.AddCountUnit(val)
    end)
    ui:RegisterUIDestroyEvent(tag, function()
        ComMgrs.dy_data_mgr:UnregisterUpdateBattleScoreEvent(tag)
        ui:UnregisterUIDestroyEvent(tag)
    end)
end

--  注册更新角色物品数量
function UIFuncs.RegisterUpdateItemNumFunc(ui, tag, func, item_id)
    local param_tb =
    {
        ui = ui,
        tag = tag,
        func = func,
        item_id = item_id,
        is_func = true,
    }
    UIFuncs._RegisterUpdateItemNum(param_tb)
end

function UIFuncs.RegisterUpdateItemNum(ui, tag, text_obj, item_id)
    local param_tb =
    {
        ui = ui,
        tag = tag,
        text_obj = text_obj,
        item_id = item_id,
        is_text_obj = true,
    }
    UIFuncs._RegisterUpdateItemNum(param_tb)
end

function UIFuncs.UnregisterUpdateItemNum(ui, tag, item_id)
    local is_virtual_item = ItemUtil.IsVirtualItem(item_id)
    if is_virtual_item then
        ComMgrs.dy_data_mgr:UnregisterUpdateCurrencyEvent(tag)
    else
        ComMgrs.dy_data_mgr.bag_data:UnregisterUpdateBagItemEvent(tag)
    end
end

function UIFuncs._RegisterUpdateItemNum(param_tb)
    local item_id = param_tb.item_id
    local is_virtual_item = ItemUtil.IsVirtualItem(item_id)
    local tag = param_tb.tag
    local ui = param_tb.ui
    local cur_num
    if is_virtual_item then
        cur_num = ComMgrs.dy_data_mgr:GetCurrencyData()[item_id] or 0
    else
        cur_num = ComMgrs.dy_data_mgr.bag_data:GetBagItemCount(item_id) or 0
    end
    if param_tb.is_text_obj then
        param_tb.text_obj.text = UIFuncs.AddCountUnit(cur_num)
    elseif param_tb.is_func then
        param_tb.func(cur_num)
    end

    if is_virtual_item then
        ComMgrs.dy_data_mgr:RegisterUpdateCurrencyEvent(tag, function (_, currency)
            if not currency[item_id] then return end
            local num = currency[item_id] or 0
            if num then
                if param_tb.is_text_obj then
                    param_tb.text_obj.text = UIFuncs.AddCountUnit(num)
                elseif param_tb.is_func then
                    param_tb.func(num)
                end
            end
        end)
    else
        ComMgrs.dy_data_mgr.bag_data:RegisterUpdateBagItemEvent(tag, function(_, op, bag_item)
            if bag_item.item_id ~= item_id then return end
            if param_tb.is_text_obj then
                param_tb.text_obj.text = UIFuncs.AddCountUnit(bag_item.count)
            elseif param_tb.is_func then
                param_tb.func(bag_item.count)
            end
        end)
    end

    param_tb.ui:RegisterUIDestroyEvent(tag, function()
        if is_virtual_item then
            ComMgrs.dy_data_mgr:UnregisterUpdateCurrencyEvent(tag)
        else
            ComMgrs.dy_data_mgr.bag_data:UnregisterUpdateBagItemEvent(tag)
        end
        param_tb.ui:UnregisterUIDestroyEvent(tag)
    end)
end

function UIFuncs.CheckItemCount(item_id, cost_item_count, is_show_tip)
    if ComMgrs.dy_data_mgr:ExCheckItemCount(item_id, cost_item_count) then
        return true
    else
        if is_show_tip then
            local item_data = SpecMgrs.data_mgr:GetItemData(item_id)
            if item_data.sub_type == CSConst.ItemSubType.CostValue then
                UIFuncs.CheckCostValueRecoverItemCount(item_id)
            elseif item_id == CSConst.Virtual.Diamond then
                SpecMgrs.ui_mgr:ShowUI("RechargeTipUI",cost_item_count)
            elseif item_data.sub_type == CSConst.ItemSubType.Currency then
                local str = string.format(UIConst.Text.ITEM_NOT_ENOUGH, item_data.name)
                SpecMgrs.ui_mgr:ShowTipMsg(str)
            else
                UIFuncs.ShowItemItemAccessUI(item_id)
            end
        end
        return false
    end
end

function UIFuncs.CheckCostValueRecoverItemCount(item_id)
    local item_data = SpecMgrs.data_mgr:GetItemData(item_id)
    local recover_need_item = item_data.recover_need_item
    if recover_need_item then
        local recover_item_data = SpecMgrs.data_mgr:GetItemData(recover_need_item)
        local recover_limit_count = SpecMgrs.data_mgr:GetParamData("recover_item_use_max_num").f_value
        local item_info = ComMgrs.dy_data_mgr.bag_data:GetBagItemByItemId(recover_need_item)
        local over_limit = ComMgrs.dy_data_mgr:ExGetCostItemOverLimit(item_id)
        if over_limit then
            local loss_value = over_limit - ComMgrs.dy_data_mgr:ExGetCostValue(item_id)
            recover_limit_count = math.min(recover_limit_count, math.floor(loss_value / recover_item_data.recover_count))
        end
        local item_guid = item_info and item_info.guid
        local item_num = ComMgrs.dy_data_mgr:ExGetItemCount(recover_need_item)
        if item_guid and item_num > 0 then
            local data = {
                title = UIConst.Text.ITEM_USE,
                get_content_func = function (select_num)
                    return UIFuncs.GetRecoverItemContent(item_id, recover_need_item, select_num)
                end,
                max_select_num = math.min(item_num, recover_limit_count),
                confirm_cb = function(select_num)
                    UIFuncs.SendUseBagItem(item_guid, select_num)
                end,
            }
            SpecMgrs.ui_mgr:ShowSelectItemUseByTb(data)
        else
            UIFuncs.ShowItemItemAccessUI(recover_need_item)
        end
    else
        UIFuncs.ShowItemItemAccessUI(item_id)
    end
end

function UIFuncs.GetRecoverItemContent(item_id, recover_need_item, select_num)
    local content_tb = {}
    content_tb.item_dict = {[recover_need_item] = select_num}
    local item_name = SpecMgrs.data_mgr:GetItemData(item_id).name
    local recover_item_data = SpecMgrs.data_mgr:GetItemData(recover_need_item)
    local recover_num = recover_item_data.recover_count * select_num
    recover_num = UIFuncs.AddCountUnit(recover_num)
    content_tb.desc_str = string.format(UIConst.Text.CONFIRM_USE_ITEM_TO_RECOVER, select_num, recover_item_data.name, recover_num, item_name)
    return content_tb
end

--  使用消耗品
function UIFuncs.UseBagItem(item_id)
    if not UIFuncs.CheckItemCount(item_id, 1, true) then return end
    local item_guid = ComMgrs.dy_data_mgr.bag_data:GetBagItemByItemId(item_id).guid
    local item_num = tonumber(ItemUtil.GetItemNum(item_id))
    local data = {
        title = UIConst.Text.ITEM_USE,
        get_content_func = function (select_count)
            local item_dict = {}
            item_dict[item_id] = select_count
            return {desc_str = string.format(UIConst.Text.ITEM_COUNT, item_num), item_dict = item_dict}
        end,
        max_select_num = item_num < 99 and item_num or 99,
        confirm_cb = function(count)
            UIFuncs.SendUseBagItem(item_guid, count)
        end,
    }
    SpecMgrs.ui_mgr:ShowSelectItemUseByTb(data)
end

function UIFuncs.SendUseBagItem(item_guid, count)
    local data = {
        item_guid = item_guid,
        item_count = count,
    }
    SpecMgrs.msg_mgr:SendUseBagItem(data, function(resp)
        if resp.errcode ~= 0 then
            SpecMgrs.ui_mgr:ShowTipMsg(UIConst.Text.ITEM_USE_FAILED)
            return
        else
            -- todo
        end
    end)
end

function UIFuncs.ShowItemItemAccessUI(item_id)
    SpecMgrs.ui_mgr:ShowUI("ItemAccessUI",item_id)
end

function UIFuncs.CheckItemCountByList(item_id_list, item_count_list, is_show_tip)
    local is_enough = true
    for i, item_id in ipairs(item_id_list) do
        if not UIFuncs.CheckItemCount(item_id, item_count_list[i], is_show_tip) then
            is_enough = false
        end
    end
    return is_enough
end

function UIFuncs.CheckItemCountByDict(item_dict, is_show_tip)
    local is_enough = true
    for item_id, count in pairs(item_dict) do
        if not UIFuncs.CheckItemCount(item_id, count, is_show_tip) then
            is_enough = false
        end
    end
    return is_enough
end

function UIFuncs.GetInitTopBar(ui, top_bar_parent, panel_name, close_cb)
    local top_bar_path = UIConst.PrefabResPath.TopBar
    local prefab = SpecMgrs.res_mgr:GetPrefabSync(top_bar_path)
    local top_bar = ui:GetUIObject(prefab, top_bar_parent)
    top_bar.name = "TopBar"
    ui.top_bar = top_bar
    --top_bar.localPosition = Vector2.zero
    top_bar:GetComponent("RectTransform").anchoredPosition = Vector2.zero
    UIFuncs.InitTopBar(ui, top_bar, panel_name, close_cb)
end

function UIFuncs.InitTopBar(ui, top_bar, panel_name, close_cb)
    local content_data = SpecMgrs.data_mgr:GetUIContentData(panel_name)
    local is_show_help_part = content_data.help_type and true or false
    if is_show_help_part then
        ui:AddClick(top_bar:FindChild("HelpBtn"), function ()
            UIFuncs.ShowPanelHelp(panel_name)
        end)
    end
    local help_go = top_bar:FindChild("HelpBtn")
    if help_go then
        help_go:SetActive(is_show_help_part)
    end
    local Image = top_bar:FindChild("Image")
    if Image then
        Image:SetActive(is_show_help_part)
    end
    ui:AddClick(top_bar:FindChild("CloseBtn"), function ()
        if close_cb then
            close_cb(ui)
        else
            SpecMgrs.ui_mgr:HideUI(ui)
        end
    end)
    top_bar:FindChild("CloseBtn/Title"):GetComponent("Text").text = content_data.title or ""
    local item_parent = top_bar:FindChild("Itemlist")
    item_parent:GetComponent("RectTransform").anchoredPosition = is_show_help_part and Vector2.New(0, 0) or Vector2.New(130, 0)
    if not item_parent then return end
    local item_temp = item_parent:FindChild("Item")
    item_temp:SetActive(false)
    if content_data.top_bar_item_list then
        if not ui._item_to_text_list then ui._item_to_text_list = {} end -- 注意名字重叠
        local go
        local item_data
        for _, item_id in ipairs(content_data.top_bar_item_list) do
            local go = ui:GetUIObject(item_temp, item_parent)
            item_data = SpecMgrs.data_mgr:GetItemData(item_id)
            ui:AssignSpriteByIconID(item_data.icon, go:FindChild("Frame/Icon"):GetComponent("Image"))
            local text_comp = go:FindChild("Frame/Text"):GetComponent("Text")
            if not ui._item_to_text_list[item_id] then ui._item_to_text_list[item_id] = {} end
            table.insert(ui._item_to_text_list[item_id], text_comp)
            UIFuncs.RegisterUpdateItemNumFunc(ui, panel_name .. "TopBar" .. item_id, function(num)
                text_comp.text = UIFuncs.GetItemNumStr(item_id)
            end, item_id)
        end
    end
    if content_data.is_show_combat then
        local go = ui:GetUIObject(item_temp, item_parent)
        ui:AssignSpriteByIconID(UIConst.Icon.Combat, go:FindChild("Frame/Icon"):GetComponent("Image"))
        local text_comp = go:FindChild("Frame/Text"):GetComponent("Text")
        UIFuncs.RegisterUpdateBattlePoint(ui, ui.class_name .. "TopBar", text_comp)
    end
end

function UIFuncs.UpdateCurrencyItemNum(item_text_list, currency)
    if not item_text_list or not currency then return end
    for item_id, num in pairs(currency) do
        if item_text_list[item_id] then
            for _, text_comp in ipairs(item_text_list[item_id]) do
                text_comp.text = UIFuncs.GetItemNumStr(item_id, num)
            end
        end
    end
end

function UIFuncs.GetItemNumStr(item_id, item_num)
    item_num = item_num or ComMgrs.dy_data_mgr:ExGetItemCount(item_id)
    if table.contains(CSConst.CostValueItem, item_id) then
        local item_limit = ComMgrs.dy_data_mgr:ExGetMaxCostValue(item_id)
        return string.format(UIConst.Text.SPRIT, item_num, item_limit)
    end
    return UIFuncs.AddCountUnit(item_num)
end

function UIFuncs.UpdateBagItemNum(item_text_list, item_data)
    if not item_text_list[item_data.item_id] then return end
    for _, text_comp in ipairs(item_text_list[item_data.item_id]) do
        text_comp.text = UIFuncs.AddCountUnit(item_data.count)
    end
end

-- 显示奖励ui
function UIFuncs.ShowGetRewardItem(reward_id, is_merge)
    local item_list = ItemUtil.GetSortedRewardItemList(reward_id, is_merge)
    SpecMgrs.ui_mgr:ShowUI("GetItemUI", item_list)
end

function UIFuncs.ShowGetRewardItemByItemDict(item_dict, is_sort, sort_func)
    local is_sort = is_sort == nil or is_sort
    local item_list = ItemUtil.ItemDictToItemDataList(item_dict, is_sort, sort_func)
    SpecMgrs.ui_mgr:ShowUI("GetItemUI", item_list)
end

function UIFuncs.ShowGetRewardItemByItemList(item_list)
    local list = table.deepcopy(item_list)
    list = ItemUtil.SortRoleItemList(list, true)
    SpecMgrs.ui_mgr:ShowUI("GetItemUI", list)
end

function UIFuncs.GetRoleItemList(item_id_list, item_count_list)
    local ret = {}
    for i,v in ipairs(item_id_list) do
        table.insert(ret, {item_id = v, count = item_count_list[i]})
    end
    return ret
end

function UIFuncs.SetItem(ui, item_id, count, content, click_cb)
    local param_tb = {
        ui = ui,
        parent = content,
        item_id = item_id,
        count = count,
        click_cb = click_cb,
        size = content:GetComponent("RectTransform").sizeDelta
    }
    local item = UIFuncs.GetInitItemGoByTb(param_tb)
    item:GetComponent("RectTransform").anchoredPosition = Vector3.zero
    return item
end

function UIFuncs.SetItemList(ui, role_item_list, content, not_sort)
    local ret = {}
    local list = table.deepcopy(role_item_list)
    if not not_sort then
        role_item_list = ItemUtil.SortRoleItemList(list, true)
    end
    for i = #role_item_list, 1, -1 do
        local data = role_item_list[i]
        local param_tb = {
            ui = ui,
            parent = content,
            item_id = data.item_id,
            count = data.count,
        }
        local item = UIFuncs.GetInitItemGoByTb(param_tb)
        table.insert(ret, item)
    end
    return ret
end

function UIFuncs.GetServerName(serv_id)
    local server_data = SpecMgrs.data_mgr:GetServerData(serv_id)
    return server_data.name
end

function UIFuncs.AddGlodCircleEffect(ui, go)
    return UIFuncs.AddEffect(ui, go, SpecMgrs.data_mgr:GetParamData("glod_circle").effect_id)
end

function UIFuncs.AddSelectEffect(ui, go)
    return UIFuncs.AddEffect(ui, go, SpecMgrs.data_mgr:GetParamData("select_effect").effect_id)
end

function UIFuncs.AddCompleteEffect(ui, go)
    return UIFuncs.AddEffect(ui, go, SpecMgrs.data_mgr:GetParamData("complete_effect").effect_id)
end

function UIFuncs.AddEffect(ui, go, effect_id)
    local param_tb = {
        attach_ui_go = go,
        effect_id = effect_id,
        offset_tb = {0, 0, 0, 0},
        need_sync_load = true,
    }
    local effect = ui:AddUIEffect(go, param_tb)
    return effect
end

function UIFuncs.GetHeroTalk(hero_id, index)
    local hero_data = SpecMgrs.data_mgr:GetHeroData(hero_id)
    if hero_data.talk_list then
        index = index or math.random(1, #hero_data.talk_list)
        return hero_data.talk_list[index], hero_data.talk_list
    end
end

-- 宝箱生成方法
function UIFuncs.GetTreasureBox(ui, parent, treasure_box_id)
    local prefab = UIFuncs.GetTreasureBoxPrafab(ui, treasure_box_id)
    local treasure_box = ui:GetUIObject(prefab, parent)
    treasure_box.name = "treasure_box"
    return treasure_box
end

function UIFuncs.GetTreasureBoxPrafab(ui, treasure_box_id)
    if not ui._treasure_prefab_dict then ui._treasure_prefab_dict = {} end
    if not ui._treasure_prefab_dict[treasure_box_id] then
        treasure_box_id = treasure_box_id or SpecMgrs.data_mgr:GetParamData("default_treasure_box").treasure_box_id
        local path = SpecMgrs.data_mgr:GetTreasureBoxData(treasure_box_id).path
        ui._treasure_prefab_dict[treasure_box_id] = SpecMgrs.res_mgr:GetPrefabSync(path)
    end
    return ui._treasure_prefab_dict[treasure_box_id]
end

-- nil 已领取 true 可领取 false 不能领取
function UIFuncs.UpdateTreasureBoxStatus(go, is_treasure_can_get)
    if not go.activeInHierarchy then return end -- 动画机在隐藏情况下将不更新状态
    local animator = go:GetComponent("Animator")
    if is_treasure_can_get == true then
        animator:Play("treasure_box_unlock", -1, 0)
    elseif is_treasure_can_get == false then
        animator:Play("treasure_box_lock", -1, 0)
    else
        animator:Play("treasure_box_already_get", -1, 0)
    end
end

function UIFuncs.PlayOpenBoxAnim(go)
    if not go.activeInHierarchy then return end -- 动画机在隐藏情况下将不更新状态
    local animator = go:GetComponent("Animator")
    animator:Play("treasure_box_already_get")
end

function UIFuncs.ShowTreasurePreview(param, reward_state, confirm_cb)
    local data = {
        confirm_cb = confirm_cb,
        title = UIConst.Text.TREASURE_PREVIEW_TITLE,
        desc = UIConst.Text.TREASURE_PREVIEW_DESC,
        reward_state = reward_state
    }
    if type(param) == "number" then
        data.reward_id = param
    elseif type(param) == "table" then
        data.item_list = param
    end
    SpecMgrs.ui_mgr:ShowUI("RewardPreviewUI", data)
end

function UIFuncs.TransRewardState(is_can_pick)
    if is_can_pick == false then
        return CSConst.RewardState.unpick
    elseif is_can_pick == true then
        return CSConst.RewardState.pick
    else
        return CSConst.RewardState.picked
    end
end

function UIFuncs.CalculateTreasureSliderValue(progress, progress_list)
    if progress <= 0 then return 0 end
    local ret_value
    local max_count = #progress_list
    for i, compare_grpgress in ipairs(progress_list) do
        if progress < compare_grpgress then
            local prev_index = i - 1
            local prev_progress = progress_list[prev_index] or 0
            if prev_index == 0 then
                ret_value = progress / compare_grpgress / max_count
            else
                ret_value = prev_index / max_count + (progress - prev_progress)/ (compare_grpgress - prev_progress) / max_count
            end
            break
        end
    end
    return ret_value or 1
end

-- 数量不够显示红色的 1/5, 数量够显示绿色，是不是足够自己传
function UIFuncs.GetPerStr(first_num, second_num, is_enough)
    if is_enough == nil then
        is_enough = first_num >= second_num
    end
    local format = is_enough and UIConst.Text.GREEN_PRE_VALUE or UIConst.Text.RED_PRE_VALUE
    first_num = UIFuncs.AddCountUnit(first_num)
    second_num = UIFuncs.AddCountUnit(second_num)
    return string.format(format, first_num, second_num)
end

-- 宝箱生成方法  end

function UIFuncs.GetHeroSpellDesc(hero_id, spell_data, destiny_lv, is_change_color)
    local ret_str
    local destiny_addition = ""
    if destiny_lv then
        if destiny_lv > 1 and spell_data.hurt_grow_rate > 0 then
            destiny_addition = string.format(UIConst.Text.DESTINY_ADDITION, spell_data.hurt_grow_rate * (destiny_lv - 1))
        end
    end
    ret_str = string.gsub(spell_data.desc, "$destiny", destiny_addition)
    local spell_active_flag = true
    if spell_data.spell_unit then
        local unit_id = SpecMgrs.data_mgr:GetHeroData(hero_id).unit_id
        local hero_name_str
        if unit_id ~= spell_data.spell_unit then
            hero_name_str = SpecMgrs.data_mgr:GetUnitData(spell_data.spell_unit).name
        end
        for _, hero_unit in ipairs(spell_data.spell_unit_list) do
            if unit_id ~= hero_unit then
                local unit_name = SpecMgrs.data_mgr:GetUnitData(hero_unit).name
                hero_name_str = hero_name_str and string.format(UIConst.Text.AND_VALUE, hero_name_str, unit_name) or unit_name
            end
            if not ComMgrs.dy_data_mgr.night_club_data:CheckHeroIsLineUp(hero_unit) then
                spell_active_flag = false
            end
        end
        if not ComMgrs.dy_data_mgr.night_club_data:CheckHeroIsLineUp(spell_data.spell_unit) then
            spell_active_flag = false
        end
        ret_str = string.gsub(ret_str, "$unit", hero_name_str)
    end
    if is_change_color then
        local spell_color = spell_active_flag and UIConst.Color.ActiveColor or UIConst.Color.UnactiveColor
        local spell_format = spell_active_flag and UIConst.Text.SPELL_TEXT_FORMAT or UIConst.Text.UNACTIVE_SPELL_TEXT_FORMAT
        local desc = string.format(spell_format, spell_data.name, ret_str)
        ret_str = string.format(UIConst.Text.SIMPLE_COLOR, spell_color, desc)
    else
        ret_str = string.format(UIConst.Text.SPELL_TEXT_FORMAT, spell_data.name, ret_str)
    end
    return ret_str
end

function UIFuncs.GetPerfectMapScale(is_scale_by_width)
    local perfect_size = SpecMgrs.data_mgr:GetParamData("perfect_map_size").tb_int
    local scale = is_scale_by_width and Screen.width / perfect_size[1] or Screen.height / perfect_size[2]
    local range_of_map_scale = SpecMgrs.data_mgr:GetParamData("map_scale_range").tb_float
    scale = math.clamp(scale, range_of_map_scale[1], range_of_map_scale[2])
    return Vector3.New(scale, scale, 1)
end

--  购买商品
function UIFuncs.ShowBuyShopItemUI(item_id, item_count, max_buy_time, price_list, confirm_cb, limit_day_buy_time, already_buy_time, discount_num_list, discount_list)
    for i, price in ipairs(price_list) do
        local need_price = UIFuncs.GetPrice(price.count, 1, already_buy_time, discount_num_list, discount_list)
        if not UIFuncs.CheckItemCount(price.item_id, need_price, true) then return end
    end
    local param_tb = {
        item_id = item_id,
        item_count = item_count,
        max_buy_time = max_buy_time,
        price_list = price_list,
        confirm_cb = confirm_cb,
        limit_day_buy_time = limit_day_buy_time,
        already_buy_time = already_buy_time,
        discount_num_list = discount_num_list, -- 购买次数列表
        discount_list = discount_list,  -- 购买折扣列表
    }
    SpecMgrs.ui_mgr:ShowUI("BuyShopItemUI", param_tb)
end

--  阶梯折扣获取价格
function UIFuncs.GetPrice(price, buy_time, already_buy_time, discount_num_list, discount_list)
    if not discount_num_list then
        return buy_time * price
    else
        local ret = 0
        for i = 1, buy_time do
            local buy_time = already_buy_time + i
            for j = 1, #discount_num_list do
                buy_time = buy_time - discount_num_list[j]
                local cur_price
                if buy_time <= 0 then
                    cur_price = price * discount_list[j]
                elseif j == #discount_num_list then
                    cur_price = price
                end
                if cur_price then
                    ret = ret + math.ceil(cur_price)
                    break
                end
            end
        end
        return ret
    end
end

function UIFuncs.GetUnlockIdVipLevel(id)
    local need_vip = SpecMgrs.data_mgr:GetFuncUnlockData(id).vip
    return need_vip 
end

function UIFuncs.SetVipImage(obj, vip_level)
    local vip = vip_level or ComMgrs.dy_data_mgr.vip_data:GetVipLevel()
    local vip_data = SpecMgrs.data_mgr:GetVipData(vip)
    UIFuncs.AssignSpriteByIconID(vip_data.icon, obj:GetComponent("Image"))
end

function UIFuncs.HideItemRecive(item)
    item:FindChild("ReceiveBtn"):SetActive(false)
    item:FindChild("AlreadyRecive"):SetActive(false)
end

--  领取  已领取
function UIFuncs.SetItemCanRecive(ui, item, have_recive)
    local recive_btn = item:FindChild("ReceiveBtn")
    local already_recive = item:FindChild("AlreadyRecive")
    if have_recive then
        recive_btn:SetActive(false)
        already_recive:SetActive(true)
        already_recive:FindChild("Text"):GetComponent("Text").text = UIConst.Text.ALREADY_RECEIVE_TEXT
    else
        recive_btn:SetActive(true)
        already_recive:SetActive(false)
        recive_btn:FindChild("Text"):GetComponent("Text").text = UIConst.Text.RECEIVE_TEXT
        ui:RemoveUIEffect(recive_btn)
        UIFuncs.AddCompleteEffect(ui, recive_btn)
    end
end

function UIFuncs.SetButtonCanClick(go, can_click)
    local btn_cmp = go:GetComponent("Button")
    if not btn_cmp then
        PrintError("not btn cmp")
        return
    else
        btn_cmp.interactable = can_click
    end
    local gray_image = go:FindChild("GrayImage")
    if gray_image then
        gray_image:SetActive(not can_click)
    end
end

function UIFuncs.GetShopNameByShopType(shop_type)
    return SpecMgrs.data_mgr:GetShopData(shop_type).shop_name
end
-- 0.1 => 10%off
function UIFuncs.GetDiscountStr(discount)
    discount = math.floor(discount * 100)
    return string.format(UIConst.Text.DISCOUNT_TEXT1, discount)
end

function UIFuncs.GetFuncLockTipStr(func_unlock_id)
    local data = SpecMgrs.data_mgr:GetFuncUnlockData(func_unlock_id)
    if data.unlock_desc then return data.unlock_desc end
    local tip_str
    local func_name = data.name
    if data.unlock_type == CSConst.FuncUnlockType.Level then
        tip_str = string.format(UIConst.Text.LEVEL_UNLOCK_FORMAT, func_name, data.level)
    elseif data.unlock_type == CSConst.FuncUnlockType.Vip then
        tip_str = string.format(UIConst.Text.VIP_UNLOCK_FORMAT, func_name, data.level)
    elseif data.unlock_type == CSConst.FuncUnlockType.VipOrLevel then
        tip_str = string.format(UIConst.Text.LEVEL_OR_LEVEL_UNLOCK_FORMAT, func_name, data.vip, data.level)
    end
    tip_str = tip_str or UIConst.Text.FUNC_NOT_OPEN
    return tip_str
end

function UIFuncs.GetCastItemStr(item_dict, func_str, item_count_format, separator)
    local itme_count_str = UIFuncs.GetConnectItemCountStr(item_dict, item_count_format, separator)
    return string.format(UIConst.Text.UES_ITEM_DESC, itme_count_str, func_str or "")
end

function UIFuncs.GetConnectItemCountStr(item_dict, item_count_format, separator)
    local item_data_list = ItemUtil.ItemDictToItemDataList(item_dict, true)
    item_count_format = item_count_format or UIConst.Text.ITEM_X_COUNT
    separator = separator or UIConst.Text.DEFAULT_SEPARATOR
    local item_str_list = {}
    for i, data in ipairs(item_data_list) do
        table.insert(item_str_list, string.format(item_count_format, data.item_data.name, data.count))
    end
    return table.concat(item_str_list, separator)
end

-- 添加换行
function UIFuncs.MergeStrList(str_list)
    return table.concat(str_list, "\n")
end

-- 添加首行缩进
function UIFuncs.AddFirstLineIndentation(text)
    return "\u{00A0}\u{00A0}\u{00A0}\u{00A0}" .. text
end

--  钻石x100
function UIFuncs.GetItemXCountStr(item_id, count)
    local item_data = SpecMgrs.data_mgr:GetItemData(item_id)
    return string.format(UIConst.Text.ITEM_X_COUNT, item_data.name, count)
end

function UIFuncs.Format(str, param_list)
    local ret_str = str
    for i, param in ipairs(param_list) do
        ret_str = string.gsub(ret_str, "{" .. i .. "}", param)
    end
    return ret_str
end

-- 返回英雄加上突破前后缀后的名字
function UIFuncs.GetHeroName(hero_id, break_lv)
    local hero_basic_data = SpecMgrs.data_mgr:GetHeroData(hero_id)
    local hero_break_lv = break_lv
    if not hero_break_lv then
        local hero_info = ComMgrs.dy_data_mgr.night_club_data:GetHeroDataById(hero_id)
        hero_break_lv = hero_info and hero_info.break_lv
    end
    local hero_break_data = SpecMgrs.data_mgr:GetHeroBreakLvData(hero_break_lv)
    if not hero_break_data then return hero_basic_data.name end
    local ret_name = (hero_break_data.profix or "") .. string.format(UIConst.Text.NAME_WITH_BREAK_LV, hero_basic_data.name, hero_break_lv)
    return ret_name
end

return UIFuncs