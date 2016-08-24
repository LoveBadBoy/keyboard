//
//  keyboardViewController.h
//  keyboard
//
//  Created by 赵宏 on 16/8/23.
//  Copyright © 2016年 赵宏. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"
#import "ZYQAssetPickerController.h"
@interface keyboardViewController : UIViewController<UIScrollViewDelegate,HPGrowingTextViewDelegate,ZYQAssetPickerControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property(nonatomic,retain)NSString *sender_uid;
@property(nonatomic,retain)NSString *sender_username;

@property(nonatomic,retain)NSDictionary* userDic;

@end
