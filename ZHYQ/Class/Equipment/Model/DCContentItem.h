//
//  DCContentItem.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/18.
//  Copyright © 2017年 焦平. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface DCContentItem : NSObject


@property (nonatomic , strong) NSString *content;
/** 是否点击 */
@property (nonatomic,assign)BOOL isSelect;

@end
