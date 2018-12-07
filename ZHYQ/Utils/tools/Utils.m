//
//  Utils.m
//  SYapp
//
//  Created by 焦平 on 2017/2/14.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "Utils.h"

#import "AppDelegate.h"

@implementation Utils

/*
 AppDelegate
 */
+ (AppDelegate *)applicationDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

+ (UIImageView *)imageViewWithFrame:(CGRect)frame withImage:(UIImage *)image{
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.image = image;
    return imageView;
}

+ (UILabel *)labelWithFrame:(CGRect)frame withTitle:(NSString *)title titleFontSize:(UIFont *)font textColor:(UIColor *)color backgroundColor:(UIColor *)bgColor alignment:(NSTextAlignment)textAlignment{
    
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = title;
    label.font = font;
    label.textColor = color;
    label.backgroundColor = bgColor;
    label.textAlignment = textAlignment;
    return label;
    
}


//alertView
+(UIAlertView *)alertTitle:(NSString *)title message:(NSString *)msg delegate:(id)aDeleagte cancelBtn:(NSString *)cancelName otherBtnName:(NSString *)otherbuttonName{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:aDeleagte cancelButtonTitle:cancelName otherButtonTitles:otherbuttonName, nil];
    [alert show];
    return alert;
}

+(UIButton *)createBtnWithType:(UIButtonType)btnType frame:(CGRect)btnFrame backgroundColor:(UIColor*)bgColor{
    UIButton *btn = [UIButton buttonWithType:btnType];
    btn.frame = btnFrame;
    [btn setBackgroundColor:bgColor];
    return btn;
}

//利用正则表达式验证邮箱的合法性
+(BOOL)isValidateEmail:(NSString *)email {
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
    
}

//利用正则表达式判断手机号码格式是否正确
+ (BOOL)valiMobile:(NSString *)mobile
{
//    mobile = [mobile stringByReplacingOccurrencesOfString:@" " withString:@""];
//    if (mobile.length != 11)
//    {
//        return NO;
//    }else{
//        /**
//         * 移动号段正则表达式
//         */
//        NSString *CM_NUM = @"^((13[4-9])|(147)|(15[0-2,7-9])|(178)|(18[2-4,7-8]))\\d{8}|(1705)\\d{7}$";
//        /**
//         * 联通号段正则表达式
//         */
//        NSString *CU_NUM = @"^((13[0-2])|(145)|(15[5-6])|(176)|(18[5,6]))\\d{8}|(1709)\\d{7}$";
//        /**
//         * 电信号段正则表达式
//         */
//        NSString *CT_NUM = @"^((133)|(153)|(177)|(18[0,1,9]))\\d{8}$";
//        NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM_NUM];
//        BOOL isMatch1 = [pred1 evaluateWithObject:mobile];
//        NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU_NUM];
//        BOOL isMatch2 = [pred2 evaluateWithObject:mobile];
//        NSPredicate *pred3 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT_NUM];
//        BOOL isMatch3 = [pred3 evaluateWithObject:mobile];
//        
//        if (isMatch1 || isMatch2 || isMatch3) {
//            return YES;
//        }else{
//            return NO;
//        }
//    }
    
    if ([mobile length] == 0) {
        return NO;
    }
    
    NSString *MOBILE = @"^1([0-9]){10,10}";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    
    if ([regextestmobile evaluateWithObject:mobile] == YES) {
        return YES;
    } else {
        return NO;
    }
}

+(NSString *)convertToJsonData:(id)dict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    
    if (!jsonData) {
        NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    return mutStr;
}

