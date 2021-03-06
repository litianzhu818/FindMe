//
//  MeViewController.m
//  FindMe
//
//  Created by mac on 14-7-4.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import "MeViewController.h"
#import "User.h"
#import "UIImageView+WebCache.h"
#import "JMWhenTapped.h"
#import <AGCommon/UINavigationBar+Common.h>
#import <AGCommon/NSString+Common.h>
#import "UIView+Common.h"
#import "NSString+HD.h"
@interface MeViewController (){
    User *_user;
}

@end

@implementation MeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {

    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userInfoUpdate:) name:UserInfoChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginChange:) name:KNOTIFICATION_LOGINCHANGE object:nil];
    self.title = @"我的";
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"meTitleView"]];
    if (![[Config sharedConfig] isLogin]) {
        [self.view addSubview:[HDTool loadCustomViewByIndex:EmptyViewIndex]];
        return;
    }
    [self setup];
}


-(void)loginChange:(NSNotification *)notification{

    BOOL isLogin = [notification.object boolValue];
    if (isLogin) {
        [[self.view viewWithTag:100] removeFromSuperview];
        [self setup];
    }
    else{
        [self.view addSubview:[HDTool loadCustomViewByIndex:EmptyViewIndex]];
 }
}

-(void)setup{
    _user = [User getUserFromNSUserDefaults];
    self.photo.layer.cornerRadius = 25.0f;
    self.photo.layer.masksToBounds = YES;
    [self setData];
    
    
    __weak __typeof(&*self)weakSelf = self;
    [self.detailView whenTouchedDown:^{
        weakSelf.detailView.backgroundColor = [UIColor lightGrayColor];
    }];
    [self.detailView whenTouchedUp:^{
        weakSelf.detailView.backgroundColor = [UIColor whiteColor];
        [self performSegueWithIdentifier:@"editInfo" sender:nil];
    }];
    
    [self.photoWallView whenTouchedDown:^{
        weakSelf.photoWallView.backgroundColor = [UIColor lightGrayColor];
    }];
    [self.photoWallView whenTouchedUp:^{
        weakSelf.photoWallView.backgroundColor = [UIColor whiteColor];
        [weakSelf performSegueWithIdentifier:@"album" sender:nil];
    }];
    
    [self.addVView whenTouchedDown:^{
        weakSelf.addVView.backgroundColor = [UIColor lightGrayColor];
    }];
    [self.addVView whenTouchedUp:^{
        weakSelf.addVView.backgroundColor = [UIColor whiteColor];
        if ([_user.userAuth intValue]==1) {
            [HDTool showHDJGHUDHint:@"你已经认证过了"];
            return;
        }
        [weakSelf performSegueWithIdentifier:@"attestation" sender:nil];
    }];
    
    [self.shareView whenTouchedDown:^{
        weakSelf.shareView.backgroundColor = [UIColor lightGrayColor];
    }];
    [self.shareView whenTouchedUp:^{
        weakSelf.shareView.backgroundColor = [UIColor whiteColor];
        [self showShare];
    }];
    
    [self.settingView whenTouchedDown:^{
        weakSelf.settingView.backgroundColor = [UIColor lightGrayColor];
    }];
    [self.settingView whenTouchedUp:^{
        weakSelf.settingView.backgroundColor = [UIColor whiteColor];
        [weakSelf performSegueWithIdentifier:@"setting" sender:nil];
    }];
}

-(void)setData{

    [self.photo sd_setImageWithURL:[HDTool getSImage:_user.userPhoto] placeholderImage:[UIImage imageNamed:@"defaultImage"] options:SDWebImageRetryFailed];
    self.nickname.text = _user.userNickName;
    CGSize size = CGSizeMake(320,2000);
    CGSize realsize = [_user.userNickName getRealSize:size andFont:[UIFont systemFontOfSize:14.0f]];
    self.nickname.frame = CGRectMake(self.nickname.frame.origin.x, self.nickname.frame.origin.y, realsize.width, realsize.height);
    
    self.sex.frame = CGRectMake(self.nickname.right + 5, self.sex.top, self.sex.width, self.sex.height);
    if ([_user.userSex isEqualToString:@"男"]) {
        self.sex.image = [UIImage imageNamed:@"boy"];
    }else if([_user.userSex isEqualToString:@"女"]){
        self.sex.image = [UIImage imageNamed:@"girl"];
    }else{
        [HDTool autoSex:self.sex];
    }
    
    self.vUserImg.frame = CGRectMake(self.sex.right+5, self.vUserImg.top, self.vUserImg.width, self.vUserImg.height);
    
    self.qianming.text = _user.userSignature;
    
    if ([_user.userAuth intValue]==1) {
        self.addVView.userInteractionEnabled = NO;
        self.isAuthBt.hidden = NO;
        self.vUserImg.hidden = NO;
    }else{
        self.addVView.userInteractionEnabled = YES;
        self.isAuthBt.hidden = YES;
        self.vUserImg.hidden = YES;
    }
}
-(void)userInfoUpdate:(NSNotification *)note{
    _user = [User getUserFromNSUserDefaults];
    [self setData];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UserInfoChange object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KNOTIFICATION_LOGINCHANGE object:nil];
}

