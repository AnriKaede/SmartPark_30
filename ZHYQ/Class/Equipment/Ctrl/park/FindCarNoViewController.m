//
//  FindCarNoViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/5/3.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "FindCarNoViewController.h"
#import "CRSearchBar.h"
#import "FindCarCell.h"

#import "FindCarNoModel.h"

#import "NoDataView.h"

#import "InputKeyBoardView.h"
#import "NumInputView.h"

#import "ParkRecordCenViewController.h"

#import "UITextField+Position.h"

@interface FindCarNoViewController ()<UITableViewDelegate, UITableViewDataSource, CYLTableViewPlaceHolderDelegate>
{
    __weak IBOutlet UITextField *_searchTF;
    
    __weak IBOutlet UITableView *_carListTableView;
    
    NSMutableArray *_listData;
    
    int _length;
    int _page;
    
    InputKeyBoardView *_keyBoardView;
    NumInputView *_numInputView;
}
@end

@implementation FindCarNoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _listData = @[].mutableCopy;
    
    _length = 8;
    _page = 1;
    
    [self _initView];
}

-(void)_initView
{
    self.title = @"车牌查询";
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"#E2E2E2"];
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    [_searchTF becomeFirstResponder];
    
    _carListTableView.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    _carListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_carListTableView registerNib:[UINib nibWithNibName:@"FindCarCell" bundle:nil] forCellReuseIdentifier:@"FindCarCell"];
    
    // ios 11tableView闪动
    _carListTableView.estimatedRowHeight = 0;
    _carListTableView.estimatedSectionHeaderHeight = 0;
    _carListTableView.estimatedSectionFooterHeight = 0;
    
    _carListTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        _page ++;
        [self _loadData];
    }];
//    _carListTableView.mj_footer.automaticallyHidden = NO;
    _carListTableView.mj_footer.hidden = YES;
    
    [self _initKeyBoradInput];
}

- (void)_initKeyBoradInput {
    // 设置自定义键盘
    int verticalCount = 5;
    CGFloat kheight = KScreenWidth/10 + 8;
    _keyBoardView = [[InputKeyBoardView alloc] initWithFrame:CGRectMake(0, KScreenHeight - kheight * verticalCount, KScreenWidth, kheight * verticalCount) withClickKeyBoard:^(NSString *character) {
        
        NSString *textStr = [_searchTF.text stringByAppendingString:character];
        if(textStr.length <= 8){
            [self judgementKeyBorad:textStr];
            [_searchTF positionAddCharacter:character];
        }
        
        
    } withDelete:^{
        if(_searchTF.text.length > 0){
            [self positionDelete];
            [self judgementKeyBorad:_searchTF.text];
        }
    } withConfirm:^{
        [self searchClicked];
    } withCut:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            _searchTF.inputView = _numInputView;
            [_searchTF reloadInputViews];
        });
    }];
    [_keyBoardView setNeedsDisplay];
    _searchTF.inputView = _keyBoardView;
    
    _numInputView = [[NumInputView alloc] initWithFrame:CGRectMake(0, KScreenHeight - kheight * verticalCount, KScreenWidth, kheight * verticalCount) withClickKeyBoard:^(NSString *character) {
        
        NSString *textStr = [_searchTF.text stringByAppendingString:character];
        if(textStr.length <= 8){
            [self judgementKeyBorad:textStr];
            [_searchTF positionAddCharacter:character];
//            if(textStr.length == 7){
//                [self searchClicked];
//            }
        }
        
    } withDelete:^{
        // 依次删除
        if(_searchTF.text.length > 0){
            [self positionDelete];
            [self judgementKeyBorad:_searchTF.text];
        }
    } withConfirm:^{
        [self searchClicked];
    } withCut:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            _searchTF.inputView = _keyBoardView;
            [_searchTF reloadInputViews];
        });
    }];
    [_numInputView setNeedsDisplay];

}
// 删除光标位置字符
- (void)positionDelete {
    NSRange range = [_searchTF selectedRange];
    NSString *frontStr;
    if(range.location > 0){
        frontStr = [_searchTF.text substringWithRange:NSMakeRange(0, range.location-1)];
    }else {
        frontStr = @"";
    }
    NSString *afterStr = [_searchTF.text substringWithRange:NSMakeRange(range.location, _searchTF.text.length - range.location)];
    
    _searchTF.text = [NSString stringWithFormat:@"%@%@", frontStr, afterStr];
    // 重新定位光标
    [_searchTF setSelectedRange:NSMakeRange(range.location-1, 0)];
}

