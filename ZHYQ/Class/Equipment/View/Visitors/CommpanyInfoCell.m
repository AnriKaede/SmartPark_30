//
//  CommpanyInfoCell.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/18.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "CommpanyInfoCell.h"

#import "VisotorListViewController.h"

@interface CommpanyInfoCell()

@property (weak, nonatomic) IBOutlet UIView *visitorView;

@end

@implementation CommpanyInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.contentView.backgroundColor = [UIColor colorWithHexString:@"1B82D1"];
    
    [self _initView];
}

-(void)_initView
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [_visitorView addGestureRecognizer:tap];
    
    CAShapeLayer *layer = [CAShapeLayer new];
    layer.lineWidth = 2;
    //圆环的颜色
    layer.strokeColor = [UIColor whiteColor].CGColor;
    //背景填充色
    layer.fillColor = [UIColor clearColor].CGColor;
    //设置半径为10
    CGFloat radius = 60;
    //按照顺时针方向
    BOOL clockWise = true;
    //初始化一个路径
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(KScreenWidth/2, 75) radius:radius startAngle:(0*M_PI) endAngle:2.0f*M_PI clockwise:clockWise];
    layer.path = [path CGPath];
    [self.contentView.layer addSublayer:layer];
}

-(void)tapAction:(id)sender
{
    VisotorListViewController *visitorVC = [[VisotorListViewController alloc] init];
    [[self viewController].navigationController pushViewController:visitorVC animated:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
