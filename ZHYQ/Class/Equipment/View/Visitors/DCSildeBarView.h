//
//  SideBarView.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/18.
//  Copyright © 2017年 焦平. All rights reserved.//

#import <UIKit/UIKit.h>

typedef enum {
    VersionFilter = 0,
    LogFilter,
    FaceFilter,
    MessageFilter,
    ParkRecordFilter,
    AppointMentParkFilter
}FilterType;

@interface DCSildeBarView : UIView

/* show */
+(void)dc_showSildBarViewController:(FilterType)filterType;


@end
