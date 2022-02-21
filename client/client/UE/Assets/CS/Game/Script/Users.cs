public class Users
{
    public string gameRoleBalance;
    public string gameRoleID;
    public string gameRoleLevel;
    public string gameRoleName;
    public string partyName;
    public string serverID;
    public string serverName;
    public string vipLevel;
    public string roleCreateTime;     //UC与1881渠道必传，值为10位数时间戳
    public string gameRoleGender;     //360渠道参数
    public string gameRolePower;      //360渠道参数，设置角色战力，必须为整型字符串
    public string partyId;            //360渠道参数，设置帮派id，必须为整型字符串
    public string professionId;       //360渠道参数，设置角色职业id，必须为整型字符串
    public string profession;         //360渠道参数，设置角色职业名称
    public string partyRoleId;        //360渠道参数，设置角色在帮派中的id
    public string partyRoleName;      //360渠道参数，设置角色在帮派中的名称
    public string friendlist;         //360渠道参数，设置好友关系列表，格式请参考：http://open.quicksdk.net/help/detail/aid/190
}