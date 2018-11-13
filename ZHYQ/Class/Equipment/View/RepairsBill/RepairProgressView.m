//
//  RepairProgressView.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/4/17.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "RepairProgressView.h"
#import "RepairProgressCell.h"
#import "CalculateHeight.h"

#import "BillProgressModel.h"

@interface RepairProgressView()<UITableViewDelegate, UITableViewDataSource>
{
    UITableView *_progressTableView;
    NSMutableArray *_progressData;
}
@end

@implementation RepairProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        _progressData = @[].mutableCopy;
        [self _initView];
    }
    return self;
}

- (void)_initView {
    self.hidden = YES;
    self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.6];
    
    _progressTableView = [[UITableView alloc] initWithFrame:CGRectMake(35, 82, self.width - 70, self.height - 82 - 107) style:UITableViewStylePlain];
    _progressTableView.backgroundColor = [UIColor whiteColor];
    _progressTableView.delegate = self;
    _progressTableView.dataSource = self;
    [self addSubview:_progressTableView];
    _progressTableView.showsVerticalScrollIndicator = NO;
    _progressTableView.showsHorizontalScrollIndicator = NO;
    
    _progressTableView.bounces = NO;
    _progressTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _progressTableView.layer.cornerRadius = 8;
    
    /*
    // UITableView clipsToBounds默认为YES 无法设置阴影，添加底部view实现阴影效果
    UIView *shadowBgView = [[UIView alloc] initWithFrame:_progressTableView.frame];
    shadowBgView.backgroundColor = [UIColor whiteColor];
    [self insertSubview:shadowBgView belowSubview:_progressTableView];
    shadowBgView.layer.cornerRadius = 8;
    shadowBgView.layer.shadowOffset = CGSizeMake(5, 5);
    shadowBgView.layer.shadowColor = [UIColor blackColor].CGColor;
    shadowBgView.layer.shadowOpacity = 0.7;
    shadowBgView.layer.shadowRadius = 4;
     */
    
    [_progressTableView registerNib:[UINib nibWithNibName:@"RepairProgressCell" bundle:nil] forCellReuseIdentifier:@"RepairProgressCell"];
    
    // 按钮
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake((self.width - 40)/2, _progressTableView.bottom + 34, 40, 40);
    [closeButton setBackgroundImage:[UIImage imageNamed:@"window_close_icon"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeButton];
    
}

#pragma mark 加载数据
- (void)_loadData:(NSString *)billId {
    NSString *urlStr = [NSString stringWithFormat:@"%@/deviceAlarm/handleLogs", Main_Url];
    
    NSMutableDictionary *param = @{}.mutableCopy;
    [param setObject:billId forKey:@"orderId"];
    
    NSString *jsonStr = [Utils convertToJsonData:param];
    NSDictionary *paramJson = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:paramJson progressFloat:nil succeed:^(id responseObject) {
        if(responseObject[@"code"] != nil && ![responseObject[@"code"] isKindOfClass:[NSNull class]] && [responseObject[@"code"] isEqualToString:@"1"]){
            
            NSArray *data = responseObject[@"responseData"][@"items"];
            [data enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                BillProgressModel *model = [[BillProgressModel alloc] initWithDataDic:obj];
                [_progressData addObject:model];
            }];
            
            [_progressTableView reloadData];
            
        }else if(responseObject[@"message"] != nil && ![responseObject[@"message"] isKindOfClass:[NSNull class]]){
            [[self viewController] showHint:responseObject[@"message"]];
        }
    } failure:^(NSError *error) {
        [[self viewController] showHint:KRequestFailMsg];
    }];
}

- (void)closeAction {
    [self hidProgress];
}

- (void)showProgress:(NSString *)billId {
    [_progressData removeAllObjects];
    [_progressTableView reloadData];
    
    self.hidden = NO;
    
    [self _loadData:billId];
}
- (void)hidProgress {
    self.hidden = YES;
}

#pragma mark UITableView 协议
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _progressData.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat labelHeight = 0;
    if(_progressData.count > indexPath.row){
        BillProgressModel *billProgressModel = _progressData[indexPath.row];
        if(billProgressModel.handleContent == nil || [billProgressModel.handleContent isKindOfClass:[NSNull class]]){
            return 60;
        }
        labelHeight = [CalculateHeight heightForString:billProgressModel.handleContent fontSize:16 andWidth:_progressTableView.width - 70];
    }
    return labelHeight + 40;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _progressTableView.width, 60)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, headerView.width, headerView.height - 3)];
    titleLabel.text = @"处理进度";
    titleLabel.textColor = [UIColor colorWithHexString:@"#4DAEF8"];
    titleLabel.font = [UIFont systemFontOfSize:23];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:titleLabel];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, titleLabel.bottom, headerView.width, 3)];
    lineView.backgroundColor = [UIColor colorWithHexString:@"#4DAEF8"];
    [headerView addSubview:lineView];
    
    return headerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RepairProgressCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RepairProgressCell" forIndexPath:indexPath];
    if(_progressData.count > indexPath.row){
        BillProgressModel *billProgressModel = _progressData[indexPath.row];
        if(indexPath.row == 0){
            billProgressModel.isFirst = YES;
        }else {
            billProgressModel.isFirst = NO;
        }
        if(indexPath.row == _progressData.count - 1){
            billProgressModel.isLast = YES;
        }else {
            billProgressModel.isLast = NO;
        }
        cell.billProgressModel = billProgressModel;
    }
    return cell;
}

@end
