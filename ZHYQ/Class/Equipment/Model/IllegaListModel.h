//
//  IllegaListModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/29.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface IllegaListModel : BaseModel

/*
{
    "illegalLogid": "8a21dd2c5ba51645015ba58f79280003",
    "illegalId": "8a21dd2c5ba51645015ba58efbaf0000",
    "illegalContent": "由禁停变为允停",
    "illegalPic": null,
    "illegalCreatetime": "20170425224135",
    "illegalCreateUser": "湖南通服",
    "illegalType": "01",
    "illegalCarno": "湘A67976",
    "illegalNum": 1,
    "illegalStatus": "02"
}
 */

@property (nonatomic, copy) NSString *illegalLogid;
@property (nonatomic, copy) NSString *illegalId;
@property (nonatomic, copy) NSString *illegalContent;
@property (nonatomic, copy) NSString *illegalPic;
@property (nonatomic, copy) NSString *illegalCreatetime;
@property (nonatomic, copy) NSString *illegalCreateUser;
@property (nonatomic, copy) NSString *illegalType;
@property (nonatomic, copy) NSString *illegalCarno;
@property (nonatomic, strong) NSNumber *illegalNum;
@property (nonatomic, copy) NSString *illegalStatus;

@end
