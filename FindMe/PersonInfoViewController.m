//
//  PersonInfoViewController.m
//  FindMe
//
//  Created by mac on 14-6-27.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import "PersonInfoViewController.h"
#import "NYSegmentedControl.h"
#import "JMWhenTapped.h"
#import "ChooseConstellationViewController.h"
#import "EaseMob.h"
#import "EMError.h"
#import "TNSexyImageUploadProgress.h"
@interface PersonInfoViewController (){
    LXActionSheet *_actionSheet;
    UIImagePickerController *_imagePicker;
    NSString *_constellationStr;
    BOOL _existPhoto;
    
    TNSexyImageUploadProgress *_progress;
    UIImage *_image;
    QiniuSimpleUploader *_uploader;
    NSString *_photoName;
}

@end

@implementation PersonInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupForDismissKeyboard:self];
    
    self.phtot.layer.cornerRadius = 25.0f;
    self.phtot.layer.masksToBounds = YES;
    
    [self.navigationItem setHidesBackButton:YES];
    
    NYSegmentedControl *segmentedControl = [[NYSegmentedControl alloc] initWithItems:@[@"男生", @"女生"]];
    _user.userSex = @"男";//没改动的话默认是男
    [segmentedControl addTarget:self action:@selector(segmentSelected:) forControlEvents:UIControlEventValueChanged];
    segmentedControl.center = CGPointMake(self.sexView.center.x - 80, 2);
    segmentedControl.titleTextColor = [UIColor colorWithWhite:0.5f alpha:1.0f];
    segmentedControl.selectedTitleTextColor = [UIColor whiteColor];
    segmentedControl.borderWidth = 1.0f;
    segmentedControl.borderColor = [UIColor colorWithWhite:0.15f alpha:1.0f];
    segmentedControl.drawsGradientBackground = YES;
    segmentedControl.segmentIndicatorInset = 2.0f;
    segmentedControl.drawsSegmentIndicatorGradientBackground = YES;
    segmentedControl.segmentIndicatorGradientTopColor = HDRED;
    segmentedControl.segmentIndicatorGradientBottomColor = HDRED;
    segmentedControl.segmentIndicatorAnimationDuration = 0.3f;
    segmentedControl.segmentIndicatorBorderWidth = 0.0f;
    [segmentedControl sizeToFit];
    [self.sexView addSubview:segmentedControl];
    

    
    __weak __typeof(&*self)weakSelf = self;
	[self.constellationView whenTouchedDown:^{
		weakSelf.constellationView.backgroundColor = [UIColor groupTableViewBackgroundColor];
	}];
    
	[self.constellationView whenTouchedUp:^{
		weakSelf.constellationView.backgroundColor = [UIColor whiteColor];
        [weakSelf performSegueWithIdentifier:@"chooseConstellation" sender:self];
	}];
    
    
    [self.photoView whenTouchedDown:^{
        weakSelf.photoView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }];
    
    [self.photoView whenTouchedUp:^{
		weakSelf.photoView.backgroundColor = [UIColor whiteColor];
        [weakSelf.view endEditing:YES];
        _actionSheet = [[LXActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@[@"拍照",@"从手机相册选择"]];
        [_actionSheet showInView:weakSelf.view];
	}];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"chooseConstellation"])
    {
        
        ChooseConstellationViewController *controller=(ChooseConstellationViewController *)segue.destinationViewController;
        controller.personInfoViewController = sender;
    }
}
- (IBAction)submitPressed:(id)sender {
    [self.view endEditing:YES];
    if (![self isOK]) {
        return;
    }

//先上传图片到七牛

    NSString *filePathStr = [[self documentFolderPath] stringByAppendingString:@"/myPhoto.png"];
    
    _progress = [[TNSexyImageUploadProgress alloc] init];
    _progress.radius = 100;
    _progress.progressBorderThickness = -10;
    _progress.trackColor = [UIColor blackColor];
    _progress.progressColor = [UIColor whiteColor];
    _progress.imageToUpload = _image;
    [_progress show];
    
    _photoName = [HDTool generateImgName];
    
    NSDictionary *parameters = @{@"type": @"user"};
    [HDNet GET:@"/data/qiniu/uploadtoken.do" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *result = responseObject[@"result"];
        if (1==[result intValue]) {
            NSString *token = responseObject[@"token"];
            _uploader = [QiniuSimpleUploader uploaderWithToken:token];
            _uploader.delegate = self;
            [_uploader uploadFile:filePathStr key:_photoName extra:nil];
        }else{
            [_progress removeFromSuperview];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        MJLog(@"错误");
        [_progress removeFromSuperview];
    }];

}

