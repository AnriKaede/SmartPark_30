//
//  Utils.h
//  SYapp
//
//  Created by 焦平 on 2017/2/14.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/***************************************************************************
 *
 * 工具类
 *
 ***************************************************************************/

@class AppDelegate;
@class UserInfo;

@interface Utils : NSObject

/*
 AppDelegate
 */

+(AppDelegate *)applicationDelegate;

+ (UIImageView *)imageViewWithFrame:(CGRect)frame withImage:(UIImage *)image;

+ (UILabel *)labelWithFrame:(CGRect)frame withTitle:(NSString *)title titleFontSize:(UIFont *)font textColor:(UIColor *)color backgroundColor:(UIColor *)bgColor alignment:(NSTextAlignment)textAlignment;


#pragma mark - alertView提示框
+(UIAlertView *)alertTitle:(NSString *)title message:(NSString *)msg delegate:(id)aDeleagte cancelBtn:(NSString *)cancelName otherBtnName:(NSString *)otherbuttonName;
#pragma mark - btnCreate
+(UIButton *)createBtnWithType:(UIButtonType)btnType frame:(CGRect)btnFrame backgroundColor:(UIColor*)bgColor;

#pragma mark isValidateEmail
+(BOOL)isValidateEmail:(NSString *)email;

+ (BOOL)valiMobile:(NSString *)mobile;

+(NSString *)convertToJsonData:(id)dict;

+ (NSString*)weekdayStringFromDate:(NSDate*)inputDate;

+ (BOOL)judgePassWordLegal:(NSString *)pass;

//获取当前屏幕显示的viewcontroller
+ (UIViewController *)getCurrentVC;

// 退出登录清除本地数据
+ (void)logoutRemoveDefInfo;

+ (NSString *)exchWith:(NSNumber *)time WithFormatter:(NSString *)dataformatter;

+ (NSString *)getCurrentTime;

+(NSString *)getCurrentMouth;

+ (NSString *)dateTimeDifferenceWithStartTime:(NSString *)startTime endTime:(NSString *)endTime;

+ (NSString *)getMonthBeginAndEndWith:(NSString *)dateStr;

+ (CGFloat)getStringHeightWithText:(NSString *)text fontSize:(float)fontSize viewWidth:(CGFloat)width;

+ (NSString *)timeStrWithInt:(NSNumber *)time;

@end