- (void)judgementKeyBorad:(NSString *)textStr {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(textStr.length > 0){
            _searchTF.inputView = _numInputView;
            [_searchTF reloadInputViews];
        }else{
            _searchTF.inputView = _keyBoardView;
            [_searchTF reloadInputViews];
        }
    });
}

- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 点击搜索协议
- (void)searchClicked {
    [self.view endEditing:YES];
    
    if(_searchTF.text.length <= 0){
        [self showHint:@"搜索内容不能为空"];
        return;
    }
    
    [_carListTableView setContentOffset:CGPointMake(0, 0) animated:NO];
    [_listData removeAllObjects];
    _page = 1;
    [self _loadData];
}

#pragma mark UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *textStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if(textStr.length <= 2 && textField.text.length > 2){
        _searchTF.inputView = _keyBoardView;
    }else if(textStr.length > 2 && textField.text.length <= 2){
        _searchTF.inputView = _numInputView;
    }
    
    return YES;
}

- (void)_loadData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/parking/getCarInfo", Main_Url];
    
    NSMutableDictionary *param = @{}.mutableCopy;
    [param setObject:_searchTF.text forKey:@"carNo"];
    [param setObject:[NSNumber numberWithInt:_page] forKey:@"pageNumber"];
    [param setObject:[NSNumber numberWithInt:_length] forKey:@"pageSize"];
    
    NSString *jsonStr = [Utils convertToJsonData:param];
    NSDictionary *paramJson = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:paramJson progressFloat:nil succeed:^(id responseObject) {
        [self removeNoDataImage];
        
        [_carListTableView.mj_footer endRefreshing];
        if(responseObject[@"code"] != nil && ![responseObject[@"code"] isKindOfClass:[NSNull class]] && [responseObject[@"code"] isEqualToString:@"1"]){
            
            NSArray *data = responseObject[@"responseData"];
            if(data.count > _length-1){
                _carListTableView.mj_footer.state = MJRefreshStateIdle;
                _carListTableView.mj_footer.hidden = NO;
            }else {
                _carListTableView.mj_footer.state = MJRefreshStateNoMoreData;
                _carListTableView.mj_footer.hidden = YES;
            }
            [data enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                FindCarNoModel *model = [[FindCarNoModel alloc] initWithDataDic:obj];
                [_listData addObject:model];
            }];
            
            [_carListTableView cyl_reloadData];
            
        }else if(responseObject[@"message"] != nil && ![responseObject[@"message"] isKindOfClass:[NSNull class]]){
            [self showHint:responseObject[@"message"]];
        }
    } failure:^(NSError *error) {
        [_carListTableView.mj_footer endRefreshing];
        
        if(_listData.count <= 0){
            [self showNoDataImage];
        }else {
            [self showHint:KRequestFailMsg];
        }
    }];
    
}

// 无网络重载
- (void)reloadTableData {
    [self _loadData];
}

#pragma mark 无数据协议
- (UIView *)makePlaceHolderView {
    NoDataView *noDateView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight-64-49)];
    return noDateView;
}

#pragma mark UITableVIew 协议
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _listData.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 160;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 6;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FindCarCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FindCarCell" forIndexPath:indexPath];
    if(_listData.count > indexPath.section){
        cell.findCarNoModel = _listData[indexPath.section];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 查询车牌停车记录
    ParkRecordCenViewController *parkRecordCenVC = [[ParkRecordCenViewController alloc] init];
    FindCarNoModel *findCarNoModel = _listData[indexPath.section];
    parkRecordCenVC.carNo = [NSString stringWithFormat:@"%@", findCarNoModel.CAR_NO];
    [self.navigationController pushViewController:parkRecordCenVC animated:YES];
}

@end
