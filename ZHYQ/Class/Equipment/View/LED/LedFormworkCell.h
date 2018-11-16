//
//  LedFormworkCell.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/16.
//  Copyright © 2018 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LEDFormworkDelegate <NSObject>

- (void)edit;
- (void)deleteForwork;
- (void)user;

@end

@interface LedFormworkCell : UITableViewCell

@property (nonatomic,assign) id<LEDFormworkDelegate> formworkDelegate;

@end

NS_ASSUME_NONNULL_END
