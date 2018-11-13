//
//  MessageCenViewController.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/5/29.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import <WMPageController/WMPageController.h>

@interface MessageCenViewController : WMPageController

@property (nonatomic,assign) int loginUnreadNum;
@property (nonatomic,assign) int warnUnreadNum;
@property (nonatomic,assign) int billUnreadNum;

@end
