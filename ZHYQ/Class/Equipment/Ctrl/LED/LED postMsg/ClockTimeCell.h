//
//  ClockTimeCell.h
//  ZHYQ
//
//  Created by coder on 2018/10/23.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LEDClockTimeDelegate <NSObject>

-(void)clockTimeWithTimeStr:(NSString *)time;

@end

NS_ASSUME_NONNULL_BEGIN

@interface ClockTimeCell : UITableViewCell

@property (nonatomic,weak) id<LEDClockTimeDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
