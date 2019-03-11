//
//  EquipmQueryCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/12/27.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "EquipmQueryCell.h"

@implementation EquipmQueryCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self _initView];
    }
    return self;
}

- (void)_initView {
    CGFloat itemWidth = KScreenWidth/4;
    for (int i=0; i<4; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i*itemWidth, 0, itemWidth, self.contentView.height)];
        label.tag = 1000+i;
        label.text = @"-";
        label.numberOfLines = 2;
        label.textColor = [UIColor blackColor];
        label.font = [UIFont systemFontOfSize:15];
        label.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:label];
    }
}

- (void)setInfoModel:(CommncInfoModel *)infoModel {
    _infoModel = infoModel;
    
    UILabel *codeLabel = [self.contentView viewWithTag:1000];
    codeLabel.text = [NSString stringWithFormat:@"%@", infoModel.serviceId];
    
    UILabel *nameLabel = [self.contentView viewWithTag:1001];
    nameLabel.text = [NSString stringWithFormat:@"%@", infoModel.serviceName];
    
    UILabel *valueLabel = [self.contentView viewWithTag:1002];
    valueLabel.text = [NSString stringWithFormat:@"%@", infoModel.serviceValue];
    
    UILabel *timeLabel = [self.contentView viewWithTag:1003];
    timeLabel.text = [NSString stringWithFormat:@"%@", infoModel.reporTime];
    
}

@end
