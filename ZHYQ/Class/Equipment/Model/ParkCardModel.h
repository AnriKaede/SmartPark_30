//
//  ParkCardModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/12/5.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface ParkCardModel : BaseModel

/*
{
    "cardId": "f04f14b4b3d811e69fe500163e0026d7",
    "cardName": "禹禄君",
    "cardPhone": "18900744368",
    "cardMemberId": null,
    "cardNo": "card1480165500759",
    "cardAgentid": "8a04a41f56bc33a20156bc33a29f0000",
    "cardParkid": "8a04a41f56bc33a20156bc3726df0004",
    "cardAreaid": "8a04a41f588f6f860158903d97e40003",
    "cardBegindate": "20151103",
    "cardExpdate": "20251103",
    "cardType": "3",
    "cardFlag": "0",
    "cardStaggerType": "1",
    "cardStaggerStart": null,
    "cardStaggerEnd": null,
    "cardUserid": null,
    "cardCtime": "20161012",
    "cardUtime": "20161012",
    "joinAgentName": null,
    "joinParkName": null,
    "joinAreaName": null,
    "joinCarNo": null,
    "cardLevel": "00",
    "cardPayType": null,
    "pcCardType": null,
    "pcId": null,
    "carNoLike": null,
    "cardTime": null,
    "updateType": null,
    "cardJobNumber": null,
    "cardUnitInfo": "其他",
    "cardRemark": null,
    "cardJobNumberLike": null,
    "cardUnitInfoLk": null
}
 */

@property (nonatomic,copy) NSString *cardId;
@property (nonatomic,copy) NSString *cardName;
@property (nonatomic,copy) NSString *cardPhone;

@end
