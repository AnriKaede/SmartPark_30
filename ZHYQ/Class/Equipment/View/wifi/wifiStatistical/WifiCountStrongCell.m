//
//  WifiCountStrongCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/10/26.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "WifiCountStrongCell.h"
#import "WifiCountStrongModel.h"

@implementation WifiCountStrongCell
{
    __weak IBOutlet UILabel *_oneValueLabel;
    __weak IBOutlet UILabel *_twoValueLabel;
    __weak IBOutlet UILabel *_threeValueLabel;
    __weak IBOutlet UILabel *_fourValueLabel;
    
    __weak IBOutlet UILabel *_oneRangeLabel;
    __weak IBOutlet UILabel *_twoRangeLabel;
    __weak IBOutlet UILabel *_threeRangeLabel;
    __weak IBOutlet UILabel *_fourRangeLabel;
    
    __weak IBOutlet NSLayoutConstraint *_oneWidth;
    __weak IBOutlet NSLayoutConstraint *_twoWidth;
    __weak IBOutlet NSLayoutConstraint *_threeWidth;
    __weak IBOutlet NSLayoutConstraint *_fourWidth;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setStrongData:(NSArray *)strongData {
    strongData = [self sortByX:strongData];
    
    strongData = [self sortByStrong:strongData];
    _strongData = strongData;
    
    NSArray *rangeLabels = @[_oneRangeLabel, _twoRangeLabel, _threeRangeLabel, _fourRangeLabel];
    __block CGFloat allNum = 0;
    [strongData enumerateObjectsUsingBlock:^(WifiCountStrongModel *strongModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if(rangeLabels.count > idx){
            UILabel *label = rangeLabels[idx];
            if(idx == strongData.count - 1){
                label.text = [NSString stringWithFormat:@"< %@dbm", strongModel.signalStringth];
            }else {
                WifiCountStrongModel *nextModel = strongData[idx+1];
                label.text = [NSString stringWithFormat:@"%@dbm~%@dbm", strongModel.signalStringth, nextModel.signalStringth];
            }
        }
        
        allNum += strongModel.userCount.integerValue;
    }];
    
    NSArray *valueLabels = @[_oneValueLabel, _twoValueLabel, _threeValueLabel, _fourValueLabel];
    NSArray *widthCons = @[_oneWidth, _twoWidth, _threeWidth, _fourWidth];
    CGFloat allWidth = KScreenWidth-20;
    [strongData enumerateObjectsUsingBlock:^(WifiCountStrongModel *strongModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if(widthCons.count > idx){
            NSLayoutConstraint *widthCon = widthCons[idx];
            widthCon.constant = strongModel.userCount.floatValue/allNum * allWidth;
            
            UILabel *valueLabel = valueLabels[idx];
            if(strongModel.userCount.integerValue == 0){
                valueLabel.hidden = YES;
            }else {
                valueLabel.hidden = NO;
                valueLabel.text = [NSString stringWithFormat:@"  %@\n%.0f%%", strongModel.userCount, strongModel.userCount.floatValue/allNum*100];
            }
        }
        
    }];
    
}

- (NSArray *)sortByStrong:(NSArray *)data {
    NSMutableArray *sortData = data.mutableCopy;
    [sortData enumerateObjectsUsingBlock:^(WifiCountStrongModel *strongModel, NSUInteger idx, BOOL * _Nonnull stop) {
        for (NSInteger i=idx; i<data.count; i++) {
            WifiCountStrongModel *iStrongModel = sortData[i];
            if(strongModel.signalStringth.floatValue < iStrongModel.signalStringth.floatValue){
                [sortData exchangeObjectAtIndex:idx withObjectAtIndex:i];
                strongModel = iStrongModel;
            }
        }
    }];
    return sortData;
}

- (NSArray *)sortByX:(NSArray *)data {
    NSMutableArray *sortData = data.mutableCopy;
    [sortData enumerateObjectsUsingBlock:^(WifiCountStrongModel *speedModel, NSUInteger idx, BOOL * _Nonnull stop) {
        for (NSInteger i=idx; i<data.count; i++) {
            WifiCountStrongModel *iSpeedModel = sortData[i];
            if(iSpeedModel.signalStringth.floatValue < speedModel.signalStringth.floatValue){
                [sortData exchangeObjectAtIndex:idx withObjectAtIndex:i];
            }
        }
    }];
    return sortData;
}

@end
