//
//  FgUnParkTableViewCell.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/27.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "FgUnParkTableViewCell.h"

#import "YQSwitch.h"

@interface FgUnParkTableViewCell()<switchTapDelegate>

@property (weak, nonatomic) IBOutlet YQSwitch *lockSwitch;

@end

@implementation FgUnParkTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _lockSwitch.onText = @"升锁";
    _lockSwitch.offText = @"降锁";
    _lockSwitch.on = NO;
    _lockSwitch.backgroundColor = [UIColor clearColor];
    _lockSwitch.onTintColor = [UIColor colorWithHexString:@"6BDB6A"];
    _lockSwitch.tintColor = [UIColor colorWithHexString:@"FF4359"];
    _lockSwitch.switchDelegate = self;
//    [_lockSwitch addTarget:self action:@selector(lockOnOrOffClick:) forControlEvents:UIControlEventTouchUpInside];
    
}

//-(void)lockOnOrOffClick:(YQSwitch *)yqSwitch {
//    if(_lockDelegate){
//        [_lockDelegate parkLock:yqSwitch];
//    }
//}

- (void)setIsOpen:(BOOL)isOpen {
    _isOpen = isOpen;
    
    _lockSwitch.on = isOpen;
}

- (void)setParkLockModel:(ParkLockModel *)parkLockModel {
    _parkLockModel = parkLockModel;
    
    _lockSwitch.enabled = YES;
    // 0空闲(降下) 1占用(降下) 2预约中(升起)  92异常(不能操作)
    if([parkLockModel.lockFlag isEqualToString:@"0"]){
        _lockSwitch.on = YES;
    }else if([parkLockModel.lockFlag isEqualToString:@"1"]){
#warning 地锁操作去除限制
//        _lockSwitch.enabled = NO;   // 已停车不能操作
        _lockSwitch.on = YES;
    }else if([parkLockModel.lockFlag isEqualToString:@"2"]){
        _lockSwitch.on = NO;
    }else if([parkLockModel.lockFlag isEqualToString:@"92"]){
#warning 地锁操作去除限制
//        _lockSwitch.enabled = NO;
        _lockSwitch.on = YES;
    }
    
}

-(void)switchTap:(BOOL)on {
    if(_lockDelegate){
        [_lockDelegate parkLock:_lockSwitch];
    }
}

@end
