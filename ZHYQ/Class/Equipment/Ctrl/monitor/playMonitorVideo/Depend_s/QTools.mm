////
//  QTools.m
//  DahuaVision
//
//  Created by panyj on 14-4-21.
//  Copyright (c) 2013年 Dahuatech. All rights reserved.
//

#import "QTools.h"
#include <sys/param.h>
#include <sys/mount.h>
#import "UIDevice+Resolutions.h"

@implementation QTools

static QTools* __shareQTools = nil;

- (id) init
{
    self = [super init];
    if (self)
    {
    }
    return self;
}

+ (QTools *) sharedQTools
{
    @synchronized(self)
    {
        if(nil == __shareQTools)
        {
            __shareQTools = [[self alloc] init];
        }
    }
    return __shareQTools;
}

+ (UIColor*)colorOfString16:(NSString*)color
{
    unichar uc = [color characterAtIndex:0];
    if (uc == '#')
    {
        color = [color substringFromIndex:1];
    }
    
    unsigned int colorValue = 0;
    NSScanner * scan = [[NSScanner alloc] initWithString:color];
    [scan scanHexInt:&colorValue];
    
    uint8_t * colorBytes = (uint8_t*)&colorValue;
    return [UIColor colorWithRed:(CGFloat)colorBytes[3]/255.0
                           green:(CGFloat)colorBytes[2]/255.0
                            blue:(CGFloat)colorBytes[1]/255.0
                           alpha:(CGFloat)colorBytes[0]/255.0];
}


+ (UIColor*)colorOfString10:(NSString*)color
{
    NSArray * rgbs = [color componentsSeparatedByString:@","];
    int iCount = [rgbs count];
    if (iCount < 3) {
        return [UIColor clearColor];
    }
    CGFloat rgb[4] = {0};
    for (int i=0; i<iCount; ++i) {
        rgb[i] = [rgbs[i] floatValue];
    }
    return [UIColor colorWithRed:rgb[0]/255.0
                           green:rgb[1]/255.0
                            blue:rgb[2]/255.0
                           alpha:(iCount>=4?rgb[3]/255.0:1.0)];
}


+ (UIColor*)colorWithRGB:(int)r :(int)g :(int)b
{
    return [UIColor colorWithRed:((CGFloat)r)/255 green:((CGFloat)g)/255 blue:((CGFloat)b)/255 alpha:1];
}

#define ILLEGALCHAR "!$&*()+=\\/'\"<>,~[]#@%^:?"
+ (BOOL)illegalCharacterInString:(NSString*)cString
{
	char cExclued[] = ILLEGALCHAR ;
	const char* string = [cString cStringUsingEncoding:NSUTF8StringEncoding];
	if (string != NULL)
	{
		for (int i=0 ; i< strlen(cExclued); i++)
		{
			if (NULL != strchr(string, cExclued[i]))
			{
				return TRUE;
			}
		}
	}
	
	return FALSE;
}

+ (BOOL)AllNumerics:(NSString*)cString
{
    if ([cString length] == 0) {
        return NO;
    }
    
    char numbers[] = "1234567890";
    const char* string = [cString cStringUsingEncoding:NSUTF8StringEncoding];
	if (string != NULL)
	{
		for (int i=0 ; i< strlen(string); i++)
		{
			if (NULL == strchr(numbers, string[i]))
			{
				return NO;
			}
		}
	}
	
	return YES;
}

+ (NSString*)deleteStrinngNoUseSpace:(NSString*)strInput
{
    return [strInput stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (NSString*) documentFolder
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	return documentsDirectory;
}

+ (UIButton*)createBtnByImage:(NSString*)imageName action:(SEL)sel target:(id)tar;
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:[imageName stringByAppendingString:@"_n"]] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:[imageName stringByAppendingString:@"_h"]] forState:UIControlStateHighlighted];
    [button addTarget:tar action:sel forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

+ (void)setBtnStyle:(UIButton*)btn cornerRadius:(CGFloat)radius borderWidth:(CGFloat)width bordercolor:(UIColor*)colorValue
{
    CALayer * downButtonLayer = [btn layer];
    [downButtonLayer setMasksToBounds:YES];
    [downButtonLayer setCornerRadius:radius];
    [downButtonLayer setBorderWidth:width];
    [downButtonLayer setBorderColor:[colorValue CGColor]];
}

#pragma mark -
#pragma mark Date

+ (NSDateFormatter*)dateFormatter
{
    NSTimeZone * tz = [NSTimeZone localTimeZone];
#if TARGET_IPHONE_SIMULATOR
    tz = [NSTimeZone timeZoneForSecondsFromGMT:8*3600];
#endif
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:tz];
    return formatter;
}

