//
//  VoiceRecognitionModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/22.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface VoiceRecognitionModel : BaseModel
/*
{
    "results_recognition" : [
                             "开灯"
                             ],
    "origin_result" : {
        "result" : {
            "word" : [
                      "开灯"
                      ]
        },
        "sn" : "86EDF50A-1631-4E05-B3D9-8BE19694CFBC",
        "corpus_no" : 6626496516228745438,
        "voice_energy" : 32060.572265625,
        "err_no" : 0
    }
}
*/

@property (nonatomic,copy) NSArray *results_recognition;

@end

NS_ASSUME_NONNULL_END
