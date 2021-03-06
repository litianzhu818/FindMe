//
//  User.h
//  FindMe
//
//  Created by mac on 14-4-30.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <STDbKit/STDbObject.h>
@interface User : STDbObject

@property (strong,nonatomic) NSString *userPhoneNumber;
@property (strong,nonatomic) NSString *userPassword;
@property (strong,nonatomic) NSString *userNickName;
@property (strong,nonatomic) NSString *userPhoto;



@property (strong,nonatomic) NSMutableDictionary *department;
@property (strong,nonatomic) NSMutableDictionary *school;

@property (strong,nonatomic) NSString *userGrade;
@property (strong,nonatomic) NSString *userSex;
@property (strong,nonatomic) NSString *_id;
@property (strong,nonatomic) NSString *type;
@property (strong,nonatomic) NSString *userSignature;
@property (strong,nonatomic) NSString *userRealName;

@property (strong,nonatomic) NSString *isOnLine;
@property (strong,nonatomic) NSString *userLoginCount;
@property (strong,nonatomic) NSMutableArray *userAlbum;

@property (strong,nonatomic) NSNumber *userAuth;

@property (strong,nonatomic) NSString *registrationID;

@property(strong,nonatomic)  NSString *userConstellation;

-(NSString *)getSchoolId;
-(NSString *)getSchoolName;
-(NSString *)getDepartmentId;
-(NSString *)getDepartmentName;

-(void)saveToNSUserDefaults;
-(void)getUserInfo:(void (^)())complete;

+(id)getUserFromNSUserDefaults;
@end
