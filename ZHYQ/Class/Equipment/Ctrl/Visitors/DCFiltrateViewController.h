//
//  DCFiltrateViewController.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/18.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DCFiltrateViewController : UIViewController

/** 点击已选回调 */
@property (nonatomic , copy) void(^sureClickBlock)(NSArray *selectArray);

@end