#pragma qiniuDelegate

- (void)uploadProgressUpdated:(NSString *)theFilePath percent:(float)percent
{
    _progress.progress = percent*0.95;
}

- (void)uploadSucceeded:(NSString *)theFilePath ret:(NSDictionary *)ret
{
    __weak __typeof(&*self)weakSelf = self;
    _user.userRealName = self.nameTextField.text;
    _user.userConstellation = _constellationStr;
    NSDictionary *parameters = @{ @"userPhoneNumber":           _user.userPhoneNumber,
                                 @"userNickName":           _user.userRealName,
                                 @"school._id":             [_user getSchoolId],
                                 @"school.schoolName":      [_user getSchoolName],
                                 @"department._id":         [_user getDepartmentId],
                                 @"department.deptName":    [_user getDepartmentName],
                                 @"userConstellation":      _user.userConstellation,
                                 @"userGrade":              _user.userGrade,
                                 @"userSex":                _user.userSex,
                                 @"userEquipment.equitNo": [[Config sharedConfig] getRegistrationID],
                                 @"userEquipment.osType":   @"1",
                                 @"userRealName":           _user.userRealName,
                                 @"key":                    _photoName
                                 };
    
    [HDNet POST:@"/data/user/complete_user_info.do" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *state = [responseObject objectForKey:@"state"];
        if ([state isEqualToString:@"20001"]) {
            _progress.progress = 1.0f;
            NSDictionary *userInfo = [responseObject objectForKey:@"userInfo"];
            _user._id = [userInfo objectForKey:@"userId"];
            _user.userPhoto = [userInfo objectForKey:@"userPhoto"];
            [_user getUserInfo:^{
                [_user saveToNSUserDefaults];
            }];
            [[Config sharedConfig] changeLoginState:@"1"];
            [[Config sharedConfig] changeOnlineState:@"1"];
            [weakSelf.navigationController popToRootViewControllerAnimated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@YES userInfo:@{@"isBack": @"0"}];
            [HDNet EaseMobLoginWithUsername:_user._id];
        }else if ([state isEqualToString:@"10001"]){
            [_progress removeFromSuperview];
            [HDTool showHDJGHUDHint:@"超时"];
        }else{
            [_progress removeFromSuperview];
            [HDTool showHDJGHUDHint:@"超时"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_progress removeFromSuperview];
        [HDTool showHDJGHUDHint:@"超时"];
    }];
    
}

- (void)uploadFailed:(NSString *)theFilePath error:(NSError *)error
{
    [_progress removeFromSuperview];
    [HDTool showHDJGHUDHint:@"超时"];
}

- (void)segmentSelected:(NYSegmentedControl *)sender {
    if(sender.selectedSegmentIndex==0){
        _user.userSex = @"男";
    }else{
        _user.userSex = @"女";
    }
}



