local AppUtils = DECLARE_MODULE("BaseUtilities.AppUtils")

function AppUtils.GetNetWorkState()
    return NativeAppUtils.GetNetWorkState()
end

function AppUtils.GetBatteryPercentage()
    return NativeAppUtils.GetBatteryPercentage()
end

return AppUtils