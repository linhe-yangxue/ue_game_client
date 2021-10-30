#import "UnityAppController.h"

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AdSupport/ASIdentifierManager.h>

#import "GAEAPlatform.h"
#import "GATA.h"


#ifndef __cplusplus
#define __cplusplus
#endif


@interface UnityAppController ()
@end

// ------------------------------------------------
// C接口
// ------------------------------------------------
#if defined(__cplusplus)
extern "C"{
#endif
    // ------------------------------------------------
    // 通用函数
    // ------------------------------------------------
    NSString* _CStringToNSString (const char* string)
    {
        if (string)
            return [NSString stringWithUTF8String: string];
        else
            return [NSString stringWithUTF8String: ""];
    }
    char* _CopyCString(const char* string)
    {
        if (NULL == string) {
            return NULL;
        }
        char* res = (char*)malloc(strlen(string)+1);
        strcpy(res, string);
        return res;
    }
    //json字符串转字典
    NSMutableDictionary* JsonStringToDict(NSString* json_str) {
        NSData* data = [json_str dataUsingEncoding:NSUTF8StringEncoding];
        NSError* err;
        NSMutableDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
        if (err) @throw [NSException exceptionWithName:@"json error" reason:[err localizedDescription] userInfo:nil];
        return json;
    }
    // 字典转json字符串
    NSString* JsonDictToString(NSMutableDictionary* json) {
        NSError* err;
        NSData* data = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:&err];
        if (err) @throw [NSException exceptionWithName:@"json error" reason:[err localizedDescription] userInfo:nil];
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    NSMutableDictionary* _GetParam(const char* cstr)
    {
        NSString* str = _CStringToNSString(cstr);
        return JsonStringToDict(str);
    }
    void _SendToUnity(NSString* func_name, NSMutableDictionary* param){
        NSString* str = JsonDictToString(param);
        UnitySendMessage("GameEntry", [func_name UTF8String], [str UTF8String]);
    }
    void _CallLua(NSString* func_name, NSMutableDictionary* param)
    {
        NSMutableDictionary* json = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                     func_name, @"func_name",
                                     param, @"param", nil];
        _SendToUnity(@"CallLua", json);
    }
    void _CatchError(NSException *exception){
        NSString* type = [NSString stringWithFormat:@"%@", [exception name]];
        NSString* err = [NSString stringWithFormat:@"%@ stack:%@", [exception reason], [NSThread callStackSymbols]];
        
        NSMutableDictionary* json = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                     type, @"type",
                                     err, @"err", nil];
        _SendToUnity(@"CatchError", json);
    }
    void Log(NSString* str)
    {
	    NSMutableDictionary* dic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
									    str, @"str", nil];
       _CallLua(@"IOSLog", dic);
    }

    // ------------------------------------------------
    // Gaea
    // ------------------------------------------------
    void GaeaInit(const char* json_str) {
        @try {
            [GAEAPlatform initWithGameId:@"510048"
                 completionHandler:^(BOOL success, NSString *message) {
                     NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
                     [result setValue:@(success) forKey:@"success"];
                     [result setValue:message forKey:@"message"];
                     _CallLua(@"GaeaInitResult", result);
                 }
            ];
        } @catch (NSException *exception) {
            _CatchError(exception);
        }
    }

    void GaeaLogin(const char* json_str) {
        @try {
            [GAEAPlatform showLoginSystemWithCompletionHandler:^(NSDictionary *userInfo) {
                _CallLua(@"GaeaLoginResult", userInfo);
            }];
        } @catch (NSException *exception) {
            _CatchError(exception);
        }
    }

    void GaeaPay(const char* json_str) {
        @try {
            NSMutableDictionary* param = _GetParam(json_str);
            [GAEAPlatform purchaseWithProductId:[param objectForKey:@"productId"] 
                           serverId:[param objectForKey:@"serverId"] 
                             payExt:[param objectForKey:@"payExt"] 
                  completionHandler:^(BOOL success, NSString *message) {
                      NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
                      [result setValue:@(success) forKey:@"success"];
                      [result setValue:message forKey:@"message"];
                      _CallLua(@"GaeaPayResult", result);
            }];
        } @catch (NSException *exception) {
            _CatchError(exception);
        }
    }

    void GaeaUserCenter(const char* json_str) {
        @try {
            Log(_CStringToNSString(json_str));
            NSMutableDictionary* param = _GetParam(json_str);
            [GAEAPlatform showGaeaUserCenterWithServerId:[param objectForKey:@"serverId"]
                                                  roleId:[param objectForKey:@"roleId"]
            ];
        } @catch (NSException *exception) {
            _CatchError(exception);
        }
    }

    void GaeaForum(const char* json_str) {
        @try {
            Log(_CStringToNSString(json_str));
            NSMutableDictionary* param = _GetParam(json_str);
            Log([param objectForKey:@"roleId"]);
            Log([param objectForKey:@"roleName"]);
            [GAEAPlatform showGaeaForumWithRoleId:[param objectForKey:@"roleId"]
                                         roleName:[param objectForKey:@"roleName"]
            ];
        } @catch (NSException *exception) {
            _CatchError(exception);
        }
    }

    void GaeaService(const char* json_str) {
        @try {
            Log(_CStringToNSString(json_str));
            NSMutableDictionary* param = _GetParam(json_str);
            Log([param objectForKey:@"serverId"]);
            Log([param objectForKey:@"roleId"]);
            Log([param objectForKey:@"roleName"]);
            [GAEAPlatform showGaeaCustomerServiceWithServerId:[param objectForKey:@"serverId"]
                                                       roleId:[param objectForKey:@"roleId"]
                                                     roleName:[param objectForKey:@"roleName"]
            ];
        } @catch (NSException *exception) {
            _CatchError(exception);
        }
    }

    // ------------------------------------------------
    // GATA
    // ------------------------------------------------
    void GataInit(const char* json_str) {
        @try {
            NSMutableDictionary* param = _GetParam(json_str);
            [GATA setRegion:GATARegionChina];
            [GATA startWithAppID:[param objectForKey:@"appId"]
                         channel:[param objectForKey:@"channel"]
            ];
        } @catch (NSException *exception) {
            _CatchError(exception);
        }
    }

    void GataLogEvent1(const char* json_str) {
        @try {
            NSMutableDictionary* param = _GetParam(json_str);
            [GATA logEvent:[param objectForKey:@"eventName"]
            ];
        } @catch (NSException *exception) {
            _CatchError(exception);
        }
    }

    void GataLogEvent2(const char* json_str) {
        @try {
            NSMutableDictionary* param = _GetParam(json_str);
            [GATA logEvent:[param objectForKey:@"eventName"]
                   content:[param objectForKey:@"content"]
            ];
        } @catch (NSException *exception) {
            _CatchError(exception);
        }
    }

    void GataLogEvent3(const char* json_str) {
        @try {
            NSMutableDictionary* param = _GetParam(json_str);
            [GATA logEvent:[param objectForKey:@"eventName"]
                parameters:param
            ];
        } @catch (NSException *exception) {
            _CatchError(exception);
        }
    }

    void GataUserLogin(const char* json_str) {
        @try {
            NSMutableDictionary* param = _GetParam(json_str);
            [GATA gaeaLoginWithUserId:[param objectForKey:@"userId"]
            ];
        } @catch (NSException *exception) {
            _CatchError(exception);
        }
    }

    void GataRoleCreate(const char* json_str) {
        @try {
            NSMutableDictionary* param = _GetParam(json_str);
            [GATA roleCreateWithRoleId:[param objectForKey:@"roleId"]
                              serverId:[param objectForKey:@"serverId"]
            ];
        } @catch (NSException *exception) {
            _CatchError(exception);
        }
    }

    void GataRoleLogin(const char* json_str) {
        @try {
            NSMutableDictionary* param = _GetParam(json_str);
            [GATA roleLoginWithRoleId:[param objectForKey:@"roleId"]
                             serverId:[param objectForKey:@"serverId"]
                                level:[[param objectForKey:@"level"] intValue]
            ];
        } @catch (NSException *exception) {
            _CatchError(exception);
        }
    }

    void GataRoleLogout(const char* json_str) {
        @try {
            [GATA roleLogout];
        } @catch (NSException *exception) {
            _CatchError(exception);
        }
    }
    
    void GataSetLevel(const char* json_str) {
        @try {
            NSMutableDictionary* param = _GetParam(json_str);
            [GATA setLevel:[[param objectForKey:@"level"] intValue]];
        } @catch (NSException *exception) {
            _CatchError(exception);
        }
    }

    void GataSetCrashReportingEnabled(const char* json_str) {
        @try {
            NSMutableDictionary* param = _GetParam(json_str);
            [GATA setCrashReportingEnabled:[[param objectForKey:@"enabled"] boolValue]];
        } @catch (NSException *exception) {
            _CatchError(exception);
        }
    }

    void GataLogError(const char* json_str) {
        @try {
            NSMutableDictionary* param = _GetParam(json_str);
            [GATA logError:[param objectForKey:@"error"]];
        } @catch (NSException *exception) {
            _CatchError(exception);
        }
    }

    void GataLogLocation(const char* json_str) {
        @try {
            NSMutableDictionary* param = _GetParam(json_str);
            [GATA setLatitude:[[param objectForKey:@"latitude"] doubleValue]
                    longitude:[[param objectForKey:@"longitude"] doubleValue]
            ];
        } @catch (NSException *exception) {
            _CatchError(exception);
        }
    }

    char* GataGetDeviceInfo(const char* json_str) {
        @try {
            NSMutableDictionary* result = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                [ASIdentifierManager sharedManager].advertisingIdentifier.UUIDString, @"deviceId",
                [ASIdentifierManager sharedManager].advertisingIdentifier.UUIDString, @"deviceId1",
                [[[UIDevice currentDevice] identifierForVendor] UUIDString], @"deviceId2",
                nil];
            return _CopyCString([JsonDictToString(result) UTF8String]);
        } @catch (NSException *exception) {
            _CatchError(exception);
            return _CopyCString([@"" UTF8String]);
        }
    }
    // ------------------------------------------------
    // 常用功能
    // ------------------------------------------------
    char* EchoTest(const char* json_str)
    {
        @try {
            NSMutableDictionary* param = _GetParam(json_str);
            NSString* str = JsonDictToString(param);
            Log(str);
            return _CopyCString([str UTF8String]);
        } @catch (NSException *exception) {
            _CatchError(exception);
            return _CopyCString([@"" UTF8String]);
        }
    }

    void SetClipboard(const char* json_str)
    {
        @try {
            NSMutableDictionary* param = _GetParam(json_str);
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = [param objectForKey:@"str"];
        } @catch (NSException *exception) {
            _CatchError(exception);
        }
    }

    char* GetClipboard(const char* json_str)
    {
        @try {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            NSMutableDictionary* result = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                pasteboard.string, @"str",
                nil];
            return _CopyCString([JsonDictToString(result) UTF8String]);
        } @catch (NSException *exception) {
            _CatchError(exception);
            return _CopyCString([@"" UTF8String]);
        }
    }

    char* GetBatteryState(const char* json_str)
    {
        @try {
            UIDevice *myDevice = [UIDevice currentDevice];
            [myDevice setBatteryMonitoringEnabled:YES];
            float level = [myDevice batteryLevel] * 100;
            UIDeviceBatteryState status = [myDevice batteryState];
            NSMutableDictionary* result = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                [NSNumber numberWithFloat:level], @"level",
                [NSNumber numberWithInt:status], @"status",
                nil];
            return _CopyCString([JsonDictToString(result) UTF8String]);
        } @catch (NSException *exception) {
            _CatchError(exception);
            return _CopyCString([@"" UTF8String]);
        }
    }

    
#if defined(__cplusplus)
}
#endif


// ------------------------------------------------
// 改写UnityAppController
// ------------------------------------------------
@interface CustomAppController : UnityAppController
@end

IMPL_APP_CONTROLLER_SUBCLASS (CustomAppController)

@implementation CustomAppController

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSMutableDictionary*)launchOptions
{
    [super application:application didFinishLaunchingWithOptions:launchOptions];

    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    return [GAEAPlatform handleOpenUrl:url 
                           application:application 
                     sourceApplication:[options           objectForKey:UIApplicationOpenURLOptionsSourceApplicationKey]];
}

// gaea 额外要求
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
     if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
       return UIInterfaceOrientationMaskAll;
     } else {
       return UIInterfaceOrientationMaskAllButUpsideDown;
    }
}

@end
