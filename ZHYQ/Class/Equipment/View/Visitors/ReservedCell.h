//
//  ReservedCell.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/25.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReservedModel.h"

@protocol reserveCallTelePhoneDelegate <NSObject>

-(void)reserveCallTelePhone:(NSString *)telephone;

@end

@interface ReservedCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *telephoneLab;

@property (nonatomic, assign) id<reserveCallTelePhoneDelegate> delegate;

@property (nonatomic, retain) ReservedModel *reservedModel;

@end
