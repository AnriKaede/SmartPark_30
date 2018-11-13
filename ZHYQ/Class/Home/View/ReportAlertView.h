//
//  ReportAlertView.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/4/24.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ReportAlertDelegate <NSObject>

- (void)cancel;
- (void)submitReport;

@end

@interface ReportAlertView : UIView

@property (nonatomic,assign) id<ReportAlertDelegate> reportDelegate;

- (void)showReport:(NSString *)codeId;
- (void)hidReport;

@end
