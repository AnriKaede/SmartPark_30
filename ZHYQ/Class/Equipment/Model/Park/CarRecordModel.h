//
//  CarRecordModel.h
//  XTF_SmartPart_UserTerminal
//
//  Created by 魏唯隆 on 2017/12/13.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface CarRecordModel : BaseModel

/*
 {
     "TRACE_AGENTID": "8a04a41f56bc33a20156bc33a29f0000",
     "TRACE_AGENTNAME": "湖南通服运营商",
     "TRACE_AREA": "8a04a41f56bc33a20156bc3726df0006",
     "TRACE_BEGIN": "20180529082106",
     "TRACE_CARD_ID": "8a2b7a9662e376100162e5b1f9d4054e",
     "TRACE_CARNO": "湘B1ST23",
     "TRACE_CARNOCOLOR": "蓝",
     "TRACE_CARTYPE": "0",
     "TRACE_CASH": 0,
     "TRACE_END": "20180529191431",
     "TRACE_INDEX2": "2018052908210650000072000067254435",
     "TRACE_INGATEID": "8a04a41f56bc33a20156bc3a914c000b",
     "TRACE_INOPERNO": 50000072,
     "TRACE_INPHOTO": "http://115.29.51.72:8081/file/park/hzcl/20180529/湘B1ST23-2018-05-29-08-21-06-b.jpg",
     "TRACE_INSMALL_PHOTO": "http://115.29.51.72:8081/file/park/hzcl/20180529/湘B1ST23-2018-05-29-08-21-06-s.jpg",
     "TRACE_ISREVIEW": "0",
     "TRACE_MEMBER_ID": "8a21dd2c60927fe70160960438260003",
     "TRACE_NOTCASH": 0,
     "TRACE_OUTGATEID": "8a04a41f56bc33a20156bc3ac78f000d",
     "TRACE_OUTOPERATE": "00",
     "TRACE_OUTOPERNO": 50000072,
     "TRACE_OUTPHOTO": "http://115.29.51.72:8081/file/park/hzcl/20180529/湘B1ST23-2018-05-29-19-14-31-b.jpg",
     "TRACE_OUTSMALL_PHOTO": "http://115.29.51.72:8081/file/park/hzcl/20180529/湘B1ST23-2018-05-29-19-14-31-s.jpg",
     "TRACE_OUTTYPE": "1",
     "TRACE_PARKAMT": 0,
     "TRACE_PARKID": "8a04a41f56bc33a20156bc3726df0004",
     "TRACE_PARKNAME": "通服天园停车场",
     "TRACE_PAYDATE": "20180529191431",
     "TRACE_PREAMT": 0,
     "TRACE_RESULT": "00",
     "TRACE_SEATCODE1": "000000",
     "TRACE_SEATNO1": "0000",
     "TRACE_SETTLEDATE": "-------",
     "TRACE_SYSBATCH": "",
     "TRACE_SYSTRACE": "",
     "TRACE_TIME": 653,
     "TRACE_UPDATETIME": "20180529190922",
     "TRACE_WARNING": ""
 }

 */

@property (nonatomic,copy) NSString *TRACE_INDEX2;
@property (nonatomic,copy) NSString *TRACE_CARNO;
@property (nonatomic,copy) NSString *TRACE_BEGIN;
@property (nonatomic,copy) NSString *TRACE_END;
@property (nonatomic,strong) NSNumber *TRACE_TIME;
@property (nonatomic,copy) NSString *TRACE_RESULT;   // 66 90 未出场  00 出场
@property (nonatomic,copy) NSString *TRACE_INPHOTO;
@property (nonatomic,copy) NSString *TRACE_OUTPHOTO;
@property (nonatomic,copy) NSString *TRACE_PARKNAME;

@end
