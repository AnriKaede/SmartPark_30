//
//  AirTableViewCell.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/9.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "AirTableViewCell.h"
#import "TimeSetTableViewController.h"

@implementation AirTableViewCell
{
    __weak IBOutlet UILabel *_nameLabel;
    
    __weak IBOutlet UIButton *_outModelBt;
    __weak IBOutlet UIButton *_inModelBt;
    
    __weak IBOutlet UIView *_clockBgView;
    __weak IBOutlet UILabel *_clockLabel;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UITapGestureRecognizer *clockTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clockAction)];
    [_clockBgView addGestureRecognizer:clockTap];
    
}

// 点击设置闹钟
- (void)clockAction {
    TimeSetTableViewController *timeSetVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"TimeSetTableViewController"];
    [[self viewController].navigationController pushViewController:timeSetVC animated:YES];
}

- (void)setAirModel:(AirModel *)airModel {
    _airModel = airModel;
    
    _nameLabel.text = airModel.DEVICE_NAME;
}

- (IBAction)outModel:(id)sender {
    _outModelBt.selected = YES;
    _inModelBt.selected = NO;
}

- (IBAction)inModel:(id)sender {
    _inModelBt.selected = YES;
    _outModelBt.selected = NO;
}

@end
