//
//  AirBatchCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/7/16.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "AirBatchCell.h"
#import "AirRoomModel.h"

@implementation AirBatchCell
{
    __weak IBOutlet UILabel *_floorLabel;
    __weak IBOutlet UILabel *_roomLabel;
    
    __weak IBOutlet UIButton *_selFlagBt;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.contentView.backgroundColor = [UIColor colorWithHexString:@"#F5F5F5"];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _roomLabel.font = [UIFont fontWithName:@"Monaco" size:17];
}

- (IBAction)selBt:(id)sender {
    _selFlagBt.selected = !_selFlagBt.selected;
    if(_layerSelDelegate && [_layerSelDelegate respondsToSelector:@selector(selLayer:withOn:)]){
        [_layerSelDelegate selLayer:_airLayerModel withOn:_selFlagBt.selected];
    }
}

- (void)setAirLayerModel:(AirLayerModel *)airLayerModel {
    _airLayerModel = airLayerModel;
    
    _floorLabel.text = airLayerModel.layerName;
    
    NSMutableString *roomsStr = @"".mutableCopy;
    __block NSInteger count = 0;
    int item = (KScreenWidth - 159)/70 - 1;
    [airLayerModel.rooms enumerateObjectsUsingBlock:^(AirRoomModel *roomModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if(count >= item || roomModel.roomName.length > 5){
            [roomsStr appendFormat:@"%@\n", roomModel.roomName];
            count = 0;
        }else {
            [roomsStr appendFormat:@"%@  ", roomModel.roomName];
            count ++;
        }
    }];
    _roomLabel.text = roomsStr;
    
    _selFlagBt.selected = airLayerModel.isSelect;
    
    // 固定宽度
    [self setLabelSpace:_roomLabel withValue:_roomLabel.text withFont:_roomLabel.font];
}

#define UILABEL_LINE_SPACE 1
#define UILABEL_CHAR_SPACE 1.5
#define HEIGHT [[UIScreen mainScreen] bounds].size.height

//给UILabel设置行间距和字间距

-(void)setLabelSpace:(UILabel*)label withValue:(NSString*)str withFont:(UIFont*)font {
    
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paraStyle.alignment = NSTextAlignmentLeft;
    paraStyle.lineSpacing = UILABEL_LINE_SPACE; //设置行间距
    paraStyle.hyphenationFactor = 1.0;
    paraStyle.firstLineHeadIndent = 0.0;
    paraStyle.paragraphSpacingBefore = 0.0;
    paraStyle.headIndent = 0;
    paraStyle.tailIndent = 0;
    
    //设置字间距 NSKernAttributeName:@1.5f
    NSDictionary *dic = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paraStyle, NSKernAttributeName:@UILABEL_CHAR_SPACE
                          };
    NSAttributedString *attributeStr = [[NSAttributedString alloc] initWithString:str attributes:dic];
    label.attributedText = attributeStr;
    
}


//计算UILabel的高度(带有行间距的情况)

-(CGFloat)getSpaceLabelHeight:(NSString*)str withFont:(UIFont*)font withWidth:(CGFloat)width {
    
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paraStyle.alignment = NSTextAlignmentLeft;
    paraStyle.lineSpacing = UILABEL_LINE_SPACE;
    paraStyle.hyphenationFactor = 1.0;
    paraStyle.firstLineHeadIndent = 0.0;
    paraStyle.paragraphSpacingBefore = 0.0;
    paraStyle.headIndent = 0;
    paraStyle.tailIndent = 0;
    NSDictionary *dic = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paraStyle, NSKernAttributeName:@UILABEL_CHAR_SPACE
                          };
    
    CGSize size = [str boundingRectWithSize:CGSizeMake(width, HEIGHT) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    
    return size.height;
    
}

@end
