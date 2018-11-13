//
//  DCFiltrateItem.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/18.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DCContentItem;

@interface DCFiltrateItem : NSObject
/** 用于判断当前cell是否展开 */
@property (nonatomic, assign) BOOL isOpen;

@property (nonatomic , copy) NSString *headTitle;
/* 内容数组 */
@property (strong , nonatomic)NSArray<DCContentItem *> *content;

@end
