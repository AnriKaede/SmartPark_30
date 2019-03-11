//
//  OverLineTableView.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2019/1/11.
//  Copyright © 2019 焦平. All rights reserved.
//

#import "OverLineTableView.h"
#import "OverLineCell.h"

@interface OverLineTableView()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation OverLineTableView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self){
        [self registerNib:[UINib nibWithNibName:@"OverLineCell" bundle:nil] forCellReuseIdentifier:@"OverLineCell"];
        self.delegate = self;
        self.dataSource = self;
        self.contentInset = UIEdgeInsetsMake(4, 0, 4, 0);
    }
    return self;
}

#pragma mark UItableView协议
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _traceData.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 22;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OverLineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OverLineCell" forIndexPath:indexPath];
    cell.totalCount = _totalCount;
    
    id model = _traceData[indexPath.row];
    if([model isKindOfClass:[OverAlarmModel class]]){
        cell.alarmModel = model;
        // 严重到轻微
        NSArray *colors = @[@"#E04343",@"#FF4359",@"#FFAB27",@"#2CB093"];
        if(indexPath.row < colors.count){
            cell.colorStr = colors[indexPath.row];
        }else {
            cell.colorStr = @"#2CB093";
        }
    }else if ([model isKindOfClass:[OverCheckModel class]]){
        cell.checkModel = model;
        // 严重到轻微
        NSArray *colors = @[@"#FF4359",@"#4389E0",@"#2CB093",@"#FFAB27"];
        if(indexPath.row < colors.count){
            cell.colorStr = colors[indexPath.row];
        }else {
            cell.colorStr = @"#2CB093";
        }
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
