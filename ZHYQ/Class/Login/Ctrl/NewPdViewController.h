//
//  NewPdViewController.h
//  ZHYQ
//
//  Created by 焦平 on 2017/10/22.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "RootViewController.h"

@class  login;

@interface NewPdViewController : UIViewController
@property(nonatomic,strong)NSMutableDictionary* dict;
@property(nonatomic,copy) login *logininfo;

//从a传值到b  属性必须定义在.h文件中
@property(nonatomic,strong)NSString *userPhone;

@end
