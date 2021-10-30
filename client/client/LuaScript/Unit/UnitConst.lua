local UnitConst = DECLARE_MODULE("Unit.UnitConst")

-- 动画相关
UnitConst.ANIM_Idle = "idle"
UnitConst.ANIM_Walk = "walk"
UnitConst.ANIM_Death = "die"

UnitConst.ANIM_BlendTime = 0.15

-- 角色信息类型
UnitConst.UNITINFO_TYPE = {
    Name = 1,           --名字
    BloodBar = 2,       --血条
    Anger = 3,          --怒气
}

-- 战斗飘字类型
UnitConst.UNITHUD_TYPE = {
    Hurt = 1,           --普通伤害
    HurtCritical = 2,   --暴击伤害
    Combo = 3,          --连击
    TotalHurt = 4,      --总伤害
    Cure = 5,           --治疗
    Spell = 6,          --技能
    Miss = 7,
    TotalCure = 8,      --总治疗
    ImmediatelyKill = 9, -- 秒杀
    InvalidBuff = 10,   -- 抵抗
}

UnitConst.UnitRect = {
    Head = "head",
    Card = "card",      -- 卡牌半身
    Half = "half",    -- 全上半身
    Full = "full",
}

UnitConst.MaterialGrayPath = "Material/Spine/SkeletonGraphicGray"
UnitConst.MaterialDefaultPath = "Material/Spine/SkeletonGraphicDefault"

return UnitConst