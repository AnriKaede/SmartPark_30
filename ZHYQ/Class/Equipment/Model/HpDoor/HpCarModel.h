//
//  HpCarModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/12/19.
//  Copyright © 2018 焦平. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HpCarModel : BaseModel

/*

{
    "TRACE_BEGIN": "20190121090608",
    "TRACE_CARNO": "湘A875V1",
    "TRACE_END": "20190121091030",
    "TRACE_INDEX2": "2019012109060850000072000067655852",
    "TRACE_INGATEID": "8a04a41f56bc33a20156bc3a914c000b",
    "TRACE_INPHOTO": "http://115.29.51.72:8081/file/park/hzcl/20190121/湘A875V1-2019-01-21-09-06-08-b.jpg",
    "TRACE_OUTGATEID": "8a04a41f56bc33a20156bc3ac78f000d",
    "TRACE_OUTPHOTO": "http://115.29.51.72:8081/file/park/hzcl/20190121/湘A875V1-2019-01-21-09-10-29-b.jpg"
}

 */

//@property (nonatomic,copy) NSString *DID;
//@property (nonatomic,copy) NSString *FM_DEVICE_NAME;
//@property (nonatomic,copy) NSString *OPEN_TIME;
//@property (nonatomic,copy) NSString *PLATE;
//@property (nonatomic,copy) NSString *PLATEPIC;
//@property (nonatomic,strong) NSNumber *ROW_ID;
//@property (nonatomic,copy) NSString *TYPE;
//@property (nonatomic,copy) NSString *FM_JOIN_ID;

@property (nonatomic,copy) NSString *TRACE_BEGIN;
@property (nonatomic,copy) NSString *TRACE_CARNO;
@property (nonatomic,copy) NSString *TRACE_END;
@property (nonatomic,copy) NSString *TRACE_INDEX2;
@property (nonatomic,copy) NSString *TRACE_INGATEID;
@property (nonatomic,copy) NSString *TRACE_INPHOTO;
@property (nonatomic,copy) NSString *TRACE_OUTGATEID;
@property (nonatomic,copy) NSString *TRACE_OUTPHOTO;

@end

NS_ASSUME_NONNULL_END
