//
//  OpenDoorManager.h
//  DemoDPSDK
//
//  Created by chen_zhongbo on 16/4/29.
//  Copyright © 2016年 jiang_bin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OpenDoorManager : NSObject
+ (OpenDoorManager *) sharedInstance;

-(int32_t) setPecDoorStatusCallback;
@end
