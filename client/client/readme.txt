初始化：
svnr config配置reviewboard的账号和密码
提交流程：
1.把文件放到changelist中，如名字叫testchangename的changelist
2.svnr pr testchangename
3.然后在生成的reviewboard页面上填写单子和发给相关人员review
4.等相关人员review完成
5.svnr ci testchangename

test


    








