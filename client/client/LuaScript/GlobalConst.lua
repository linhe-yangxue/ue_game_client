local M = {
    DefaultLayer = "Default",
    UILayer = "UI",
    UnitLayer = "Unit",
    HideLayer = "Hide",
    EffectLayer = "Effect",

    ConnectStatus = {
        STATUS_Init = 1,
        STATUS_BeginConnect = 2,
        STATUS_Connected = 3,
        STATUS_Disconnected = 4,
        STATUS_Closed = 5,
        STATUS_Failed = 9,
    },
    CONNECT_TimeOutSecond = 5,
    HeartBreakTime = 2, --心跳间隔
    NetFailed = {
        TCP_Connect_Failed = 1,
        TCP_Connect_Timeout = 2,
        TCP_Receive_Disconnect = 3,
    },
}

M.ConfigParamType = {
    t_bool = 1,
    t_int = 2,
    t_string = 3,
    t_float = 4,
}

M.Config = {
    --1:bool 2:int 3:string 4:float
    -- 音效相关
    SOUND_STATE = "1_SOUND_STATE",
    AUDIO_STATE = "1_AUDIO_STATE",
    VOLUME_VALUE = "4_VOLUME_VALUE",
    BGM_VOLUME_VALUE = "4_BGM_VOLUME_VALUE",
    SFX_VOLUME_VALUE = "4_SFX_VOLUME_VALUE",
}

M.SortingLayer = {
    Default = "Default",
    Bg = "Bg",
    DynamicBgItem = "DynamicBgItem",
    UI = "UI",
    EffectUI = "EffectUI",
}

return M


