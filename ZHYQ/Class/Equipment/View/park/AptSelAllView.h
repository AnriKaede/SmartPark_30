//
//  AptSelAllView.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/6/15.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BatchAptDelegate <NSObject>

- (void)batchSelect:(BOOL)isSelect;
- (void)batchClick;

@end

@interface AptSelAllView : UIView

@property (nonatomic,assign) id<BatchAptDelegate> batchAptDelegate;

@end
