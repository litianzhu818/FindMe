//
//  ViewController.m
//  FindMe
//
//  Created by mac on 14-6-18.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import "ViewController.h"
#import "EaseMob.h"
#import "UINavigationBar+HD.h"
@interface ViewController ()

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.tabBarItem.image = [[UIImage imageNamed:@"tb0"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.tabBarItem.selectedImage = [[UIImage imageNamed:@"tb0s"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.tabBarItem.tag = 0;
        
        self.navigationBar.translucent = NO;
//        [self.navigationBar hideDividingLine];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)dealloc{


}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
