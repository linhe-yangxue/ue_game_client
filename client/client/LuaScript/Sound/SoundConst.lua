local GConst = require("GlobalConst")
local SoundConst = DECLARE_MODULE("Sound.SoundConst")

SoundConst.SoundType = {
	BGM = 1,           --背景音乐 循环播放
	SFX = 2,              --音效
}

SoundConst.Config = {
    [SoundConst.SoundType.BGM] = GConst.Config.BGM_VOLUME_VALUE,
    [SoundConst.SoundType.SFX] = GConst.Config.SFX_VOLUME_VALUE,
}

SoundConst.SOUND_TEMP_ID_BGM = 1
SoundConst.SOUND_TEMP_ID_SFX = 2

SoundConst.SOUND_ID_Login = "1"
SoundConst.SOUND_ID_MainScene = "2"
SoundConst.SOUND_ID_Fight = "3"
SoundConst.SOUND_ID_Entertainment = "4"
SoundConst.SOUND_ID_BigMap = "5"
SoundConst.SOUND_ID_Guide = "6"
SoundConst.SOUND_ID_Prison = "7"
SoundConst.SOUND_ID_CityStage = "8"
SoundConst.SOUND_ID_DareTower = "9"
SoundConst.SOUND_ID_Arena = "10"
SoundConst.SOUND_ID_Hunting = "11"
SoundConst.SOUND_ID_Cutscene = "12"
SoundConst.SOUND_ID_CreateRole = "13"

SoundConst.SoundID = {
    SID_NotPlaySound = "0",        -- 不播放音效
    SID_DefaultClick = "201",      -- 默认点击音效
    SID_BagBtnClick = "201",       -- 背包按钮音效
    SID_LoginBtnClick = "201",     -- 登陆按钮音效
    SID_SecondBtnClick = "201",    -- 二级按钮音效
    SID_FirstBtnClick = "201",     -- 一级按钮音效 进入对应系统
    SID_CloseBtnClick = "201",     -- 关闭按钮音效
}

SoundConst.SoundTag = {
    Spell = 1,        -- 不播放音效
}

return SoundConst