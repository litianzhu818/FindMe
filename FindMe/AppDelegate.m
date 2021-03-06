//
//  AppDelegate.m
//  FindMe
//
//  Created by mac on 14-6-18.
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//
#import <ShareSDK/ShareSDK.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <SMS_SDK/SMS_SDK.h>
#import "WXApi.h"
#import "AppDelegate.h"
#import "EaseMob.h"
#import "APService.h"
#import "User.h"
#import "iVersion.h"
@implementation AppDelegate

#pragma mark 一个类只会调用一次
+ (void)initialize
{
    // 1.取出设置主题的对象
    UINavigationBar *navBar = [UINavigationBar appearance];
    [navBar.layer setMasksToBounds:YES];
    // 2.设置导航栏的背景图片
    NSString *navBarBg = nil;
    if (iOS7) { // iOS7
        navBarBg = @"NavBar64";
        navBar.tintColor = [UIColor whiteColor];
    } else { // 非iOS7
        navBarBg = @"NavBar";
    }
    [navBar setBackgroundImage:[UIImage imageNamed:navBarBg] forBarMetrics:UIBarMetricsDefault];
    
    // 3.标题
    [navBar setTitleTextAttributes:@{
                                     NSForegroundColorAttributeName : [UIColor whiteColor]
                                     }];
    [navBar setShadowImage:[[UIImage alloc] init]];

    if (iOS7) {
        navBar.barTintColor = HDRED;
    }else{
        navBar.tintColor = HDRED;
    }
    
    UITabBar *tabBar = [UITabBar appearance];
    
    [tabBar setSelectedImageTintColor:HDRED];
    [tabBar setShadowImage:[UIImage imageNamed:@"shadowImage"]];
    [tabBar setBackgroundImage:[[UIImage alloc] init]];

    
    [iVersion sharedInstance].applicationBundleID = @"cn.ifanmi.FindMe";
//    [iVersion sharedInstance].appStoreID = 905006430;
    [iVersion sharedInstance].remoteVersionsPlistURL = @"http://114.215.115.33/download/versions.plist";
    
    if ([HDTool isFirstLoad]) {
        MJLog(@"这个版本第一次启动");
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    [[Config sharedConfig] changeOnlineState:@"0"];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber=0;
    
    [self initShareSDK];

    [self initEaseMobSDK:application and:launchOptions];
    
    [self initJpushSDK:launchOptions];
    
    [self initSMS];
    
    [[Config sharedConfig] saveRegistrationID:[APService registrionID]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginStateChange:)
                                                 name:KNOTIFICATION_LOGINCHANGE
                                               object:nil];
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        MJLog(@"didFinishLaunchingWithOptions----点击提醒打开软件");
    }else{
        MJLog(@"didFinishLaunchingWithOptions----点击ICON打开软件");
    }
    
//    if ([[Config sharedConfig] isLogin]) {
//        [self sysData];
//    }
    
    return YES;
}

-(void)loginStateChange:(NSNotification *)notification{
    
    BOOL isLogin = [notification.object boolValue];

    if (isLogin) {
        if ([notification.userInfo[@"isBack"] isEqualToString:@"0"]) {
            [self sysData];
        }
        
    }else{

    }
}

#pragma Jpush delegate
- (void)kAPNetworkDidRegister:(NSNotification *)notification {
    NSDictionary * userInfo = [notification userInfo];
    NSString *registrationID = [userInfo valueForKey:@"RegistrationID"];
    [[Config sharedConfig] saveRegistrationID:registrationID];
    MJLog(@"registrationID:%@",registrationID);
}

- (void)networkDidReceiveMessage:(NSNotification *)notification {
    NSDictionary * userInfo = [notification userInfo];
    NSString *type = [userInfo valueForKey:@"content"];
    NSDictionary *extras = [userInfo valueForKey:@"extras"];
    if ([type isEqualToString:@"changepic"]) {
        [[Config sharedConfig] coverPicUrl:[extras objectForKey:@"coverpic"]];
        [[NSNotificationCenter defaultCenter] postNotificationName:CoverChange object:nil];
    }
    
}

