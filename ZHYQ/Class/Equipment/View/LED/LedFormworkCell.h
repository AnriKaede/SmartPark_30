//
//  LedFormworkCell.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/16.
//  Copyright © 2018 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LEDFormworkModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol LEDFormworkDelegate <NSObject>

- (void)edit:(LEDFormworkModel *)formworkModel;
- (void)deleteForwork:(LEDFormworkModel *)formworkModel;
- (void)user:(LEDFormworkModel *)formworkModel;

@end

@interface LedFormworkCell : UITableViewCell

@property (nonatomic,assign) id<LEDFormworkDelegate> formworkDelegate;
// 入口是否是 使用模板
@property (nonatomic,assign) BOOL isEdit;
@property (nonatomic,retain) LEDFormworkModel *formworkModel;

@end

NS_ASSUME_NONNULL_END
