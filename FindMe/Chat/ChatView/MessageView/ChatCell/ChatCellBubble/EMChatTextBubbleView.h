/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */

#import <UIKit/UIKit.h>
#import "EMChatBaseBubbleView.h"
#import "MLEmojiLabel.h"

#define TEXTLABEL_MAX_WIDTH 200 //　textLaebl 最大宽度
#define LABEL_FONT_SIZE 14

extern NSString *const kRouterEventTextBubbleTapEventName;

@interface EMChatTextBubbleView : EMChatBaseBubbleView

@property (nonatomic, strong) MLEmojiLabel *textLabel;

+ (UIFont *)textLabelFont;
+ (NSLineBreakMode)textLabelLineBreakModel;

@end
