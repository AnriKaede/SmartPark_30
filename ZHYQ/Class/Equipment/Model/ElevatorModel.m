//
//  ElevatorModel.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/23.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "ElevatorModel.h"
#import "SubElevatorModel.h"

@implementation ElevatorModel

- (instancetype)initWithDataDic:(NSDictionary *)data {
    self = [super initWithDataDic:data];
    if(self){
        NSArray *subDeviceList = data[@"subDeviceList"];
        if(subDeviceList != nil && ![subDeviceList isKindOfClass:[NSNull class]]){
            NSMutableArray *subList = @[].mutableCopy;
            [subDeviceList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                SubElevatorModel *model = [[SubElevatorModel alloc] initWithDataDic:obj];
                [subList addObject:model];
            }];
            self.subDeviceList = subList;
        }
        
        
    }
    return self;
}

- (void)setWarnState:(NSString *)warnState {
    // 电梯状态 周一到周五每天晚上8点到第2天上午7点  和周六日全天 状态固定为全部正常
    if([self getCurrentWeekDay] >=1 && [self getCurrentWeekDay] <= 5){
        // 周一到周五
        if([self getCurrentHour] >= 20 &&[self getCurrentHour] <= 7){
            _warnState = @"1";
        }else {
            _warnState = warnState;
        }
    }else {
        // 周末
        _warnState = @"1";
    }
}

// 获取当前周几，从周日开始为1
- (NSInteger)getCurrentWeekDay {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSCalendarUnitWeekday;
    NSDate *now = [NSDate date];
    comps = [calendar components:unitFlags fromDate:now];
    
    return [comps weekday] - 1;
}
// 获取当前时间小时 24小时制
- (NSInteger)getCurrentHour {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSCalendarUnitHour;
    NSDate *now = [NSDate date];
    comps = [calendar components:unitFlags fromDate:now];
    
    return [comps hour];
}

#pragma mark 返回前n天 时间  单位天
- (NSDate *)getNDay:(NSInteger)n{
    NSDate*nowDate = [NSDate date];
    NSDate* theDate;
    
    if(n!=0){
        NSTimeInterval  oneDay = 24*60*60*1;  //1天的长度
        theDate = [nowDate initWithTimeIntervalSinceNow: -oneDay*n ];//initWithTimeIntervalSinceNow是从现在往前后推的秒数
        
    }else{
        theDate = nowDate;
    }
    
    return theDate;
}

@end