-(void)showShare{
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"findme" ofType:@"png"];
    //构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:@"番迷 在最美的时刻，邂逅最特别的TA。每天清晨番迷君会为你寻找最适合你的Ta，开启一段奇妙的邂逅之旅。"
                                       defaultContent:@"番迷 在最美的时刻，邂逅最特别的TA。每天清晨番迷君会为你寻找最适合你的Ta，开启一段奇妙的邂逅之旅。"
                                                image:[ShareSDK imageWithPath:imagePath]
                                                title:@"番迷（findme），以最美的方式与你邂逅"
                                                  url:@"http://www.ifanmi.cn"
                                          description:nil
                                            mediaType:SSPublishContentMediaTypeNews];
    
    //定制QQ空间信息
    [publishContent addQQSpaceUnitWithTitle:INHERIT_VALUE
                                        url:@"http://www.ifanmi.cn"
                                       site:@"http://www.ifanmi.cn"
                                    fromUrl:@"http://www.ifanmi.cn"
                                    comment:@"番迷 在最美的时刻，邂逅最特别的TA。每天清晨番迷君会为你寻找最适合你的Ta，开启一段奇妙的邂逅之旅。"
                                    summary:@"番迷 在最美的时刻，邂逅最特别的TA。每天清晨番迷君会为你寻找最适合你的Ta，开启一段奇妙的邂逅之旅。"
                                      image:[ShareSDK imageWithUrl:@"http://114.215.115.33/upload/bgpic/logo287.png"]
                                       type:INHERIT_VALUE
                                    playUrl:nil
                                       nswb:[[NSNumber alloc] initWithInt:0]];
    
    //定制微信好友信息
    [publishContent addWeixinSessionUnitWithType:[[NSNumber alloc] initWithInt:2]
                                         content:INHERIT_VALUE
                                           title:INHERIT_VALUE
                                             url:@"http://www.ifanmi.cn"
                                      thumbImage:[ShareSDK imageWithPath:imagePath]
                                           image:[ShareSDK imageWithPath:imagePath]
                                    musicFileUrl:nil
                                         extInfo:nil
                                        fileData:nil
                                    emoticonData:nil];
    
    //定制微信朋友圈信息
    [publishContent addWeixinTimelineUnitWithType:INHERIT_VALUE
                                          content:INHERIT_VALUE
                                            title:INHERIT_VALUE
                                              url:@"http://www.ifanmi.cn"
                                       thumbImage:[ShareSDK imageWithUrl:@"http://114.215.115.33/upload/bgpic/logo287.png"]
                                            image:[ShareSDK imageWithUrl:@"http://114.215.115.33/upload/bgpic/logo287.png"]
                                     musicFileUrl:nil
                                          extInfo:nil
                                         fileData:nil
                                     emoticonData:nil];
    
    
    
    //定制QQ分享信息
    [publishContent addQQUnitWithType:INHERIT_VALUE
                              content:INHERIT_VALUE
                                title:INHERIT_VALUE
                                  url:INHERIT_VALUE
                                image:[ShareSDK imageWithUrl:@"http://114.215.115.33/upload/bgpic/logo287.png"]];
    
    
    //创建弹出菜单容器
    id<ISSContainer> container = [ShareSDK container];
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                                scopes:nil
                                                         powerByHidden:YES
                                                        followAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                        [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"洪小东东"],
                                                                        SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
                                                                        nil]
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    
    
    //自定义新浪微博分享菜单项
    id<ISSShareActionSheetItem> sinaItem = [ShareSDK shareActionSheetItemWithTitle:[ShareSDK getClientNameWithType:ShareTypeSinaWeibo]
                                                                              icon:[ShareSDK getClientIconWithType:ShareTypeSinaWeibo]
                                                                      clickHandler:^{
                                                                          [ShareSDK shareContent:publishContent
                                                                                            type:ShareTypeSinaWeibo
                                                                                     authOptions:authOptions
                                                                                   statusBarTips:NO
                                                                                          result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                                                                              
                                                                                              if (state == SSPublishContentStateSuccess)
                                                                                              {
                                                                                                  MJLog(NSLocalizedString(@"TEXT_SHARE_SUC", @"分享成功"));
                                                                                              }
                                                                                              else if (state == SSPublishContentStateFail)
                                                                                              {
                                                                                                  MJLog(NSLocalizedString(@"TEXT_SHARE_FAI", @"分享失败,错误码:%d,错误描述:%@"), [error errorCode], [error errorDescription]);
                                                                                              }
                                                                                          }];
                                                                      }];
    
    
    //自定义QQ空间分享菜单项
    id<ISSShareActionSheetItem> qzoneItem = [ShareSDK shareActionSheetItemWithTitle:[ShareSDK getClientNameWithType:ShareTypeQQSpace]
                                                                               icon:[ShareSDK getClientIconWithType:ShareTypeQQSpace]
                                                                       clickHandler:^{
                                                                           [ShareSDK shareContent:publishContent
                                                                                             type:ShareTypeQQSpace
                                                                                      authOptions:authOptions
                                                                                    statusBarTips:YES
                                                                                           result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                                                                               
                                                                                               if (state == SSPublishContentStateSuccess)
                                                                                               {
                                                                                                   MJLog(NSLocalizedString(@"TEXT_SHARE_SUC", @"分享成功"));
                                                                                               }
                                                                                               else if (state == SSPublishContentStateFail)
                                                                                               {
                                                                                                   MJLog(NSLocalizedString(@"TEXT_SHARE_FAI", @"分享失败,错误码:%d,错误描述:%@"), [error errorCode], [error errorDescription]);
                                                                                               }
                                                                                           }];
                                                                       }];
    
    
    
    
    //创建自定义分享列表
    NSArray *shareList = [ShareSDK customShareListWithType:
                          sinaItem,
                          qzoneItem,
                          SHARE_TYPE_NUMBER(ShareTypeWeixiSession),
                          SHARE_TYPE_NUMBER(ShareTypeWeixiTimeline),
                          SHARE_TYPE_NUMBER(ShareTypeQQ),nil];
    
    [ShareSDK showShareActionSheet:container
                         shareList:shareList
                           content:publishContent
                     statusBarTips:YES
                       authOptions:authOptions
                      shareOptions:[ShareSDK defaultShareOptionsWithTitle:nil
                                                          oneKeyShareList:[NSArray defaultOneKeyShareList]
                                                           qqButtonHidden:NO
                                                    wxSessionButtonHidden:NO
                                                   wxTimelineButtonHidden:NO
                                                     showKeyboardOnAppear:NO
                                                        shareViewDelegate:self
                                                      friendsViewDelegate:self
                                                    picViewerViewDelegate:nil]
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                
                                if (state == SSPublishContentStateSuccess)
                                {
                                    MJLog(NSLocalizedString(@"TEXT_SHARE_SUC", @"发表成功"));
                                }
                                else if (state == SSPublishContentStateFail)
                                {
                                    MJLog(NSLocalizedString(@"TEXT_SHARE_FAI", @"发布失败!error code == %d, error code == %@"), [error errorCode], [error errorDescription]);

                                }
                            }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}
#pragma mark - ISSShareViewDelegate

- (void)viewOnWillDisplay:(UIViewController *)viewController shareType:(ShareType)shareType
{
    
    if (iOS7)
    {
        UIButton *leftBtn = (UIButton *)viewController.navigationItem.leftBarButtonItem.customView;
        UIButton *rightBtn = (UIButton *)viewController.navigationItem.rightBarButtonItem.customView;
        
        [leftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.text = viewController.title;
        label.font = [UIFont boldSystemFontOfSize:18];
        [label sizeToFit];
        
        viewController.navigationItem.titleView = label;
        
    }

        if (UIInterfaceOrientationIsLandscape(viewController.interfaceOrientation))
        {
            if (IS_IPHONE_5)
            {
                [viewController.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"iPhoneLandscapeNavigationBarBG-568h.png"]];
            }
            else
            {
                [viewController.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"iPhoneLandscapeNavigationBarBG.png"]];
            }
        }
        else
        {
            [viewController.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"iPhoneNavigationBarBG.png"]];
        }
    
}

@end
