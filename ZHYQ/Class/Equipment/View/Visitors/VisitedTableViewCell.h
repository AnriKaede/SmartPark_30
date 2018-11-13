//
//  VisitedTableViewCell.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/18.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VisitorFinishModel.h"

@protocol isArraiveCallTelePhoneDelegate <NSObject>

-(void)isArraiveCallTelePhone:(NSString *)telephone;

- (void)faceQuery:(VisitorFinishModel *)visitorFinishModel;

@end

@interface VisitedTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadSpace;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *phoneLeadSpace;

@property (weak, nonatomic) IBOutlet UILabel *telephoneLab;

@property (nonatomic, assign) id<isArraiveCallTelePhoneDelegate> delegate;

@property (nonatomic, retain) VisitorFinishModel *visitorFinishModel;

@end
