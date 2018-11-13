//
//  MessageViewController.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/13.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "RootViewController.h"

typedef enum {
    LoginMessage = 0,
    WranMessage,
    BillMessage
}MessageType;

@interface MessageViewController : RootViewController

@property (nonatomic,assign) MessageType messageType;

@end
