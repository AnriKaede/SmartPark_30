//
//  VoiceRecognitionModel.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/22.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "VoiceRecognitionModel.h"

@implementation VoiceRecognitionModel

- (instancetype)initWithDataDic:(NSDictionary *)data {
    self = [super initWithDataDic:data];
    if(self){
        NSArray *results_recognition = data[@"results_recognition"];
        if(results_recognition != nil && ![results_recognition isKindOfClass:[NSNull class]]){
            self.results_recognition = results_recognition;
        }else {
            self.results_recognition = @[];
        }
    }
    return self;
}

@end