/** 转化为以时钟开始的字符串 */
+ (NSString *)stringBeginWithHourOfTime:(NSTimeInterval)time
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter *format = [self dateFormatter];
    [format setDateFormat:@"HH:mm:ss"];
    return [format stringFromDate:date];
}
/** 转化为以时钟开始的字符串 起始时间为当前时间 */
+ (NSString *)stringBeginWithHourOfTimeNow:(NSTimeInterval)time
{
    NSDateFormatter *format = [self dateFormatter];
    [format setDateFormat:@"HH:mm:ss"];
    NSDate *nullDate=[format dateFromString:@"00:00:00"];
    NSDate *date = [NSDate dateWithTimeInterval:time sinceDate:(NSDate *)nullDate];
    return [format stringFromDate:date];
}

+ (NSDate*)dateOfDate:(NSDate*)date fmt:(NSString*)fmtStr
{
    NSDateFormatter * format = [self dateFormatter];
    [format setDateFormat:fmtStr];
    NSString * dateStr = [format stringFromDate:date];
    return [format dateFromString:dateStr];
}

//date转字符串
+ (NSString *)stringOfDate:(NSDate *)date
{
    NSDateFormatter * format = [self dateFormatter];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString * dateStr = [format stringFromDate:date];
    return dateStr;
}

+ (NSDate*)dateOfDateEnd:(NSDate*)date
{
    NSDate * dateStart = [self dateOfDate:date fmt:@"yyyy-MM-dd"];
    NSDate * dateEnd   = [dateStart dateByAddingTimeInterval:86400];//
    NSDate * dateNow   = [NSDate date];
    if ([dateNow compare:dateEnd] == NSOrderedAscending) {
        dateEnd = dateNow;
    }
    return dateEnd;
}

+ (NSString*)deviceIDOfChannelID:(NSString*)channelID
{
    NSRange range =[channelID rangeOfString:@"$"];
    if (range.length == 0) {
        return nil;
    }
    return [channelID substringToIndex:range.location];
}

+ (double)freeDiskSpaceInMBytes
{
    struct statfs buf;
    long long freespace = -1;
    if(statfs("/var", &buf) >= 0)
    {
        freespace = (long long)(buf.f_bsize * buf.f_bfree);
    }
    return freespace/(1024.0*1024.0);
}

#define kWaitViewTag    911

- (void)endWaitting:(UIView *)inView
{
    [QTools endWaittingInView:inView];
}

+ (void)startWaittingInView:(UIView*)view alert:(NSString *)labelText frame:(CGRect)frame pos:(CGPoint)postion backgroundColor:(UIColor*)color style:(UIActivityIndicatorViewStyle)style  activeWidth:(int)width
{
    if ([view viewWithTag:kWaitViewTag])
    {
        return;
    }
    
    float fontSize = 16.0f;
    
    CGSize size = CGSizeZero;
    if (labelText != nil) {
        size = [labelText sizeWithFont:[UIFont systemFontOfSize:fontSize]];
    }

    UIView* waitView = [[UIView alloc]initWithFrame:CGRectMake(postion.x, postion.y, frame.size.width, frame.size.height)];
    
    waitView.layer.cornerRadius = 6;
    waitView.layer.masksToBounds = YES;
    waitView.backgroundColor = color;
    waitView.alpha = 0.7f;
    
    UIActivityIndicatorView* acView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:style];
    acView.frame = CGRectMake(CGRectGetWidth(waitView.frame)/2-width/2, (CGRectGetHeight(waitView.frame)-width)/2, width, width);
    [waitView addSubview:acView];
    [acView startAnimating];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, acView.frame.origin.y+acView.frame.size.height, waitView.frame.size.width, 30)];
    
    [label setText:labelText];
    
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    [label setTextColor:[UIColor whiteColor]];
    [label setFont:[UIFont systemFontOfSize:fontSize]];
    [waitView addSubview:label];
    [waitView setTag:kWaitViewTag];
    
    [view addSubview:waitView];
    [view bringSubviewToFront:waitView];
    [view setUserInteractionEnabled:NO];
    
    [[QTools sharedQTools] performSelector:@selector(endWaitting:)  withObject:view afterDelay:60];
}

+ (void)startWaittingInView:(UIView*)view alert:(NSString *)labelText frame:(CGRect)frame backgroundColor:(UIColor*)color
{
    [QTools startWaittingInView:view alert:labelText frame:frame pos:frame.origin backgroundColor:color style:UIActivityIndicatorViewStyleWhite activeWidth:20];
}