-(void)initShareSDK{
    [ShareSDK registerApp:@"1a81fc29a7db"];
//    [ShareSDK useAppTrusteeship:NO];
    [ShareSDK connectQQWithQZoneAppKey:@"1101776951" qqApiInterfaceCls:[QQApiInterface class] tencentOAuthCls:[TencentOAuth class]];
    
    [ShareSDK connectQZoneWithAppKey:@"1101776951"
                           appSecret:@"Z83HFVI69EpjKQBk"
                   qqApiInterfaceCls:[QQApiInterface class]
                     tencentOAuthCls:[TencentOAuth class]];
    
    [ShareSDK connectSinaWeiboWithAppKey:@"570703814"
                               appSecret:@"a806fb887bc2cfbd8cfb9e8a8bf06317"
                             redirectUri:@"http://www.ifanmi.cn"];
    
    [ShareSDK connectWeChatWithAppId:@"wx2913cf7663ee3b2f"
                           wechatCls:[WXApi class]];
}

-(void)initJpushSDK:(NSDictionary *)launchOptions{
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(kAPNetworkDidRegister:) name:kAPNetworkDidRegisterNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(networkDidReceiveMessage:) name:kAPNetworkDidReceiveMessageNotification object:nil];
    // Required
    [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                   UIRemoteNotificationTypeSound |
                                                   UIRemoteNotificationTypeAlert)];
    // Required
    [APService setupWithOption:launchOptions];
}

