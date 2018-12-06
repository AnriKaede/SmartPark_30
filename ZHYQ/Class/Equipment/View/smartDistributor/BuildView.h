//
//  BuildView.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/5.
//  Copyright © 2018 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BuildDelegate <NSObject>

- (void)buildLeft;
- (void)buildRight;

- (void)buildFloor:(NSInteger)index;

@end

NS_ASSUME_NONNULL_BEGIN

@interface BuildView : UIView
@property (nonatomic,assign) id<BuildDelegate> buildDelegate;
@property (nonatomic,copy) NSArray *floorData;

- (void)showBuild;
- (void)showFloor;

@end

NS_ASSUME_NONNULL_END
