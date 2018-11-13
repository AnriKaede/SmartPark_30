//
//  SearchRecordViewController.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/12/21.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "RootViewController.h"

typedef enum {
    Ecard = 0,
    RemoteOpen
}OpenDoorType;

@interface SearchRecordViewController : RootViewController

@property (nonatomic,copy) NSString *tagID;
@property (nonatomic,copy) NSString *deivedID;
@property (nonatomic, assign) OpenDoorType openType;

@end
