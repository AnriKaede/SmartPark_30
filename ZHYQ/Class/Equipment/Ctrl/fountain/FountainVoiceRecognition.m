//
//  FountainVoiceRecognition.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/23.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "FountainVoiceRecognition.h"

@implementation FountainVoiceRecognition

+ (NSArray *)recognitionResult:(NSString *)result {
    /**
     开 所有喷泉
     关 所有喷泉
     开 1/2/3/4/5号喷泉
     关 1/2/3/4/5号喷泉
     按以上优先级判断
     */
    
    BOOL isOpen = [result containsString:@"开"];
    BOOL isClose = [result containsString:@"关"];
    
    BOOL allFountain = [result containsString:@"所有"];
    BOOL allFountain2 = [result containsString:@"全部"];
    BOOL allFountain3 = [result containsString:@"都"];
    
//    BOOL includeFountain = [result containsString:@"喷泉"];
    
    BOOL includeOne = [result containsString:@"1"];
    BOOL includeOne2 = [result containsString:@"一"];
    
    BOOL includeTow = [result containsString:@"2"];
    BOOL includeTow2 = [result containsString:@"二"];
    
    BOOL includeThree = [result containsString:@"3"];
    BOOL includeThree2 = [result containsString:@"三"];
    
    BOOL includeFour = [result containsString:@"4"];
    BOOL includeFour2 = [result containsString:@"四"];
    
    BOOL includeFive = [result containsString:@"5"];
    BOOL includeFive2 = [result containsString:@"五"];
    
    NSArray *boolArys = @[[NSNumber numberWithBool:includeOne || includeOne2],[NSNumber numberWithBool:includeTow || includeTow2],[NSNumber numberWithBool:includeThree || includeThree2],[NSNumber numberWithBool:includeFour || includeFour2],[NSNumber numberWithBool:includeFive || includeFive2]];
    
    if(isOpen && !isClose){
        // 开
        NSMutableArray *conArys = @[].mutableCopy;
        __block BOOL noIclude = YES;
        [boolArys enumerateObjectsUsingBlock:^(NSNumber *boolNum, NSUInteger idx, BOOL * _Nonnull stop) {
            if(boolNum.boolValue){
                // 有对应编号指令
                noIclude = NO;
                [conArys addObject:@1];
            }else {
                [conArys addObject:@0];
            }
        }];
        
        if(noIclude){
            // 无对应编号指令，判断是否是全部控制
            if(allFountain || allFountain2 || allFountain3){
                // 全部控制
                return @[@1,@1,@1,@1,@1];
            }else {
                // 无效
                return @[@0,@0,@0,@0,@0];
            }
        }else {
            // 包含对应编号控制
            return conArys;
        }
        
    }else if (!isOpen && isClose) {
        // 关
        NSMutableArray *conArys = @[].mutableCopy;
        __block BOOL noIclude = YES;
        [boolArys enumerateObjectsUsingBlock:^(NSNumber *boolNum, NSUInteger idx, BOOL * _Nonnull stop) {
            if(boolNum.boolValue){
                // 有对应编号指令
                noIclude = NO;
                [conArys addObject:@2];
            }else {
                [conArys addObject:@0];
            }
        }];
        
        if(noIclude){
            // 无对应编号指令，判断是否是全部控制
            if(allFountain || allFountain2 || allFountain3){
                // 全部控制
                return @[@2,@2,@2,@2,@2];
            }else {
                // 无效
                return @[@0,@0,@0,@0,@0];
            }
        }else {
            // 包含对应编号控制
            return conArys;
        }
    }else {
        // 无效
        return @[@0,@0,@0,@0,@0];
    }
}

@end