-(BOOL)isOK{
    
    if (!_existPhoto) {
        [HDTool ToastNotification:@"头像还没选呢" andView:self.view andLoading:NO andIsBottom:NO];
        return NO;
    }
    
    NSString *temp = [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if(temp.length==0)
    {
        [HDTool ToastNotification:@"名字不能为空" andView:self.view andLoading:NO andIsBottom:NO];
        return NO;
    }
    temp = [_constellationStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (temp.length==0) {
        [HDTool ToastNotification:@"星座不选吗" andView:self.view andLoading:NO andIsBottom:NO];
        return NO;
    }
    return YES;
}

-(void)setConstellation:(NSIndexPath *)indexPath{
    NSString *imageStr = [NSString stringWithFormat:@"xzd%ld",(long)indexPath.row];
    switch (indexPath.row) {
        case 0:
            _constellationStr =@"白羊座";

            break;
        case 1:
            _constellationStr =@"金牛座";
            break;
        case 2:
            _constellationStr =@"双子座";
            break;
        case 3:
            _constellationStr =@"巨蟹座";
            break;
        case 4:
            _constellationStr =@"狮子座";
            break;
        case 5:
            _constellationStr =@"处女座";
            break;
        case 6:
            _constellationStr =@"天平座";
            break;
        case 7:
            _constellationStr =@"天蝎座";
            break;
        case 8:
            _constellationStr =@"射手座";
            break;
        case 9:
            _constellationStr =@"魔蝎座";
            break;
        case 10:
            _constellationStr =@"水瓶座";
            break;
        case 11:
            _constellationStr =@"双鱼座";
            break;
        default:
            break;
    }
    self.constellationImageView.image = [UIImage imageNamed:imageStr];
    self.constellationLbl.text = _constellationStr;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ((touch.view ==self.constellationView)||(touch.view ==self.photoView)) {
        return NO;
    }
    return YES;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.nameTextField resignFirstResponder];
}

#pragma mark - LXActionSheetDelegate

- (void)didClickOnButtonIndex:(NSInteger *)buttonIndex
{
    switch ((int)buttonIndex) {
        case 0:
        {
            _imagePicker = [[UIImagePickerController alloc] init];
            _imagePicker.delegate = self;
            _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            _imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            _imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
            _imagePicker.allowsEditing = YES;
            [self presentViewController:_imagePicker animated:YES completion:^{
                [HDTool showHDJGHUDHint:@"期待你真实的头像"];
            }];

            break;}
        case 1:
        {
            _imagePicker = [[UIImagePickerController alloc] init];
            _imagePicker.delegate = self;
            _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            _imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            _imagePicker.allowsEditing = YES;
            _imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
            //[self presentModalViewController:_imagePicker animated:YES];
            [self presentViewController:_imagePicker animated:YES completion:^{
                [HDTool showHDJGHUDHint:@"期待你真实的头像"];
            }];
            break;}
        default:
            break;
    }
}
#pragma UIImagePickerControllerDelegate
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    __weak __typeof(&*self)weakSelf = self;
    [picker dismissViewControllerAnimated:YES completion:^{
        NSString* mediaType = [info objectForKey:UIImagePickerControllerMediaType];
        //判断是静态图像还是视频
        if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
            _image= [info objectForKey:@"UIImagePickerControllerEditedImage"];
//        UIImage *image= [self scaleToSize:[info objectForKey:@"UIImagePickerControllerOriginalImage"] size:CGSizeMake(300,300)];
            NSData *imageData = UIImageJPEGRepresentation(_image,0.5);
            _image = [UIImage imageWithData:imageData];
            [weakSelf saveImage:_image WithName:@"myPhoto.png"];
        }
        
    }];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)saveImage:(UIImage *)tempImage WithName:(NSString *)imageName{
    self.phtot.image = tempImage;
    _existPhoto = YES;
    NSData* imageData = UIImagePNGRepresentation(tempImage);
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    // Now we get the full path to the file
    NSString* fullPathToFile = [documentsDirectory stringByAppendingPathComponent:imageName];
    // and then we write it out
    [imageData writeToFile:fullPathToFile atomically:NO];
}
- (NSString *)documentFolderPath{
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
}
- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0,0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage =UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    //返回新的改变大小后的图片
    return scaledImage;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
-(void)dealloc{

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

@end