- (void)initSMS{
   [SMS_SDK registerApp:@"25fd3427d030" withSecret:@"f9892059e729efde69a8eb4ceab1facd"];
    [SMS_SDK enableAppContactFriends:NO];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [ShareSDK handleOpenURL:url wxDelegate:nil];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{

    return [ShareSDK handleOpenURL:url
                 sourceApplication:sourceApplication
                        annotation:annotation
                        wxDelegate:self];
}

-(void)initEaseMobSDK:(UIApplication *)application and:(NSDictionary *)launchOptions{
    
//#if !TARGET_IPHONE_SIMULATOR
//    UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeBadge |
//    UIRemoteNotificationTypeSound |
//    UIRemoteNotificationTypeAlert;
//    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:notificationTypes];
//#endif
    
    NSString *apnsCertName = nil;
#if DEBUG
    apnsCertName = @"findmepushdev";
#else
    apnsCertName = @"findmepushpro";
#endif
    [[EaseMob sharedInstance] registerSDKWithAppKey:@"fjhongdong#findme" apnsCertName:@"findmepushpro"];
    
//    [[EaseMob sharedInstance] enableBackgroundReceiveMessage];
    
    [[EaseMob sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    

    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];

}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
   
    [APService registerDeviceToken:deviceToken];
    [[EaseMob sharedInstance] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    [APService handleRemoteNotification:userInfo];
    [[EaseMob sharedInstance] application:application didReceiveRemoteNotification:userInfo];
    
    if(application.applicationState == UIApplicationStateInactive) {//点击提醒进来时调用
        completionHandler(UIBackgroundFetchResultNewData);
    } else if (application.applicationState == UIApplicationStateBackground) {
//        [self handleUserInfo:userInfo];
        completionHandler(UIBackgroundFetchResultNewData);
    } else {
        [self handleUserInfo:userInfo];
        completionHandler(UIBackgroundFetchResultNewData);
    }
    
    completionHandler(UIBackgroundFetchResultNoData);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [APService handleRemoteNotification:userInfo];
    [[EaseMob sharedInstance] application:application didReceiveRemoteNotification:userInfo];
    if (application.applicationState==UIApplicationStateInactive) {

    }else if (application.applicationState==UIApplicationStateActive) {
        
    }else if(application.applicationState==UIApplicationStateBackground){
        
    }
}
/**
 对推送的处理
 */
-(void)handleUserInfo:(NSDictionary *)userInfo{
    if ([[userInfo objectForKey:@"type"] isEqualToString:@"10001"]) {//强退,未处理
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ForceSignOut object:nil];
        
    }else if([[userInfo objectForKey:@"type"] isEqualToString:@"10002"]){//秘圈动态
        
        [[Config sharedConfig] postNew:@"1"];
        [[NSNotificationCenter defaultCenter] postNotificationName:PostNew object:nil];
        
    }else if([[userInfo objectForKey:@"type"] isEqualToString:@"10003"]){//女生匹配动态
        
        [[Config sharedConfig] matchNew:@"1"];
        [[NSNotificationCenter defaultCenter] postNotificationName:MatchTime object:nil];
        
    }else if([[userInfo objectForKey:@"type"] isEqualToString:@"10004"]){//男生匹配动态

        [[Config sharedConfig] matchNew:@"1"];
        [[NSNotificationCenter defaultCenter] postNotificationName:MatchTime object:nil];

    }else if([[userInfo objectForKey:@"type"] isEqualToString:@"10005"]){//好友动态
        
        [[Config sharedConfig] friendNew:@"1"];
        [[NSNotificationCenter defaultCenter] postNotificationName:FriendChange object:nil];
        
    }else if ([[userInfo objectForKey:@"type"] isEqualToString:@"10006"]){//女生粉丝动态
        
        [[Config sharedConfig] fansNew:@"1"];
        [[NSNotificationCenter defaultCenter] postNotificationName:FansNew object:nil];
        
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // 让SDK得到App目前的各种状态，以便让SDK做出对应当前场景的操作
	[[EaseMob sharedInstance] applicationWillResignActive:application];
//    [[Config sharedConfig] changeOnlineState:@"0"];
    [[Config sharedConfig] saveResignActiveDate];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // 让SDK得到App目前的各种状态，以便让SDK做出对应当前场景的操作
	[[EaseMob sharedInstance] applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // 让SDK得到App目前的各种状态，以便让SDK做出对应当前场景的操作
	[[EaseMob sharedInstance] applicationWillEnterForeground:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
//    __weak __typeof(&*self)weakSelf = self;
    // 让SDK得到App目前的各种状态，以便让SDK做出对应当前场景的操作
	[[EaseMob sharedInstance] applicationDidBecomeActive:application];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [[UIApplication sharedApplication] cancelAllLocalNotifications];

    [[NSNotificationCenter defaultCenter] postNotificationName:FreshTime object:nil];
    
    if ([[Config sharedConfig] isLogin]) {
        [self sysData];
    }
}

- (void)sysData{    //同步更新数据
    [HDNet GET:@"/data/user/syc_item.do" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *sycItem = responseObject[@"sycItem"];
        NSString *syscFriends = sycItem[@"sycFriends"];
        NSString *sycPost = sycItem[@"sycPost"];
        NSString *sycMatch = sycItem[@"sycMatch"];
        NSString *sycFans = sycItem[@"sycFans"];
        if (1==[syscFriends intValue]) {
            [[Config sharedConfig] friendNew:@"1"];
            [[NSNotificationCenter defaultCenter] postNotificationName:FriendChange object:nil];
        }
        
        if (1==[sycPost intValue]) {
            [[Config sharedConfig] postNew:@"1"];
            [[NSNotificationCenter defaultCenter] postNotificationName:PostNew object:nil];
        }
        
        if (1==[sycMatch intValue]) {
            [[Config sharedConfig] matchNew:@"1"];
            [[NSNotificationCenter defaultCenter] postNotificationName:MatchTime object:nil];
        }
        
        if (1==[sycFans intValue]) {
            [[Config sharedConfig] fansNew:@"1"];
            [[NSNotificationCenter defaultCenter] postNotificationName:FansNew object:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        MJLog(@"获取更新失败");
    }];
}

#pragma mark - IChatManagerDelegate 登陆回调（主要用于监听自动登录是否成功）

- (void)didLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error
{
    if (error) {
        MJLog(@"IM后台登入失败");
    }else{
        MJLog(@"后台登入IM成功");
    }
}

#pragma mark - push

- (void)didBindDeviceWithError:(EMError *)error
{
    if (error) {
        MJLog(@"消息推送与设备绑定失败");
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // 让SDK得到App目前的各种状态，以便让SDK做出对应当前场景的操作
	[[EaseMob sharedInstance] applicationWillTerminate:application];

    [[Config sharedConfig] changeOnlineState:@"0"];
    MJLog(@"Terminate");
}

@end
