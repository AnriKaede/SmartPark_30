//
//  VisitorFinishModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/1/20.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BaseModel.h"
#import "VisitorUserModel.h"
#import "VisitorViserModel.h"

@interface VisitorFinishModel : BaseModel

/*
{
    "cardNum": "22216314",
    "createTime": "2018-01-12 15:28:39",
    "endTime": "2018-01-12 23:59:00",
    "id": 32,
    "isPrintVoucher": 1,
    "isPullCard": 0,
    "isUpload": 0,
    "logOffTime": "2018-01-12 15:45:00",
    "rCode": "16314219",
    "reasons": "拜访",
    "sitePhoto": "\\image\\sitepic\\430105197603101046_152839.png",
    "startTime": "2018-01-12 15:28:00",
    "status": 2,
    "type": 0,
    "uID": 1038,
    "user": {},
    "vID": 14,
    "visitor": {}
}
 */

@property (nonatomic,copy) NSString *cardNum;
@property (nonatomic,copy) NSString *createTime;
@property (nonatomic,copy) NSString *endTime;
//@property (nonatomic,copy) NSString *id;
@property (nonatomic,copy) NSString *logOffTime;
@property (nonatomic,copy) NSString *reasons;
@property (nonatomic,copy) NSString *sitePhoto;
@property (nonatomic,copy) NSString *startTime;
@property (nonatomic,strong) NSNumber *status;

@property (nonatomic,copy) NSString *unit;

@property (nonatomic,retain) VisitorUserModel *userModel;
@property (nonatomic,retain) VisitorViserModel *viserModel;

@end