+ (void)startWaittingInView:(UIView*)view alert:(NSString *)labelText frame:(CGRect)frame activeStyle:(UIActivityIndicatorViewStyle)style
{
    [QTools startWaittingInView:view alert:labelText frame:frame pos:frame.origin backgroundColor:[UIColor clearColor] style:style activeWidth:20];
}

+ (void)startWaittingInView:(UIView*)view alert:(NSString*)labelText
{
    [QTools startWaittingInView:view alert:labelText frame:view.frame];
}

+ (void)startWaittingInView:(UIView*)view alert:(NSString *)labelText frame:(CGRect)frame
{
    [QTools startWaittingInView:view alert:labelText frame:frame pos:frame.origin backgroundColor:[UIColor blackColor] style:UIActivityIndicatorViewStyleWhite activeWidth:20];
}

+ (void)startWaittingInViewCenter:(UIView*)view alert:(NSString *)labelText frame:(CGRect)frame
{
    CGPoint pos;
    pos.x = (view.frame.size.width-frame.size.width)/2;
    pos.y = (view.frame.size.height-frame.size.height)/2;
    
    [QTools startWaittingInView:view alert:labelText frame:frame pos:pos backgroundColor:[UIColor blackColor] style:UIActivityIndicatorViewStyleWhite activeWidth:20];
}

+ (void)startShortWaittingInView:(UIView*)view
{
    CGRect frame = CGRectMake(0, 0, 60, 60);
    CGPoint pos;
    CGFloat x, y;
    x = view.frame.size.width;
    y = view.frame.size.height;
    
    if (view.frame.size.width == 0) {
        x = 320;
    }
    if (view.frame.size.height == 0) {
        y = ([UIDevice currentScreenSize] == UIDevice_3_5_Inch) ? 480 : 568;
    }
    pos.x = (x-frame.size.width)/2;
    pos.y = (y-frame.size.height)/2;
    
    [QTools startWaittingInView:view alert:nil frame:frame pos:pos backgroundColor:[UIColor blackColor] style:UIActivityIndicatorViewStyleWhite activeWidth:25];
}

+ (void)startShortWaittingInViewForStartRunPage:(UIView*)view
{
    CGRect frame = CGRectMake(0, 0, 60, 60);
    CGPoint pos;
    CGFloat x, y;
    x = view.frame.size.width;
    y = view.frame.size.height;
    
    if (view.frame.size.width == 0) {
        x = 320;
    }
    if (view.frame.size.height == 0) {
       y = ([UIDevice currentScreenSize] == UIDevice_3_5_Inch) ? 480 : 568;
    }
    pos.x = (x-frame.size.width)/2;
    pos.y = (y-frame.size.height)/2 + 60;
    
    [QTools startWaittingInView:view alert:nil frame:frame pos:pos backgroundColor:[UIColor clearColor] style:UIActivityIndicatorViewStyleWhite activeWidth:25];
}

+ (void)endWaittingInView:(UIView*)view
{
    UIView *waitView = [view viewWithTag:kWaitViewTag];
    if (waitView) {
        
        [waitView removeFromSuperview];
        
        [view setUserInteractionEnabled:YES];
    }
}

+ (int)wideBytes:(const wchar_t*)szWideChar toMultiBytes:(char *)szDest length:(int)strLen
{
    setlocale(LC_ALL, "zh_CN.UTF-8");
    int nRet = wcstombs(szDest, szWideChar, strLen);
    return nRet;
}

+ (NSString *)createFolderInDocuments:(NSString *)folderName
{
    NSString *documentsDirectory = [QTools documentFolder];
    NSString *path = [NSString stringWithFormat:@"%@/%@", documentsDirectory, folderName];
    NSFileManager *fileManage = [NSFileManager defaultManager];
    [fileManage createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:Nil];
    return path;
}

+ (void)changeButton:(UIButton *)button image:(NSString *)imageName
{
    NSString *normal = [imageName stringByAppendingString:@"_n.png"];
    NSString *highLighted = [imageName stringByAppendingString:@"_h.png"];
    [button setImage:[UIImage imageNamed:normal] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:highLighted] forState:UIControlStateHighlighted];
}

+ (UIButton *)addButtonInRect:(CGRect)rect
              normalImageName:(NSString *)normalName
                hilightedName:(NSString *)hilightedName
                      acction:(SEL)action
                       parent:(UIView *)parentView
                       target:(id)target
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = rect;
    [button setImage:[UIImage imageNamed:normalName] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:hilightedName] forState:UIControlStateHighlighted];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [parentView addSubview:button];
    return button;
}


+ (BOOL)containsString:(NSString*)mainString subString:(NSString*)subString
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_0
        return [mainString containsString:subString];
#endif
    }else{
        return [mainString rangeOfString:subString].location != NSNotFound;
    }
    return false;
}

@end

