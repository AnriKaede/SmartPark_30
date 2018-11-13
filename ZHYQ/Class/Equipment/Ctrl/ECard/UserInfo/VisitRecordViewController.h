//
//  VisitRecordViewController.h
//  DXWingGate
//
//  Created by coder on 2018/8/24.
//  Copyright © 2018年 com.Transfar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

@interface VisitRecordViewController : RootViewController

@property (nonatomic,copy) NSString *cardNo;

-(void)filterAction;

@end
