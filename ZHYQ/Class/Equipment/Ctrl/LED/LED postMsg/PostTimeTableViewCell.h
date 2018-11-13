//
//  PostTimeTableViewCell.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/10.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LEDPostTacticsType) {
    LEDPostTacticsDefiniteTime,
    LEDPostTacticsImmediately
};

@protocol LedPostTacticsDelegate <NSObject>

-(void)ledPostTactics:(LEDPostTacticsType)type;

@end

@interface PostTimeTableViewCell : UITableViewCell

@property (nonatomic,weak) id<LedPostTacticsDelegate> delegate;

@end
