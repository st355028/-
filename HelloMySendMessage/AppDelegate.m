//
//  AppDelegate.m
//  HelloMySendMessage
//
//  Created by MinYeh on 2016/6/17.
//  Copyright © 2016年 MINYEH. All rights reserved.
//

#import "AppDelegate.h"
#import "Communucator.h"
@interface AppDelegate ()

@end

@implementation AppDelegate

//UIApplication *)application 這是程式運行核心

//這方法是整隻app的最起點
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //要求使用者的許可 ask uesr's permission
    UIUserNotificationType type = UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge;
    
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type categories:nil];
    //跟系統申請註冊要求設定
    [application registerUserNotificationSettings:settings];
    
    //Ask deviceToken from APNS 從apple server拿deviceToken
    [application registerForRemoteNotifications];
    
    return YES;
}

//成功回傳結果
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"DeviceToken : %@",deviceToken.description);
    
    NSString *finalDeviceToken = deviceToken.description;
    finalDeviceToken = [finalDeviceToken stringByReplacingOccurrencesOfString:@"<" withString:@""];
    finalDeviceToken = [finalDeviceToken stringByReplacingOccurrencesOfString:@">" withString:@""];
    finalDeviceToken = [finalDeviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSLog(@"finalToken:%@",finalDeviceToken);
    
    Communucator *comm = [Communucator sharedInstance];
    [comm updateDeviceToken:finalDeviceToken completion:^(NSError *error, id result) {
        
    }];
}
//當通知被點開後
-(void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler{
    
    NSLog(@"* didReceiveRemoteNotification: %@",userInfo.description);
    
    [[NSNotificationCenter defaultCenter]postNotificationName:DID_RECEIVED_REMOTE_NOTIFICATION object:nil];
    
    completionHandler(UIBackgroundFetchResultNewData);
}
//如果失敗後回傳結果
-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError: %@",error);
}










//app即將要進入背景狀態 （突發狀況：電話來或著其他通知導致暫停會執行到這個方法）
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

//一回到主畫面的瞬間（app進入背景狀態）（突發狀況：電話來或著其他通知導致暫停並不會執行到這個方法）
- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}



//一點墼ＡＰＰ的瞬間（還沒顯示畫面）
- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

//一回到畫面的瞬間 （突發狀況：電話來或著其他通知結束時會執行到這個方法）
- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


//通知app即將被中斷 舉例：在運行app中直接進入多工管理並且中斷時才會執行 （已到背景才開多工中段不算）
- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
