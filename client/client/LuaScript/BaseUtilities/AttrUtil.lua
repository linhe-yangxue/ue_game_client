local CSConst = require("CSCommon.CSConst")
local AttrUtil = DECLARE_MODULE("BaseUtilities.AttrUtil")
local CSFunction = require("CSCommon.CSFunction")

function AttrUtil.GetEquipAttrDict(guid)
    local equip_data = ComMgrs.dy_data_mgr.bag_data:GetBagItemDataByGuid(guid)
    return CSFunction.get_equip_all_attr(equip_data)
end

function AttrUtil.GetSortedEquipAttrList(guid)
    local attr_dict = AttrUtil.GetEquipAttrDict(guid)
    local attr_list = {}
    local all_attr_data = SpecMgrs.data_mgr:GetAllAttributeData()
    for k, v in pairs(attr_dict) do
        table.insert(attr_list, {attr_key = k, attr_num = v})
    end
    table.sort(attr_list, function (tb1, tb2)
        local order1 = all_attr_data[tb1.attr_key].order or 0
        local order2 = all_attr_data[tb2.attr_key].order or 0
        return order1 > order2
    end)
    return attr_list
end

function AttrUtil.ConvertAttrDictToList(attr_dict)
    local attr_list = {}
    for attr, value in pairs(attr_dict) do
        table.insert(attr_list, {attr = attr, value = value})
    end
    table.sort(attr_list, function (data1, data2)
        local order1 = SpecMgrs.data_mgr:GetAttributeData(data1.attr).order
        local order2 = SpecMgrs.data_mgr:GetAttributeData(data2.attr).order
        return order1 > order2
    end)
    return attr_list
end

-- 计算四属性总和
function AttrUtil.CalcTotalAttr(attr_dict)
    local total_attr = 0
    for _, attr in pairs(CSConst.RoleAttrName) do
        total_attr = total_attr + attr_dict[attr]
    end
    return total_attr
end

return AttrUtil