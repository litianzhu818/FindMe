#ifndef HDDefine_h
#define HDDefine_h

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

#define iOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)

#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

#define HDRED RGBACOLOR(236,111,105,1)

#define KNOTIFICATION_LOGINCHANGE @"loginStateChange"
#define EaseMobShouldLogin @"EaseMobShouldLogin"
#define UserInfoChange @"NSUserDefaultsUserChange"
#define FriendChange @"FriendChange"
#define MatchTime @"MatchTime"
#define FansNew @"FansNew"
#define PostNew @"PostNew"
#define CoverChange @"CoverChange"
#define ForceSignOut @"ForceSignOut"
#define FreshTime @"freshTime"

#define CHATVIEWBACKGROUNDCOLOR [UIColor colorWithRed:0.936 green:0.932 blue:0.907 alpha:1]

#define PostDetailHeadViewIndex 0
#define FirstPageViewIndex 1
#define SecondPageViewIndex 2
#define CoverViewIndex 3
#define PostDetailHeadView1Index 4
#define EmptyViewIndex 5
#define RandomHiViewIndex 6
#define LoginViewIndex 7

#define Host @"http://114.215.115.33"
//#define Host @"http://192.168.1.9:8080/FindMeServer"
#endif
