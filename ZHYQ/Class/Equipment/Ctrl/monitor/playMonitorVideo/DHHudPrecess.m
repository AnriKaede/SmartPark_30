//
//  DHHudPrecess.m
//  iDMSS
//
//  Created by nobuts on 13-4-1.
//
//

#import "DHHudPrecess.h"
#import <pthread.h>

static DHHudPrecess* g_shareInstance = nil;

@implementation DHHudPrecess

+ (DHHudPrecess *) sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_shareInstance = [[self alloc] init];
    });
    return g_shareInstance;
}

- (id)init
{
	if ((self = [super init]))
    {
       
	}
	
	return self;
}


- (void) ShowTips:(NSString*)strTips  delayTime:(NSTimeInterval)delay  atView:(UIView*)pView
{
    if (HUD != NULL)
    {
        if (pthread_main_np() != 0)
        {
            NSLog(@"ShowTips1: should not run to here!");
            
            return;
        }
        
        HUD.mode = MBProgressHUDModeText;
        HUD.labelText = strTips;
        
        sleep(delay);
    }
    else
    {
        if (0 == pthread_main_np())
        {
            NSLog(@"ShowTips2: should not run to here!");
            
            return;
        }
        
        if (NULL == pView)
        {
            pView = [[UIApplication sharedApplication] keyWindow];
        }
        
        if (NULL == pView)
        {
            return;
        }
        
       MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:pView animated:YES];

        hud.mode = MBProgressHUDModeText;
        hud.labelText = strTips;
        //hud.detailsLabelText = strTips;
        hud.margin = 10.f;
        hud.yOffset = 50.f;
        hud.removeFromSuperViewOnHide = YES;
        
        [hud hide:YES afterDelay:delay];
    }
}


- (void) showWaiting:(NSString*)strTips WhileExecuting:(SEL)method onTarget:(id)target withObject:(id)object animated:(BOOL)animated   atView:(UIView*)pView
{
    if (NULL == pView)
    {
        pView = [[UIApplication sharedApplication] keyWindow];
    }
    
    if (NULL == pView) {
        return;
    }
    
    HUD = [[MBProgressHUD alloc] initWithView:pView];
    HUD.delegate = self;
   
	[pView addSubview:HUD];
	
	HUD.labelText = strTips;
	
	[HUD showWhileExecuting:method onTarget:target withObject:object animated:animated];
}

- (void) showProgress:(NSString*)strTips WhileExecuting:(SEL)method onTarget:(id)target withObject:(id)object animated:(BOOL)animated   atView:(UIView*)pView
{
    if (NULL == pView)
    {
        pView = [[UIApplication sharedApplication] keyWindow];
    }
    
    
    if (NULL == pView) {
        return;
    }
    
    HUD = [[MBProgressHUD alloc] initWithView:pView];
    HUD.delegate = self;
    HUD.mode = MBProgressHUDModeDeterminate;
    
	[pView addSubview:HUD];
	
	HUD.labelText = strTips;
	
	[HUD showWhileExecuting:method onTarget:target withObject:object animated:animated];
}

- (void) updateProgress:(float)progress
{
    if (HUD != NULL &&  HUD.superview)
    {
        HUD.progress = progress;
    }
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[HUD removeFromSuperview];
	HUD = nil;
}

@end