+ (NSString*)weekdayStringFromDate:(NSDate*)inputDate {
    
    NSArray *weekdays = [NSArray arrayWithObjects: [NSNull null], @"星期天", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六",nil];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
    
    [calendar setTimeZone: timeZone];
    
    NSCalendarUnit calendarUnit = NSCalendarUnitWeekday;
    
    NSDateComponents *theComponents = [calendar components:calendarUnit fromDate:inputDate];
    
    return [weekdays objectAtIndex:theComponents.weekday];
}

+ (BOOL)judgePassWordLegal:(NSString *)pass{
    BOOL result = false;
    if ([pass length] >= 8){
        // 判断长度大于8位后再接着判断是否同时包含数字和字符
        NSString * regex = @"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{8,16}$";
        //        NSString *regex = @"^(?=.*[a-zA-Z0-9].*)(?=.*[a-zA-Z\\W].*)(?=.*[0-9\\W].*).{6,20}$";
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        result = [pred evaluateWithObject:pass];
    }
    return result;
}

//获取当前屏幕显示的viewcontroller
+ (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        result = nextResponder;
    }else {
        result = window.rootViewController;        
    }
    
    return result;
}

+ (void)logoutRemoveDefInfo {
    [kUserDefaults removeObjectForKey:KLoginState];
    [kUserDefaults removeObjectForKey:@"userName"];
    [kUserDefaults removeObjectForKey:@"headImag"];
    [kUserDefaults removeObjectForKey:@"roleName"];
    [kUserDefaults removeObjectForKey:KLoginUserName];
    [kUserDefaults removeObjectForKey:KLoginPasword];
    
    [kUserDefaults removeObjectForKey:KAdminCompanyId];
    [kUserDefaults removeObjectForKey:KRoleIdList];
    [kUserDefaults removeObjectForKey:KAdminUserId];
    
    [kUserDefaults removeObjectForKey:KIsRepairman];
}

+ (NSString *)exchWith:(NSNumber *)time WithFormatter:(NSString *)dataformatter
{
    NSTimeInterval interval = [time doubleValue] / 1000.0;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:dataformatter];
    NSString *dateString = [formatter stringFromDate:date];
    return dateString;
}

//获取当地时间
+ (NSString *)getCurrentTime {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateTime = [formatter stringFromDate:[NSDate date]];
    return dateTime;
}

+ (NSString *)getCurrentMouth {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM"];
    NSString *dateTime = [formatter stringFromDate:[NSDate date]];
    return dateTime;
}

+ (NSString *)dateTimeDifferenceWithStartTime:(NSString *)startTime endTime:(NSString *)endTime{
    
    NSDateFormatter *date = [[NSDateFormatter alloc]init];
    
    [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *startD =[date dateFromString:startTime];
    
    NSDate *endD = [date dateFromString:endTime];
    
    NSTimeInterval start = [startD timeIntervalSince1970]*1;
    
    NSTimeInterval end = [endD timeIntervalSince1970]*1;
    
    NSTimeInterval value = end - start;
    
    int second = (int)value;//秒
    
    NSString *str = [NSString stringWithFormat:@"%d",second];
    
    return str;
    
}

//获取当前月份最开始的一天和最后一天的日期
+ (NSString *)getMonthBeginAndEndWith:(NSString *)dateStr{
    
    NSDateFormatter *format=[[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM"];
    NSDate *newDate=[format dateFromString:dateStr];
    double interval = 0;
    NSDate *beginDate = nil;
    NSDate *endDate = nil;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar setFirstWeekday:2];//设定周一为周首日
    BOOL ok = [calendar rangeOfUnit:NSMonthCalendarUnit startDate:&beginDate interval:&interval forDate:newDate];
    //分别修改为 NSDayCalendarUnit NSWeekCalendarUnit NSYearCalendarUnit
    if (ok) {
        endDate = [beginDate dateByAddingTimeInterval:interval-1];
    }else {
        return @"";
    }
    NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
    [myDateFormatter setDateFormat:@"YYYY-MM-dd"];
    NSString *beginString = [myDateFormatter stringFromDate:beginDate];
    NSString *endString = [myDateFormatter stringFromDate:endDate];
    
    NSString *beginYear = [beginString substringWithRange:NSMakeRange(0, 4)];
    NSString *endYear = [endString substringWithRange:NSMakeRange(0, 4)];
    if (![beginYear isEqualToString:endYear]) {
        endString = [endString stringByReplacingOccurrencesOfString:endYear withString:beginYear];
    }
    
    NSString *str = [NSString stringWithFormat:@"%@,%@",beginString,endString];
    return str;
}

@end
