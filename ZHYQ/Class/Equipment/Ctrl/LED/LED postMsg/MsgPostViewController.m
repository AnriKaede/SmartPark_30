//
//  MsgPostViewController.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/10.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "MsgPostViewController.h"
#import "YQInputView.h"
#import "LEDpostMsgTableViewCell.h"
#import "YQPhotoPickerView.h"
#import "YQEditImageViewController.h"

#import "ChooseLedTableViewCell.h"
#import "PostTimeTableViewCell.h"
#import "LEDmsgTitleTableViewCell.h"
#import "LEDDetailViewController.h"
#import "ClockTimeCell.h"
#import "LedListModel.h"

#define IMAGE_SIZE (KScreenWidth - 60)/4

@interface MsgPostViewController ()<UITextViewDelegate,UITableViewDelegate,UITableViewDataSource,LedPostTacticsDelegate,LEDClockTimeDelegate, ChooseLedDeleagte>
{
    NSMutableArray *_ledData;
}
/* 文本输入框*/
@property(nonatomic, strong) YQInputView *inputV;
/* UITableView*/
@property(nonatomic, strong) UITableView *tabelV;
/* 选择图片*/
@property(nonatomic, strong) YQPhotoPickerView *photoPickerV;
/* 图片编辑起*/
@property(nonatomic, strong) YQEditImageViewController *editVC;
/* 当前选择的图片*/
@property(nonatomic, strong) NSMutableArray *imageDataSource;

@property (nonatomic,strong) UIView *headerView;

@end

@implementation MsgPostViewController

-(UIView *)headerView
{
    if (_headerView == nil) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 106)];
        _headerView.backgroundColor = [UIColor clearColor];

        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100.0*hScale, 50.0*hScale)];
        [btn addTarget:self action:@selector(postLEDMsgClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.layer.cornerRadius = 4.0*hScale;
        [btn setTitle:@"确定提交" forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:17]];
        [btn setTitleColor:[UIColor colorWithHexString:@"#1B82D1"] forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor colorWithHexString:@"#FFFFFF"];
        btn.clipsToBounds = YES;
        btn.layer.borderWidth = 0.5;
        btn.layer.borderColor = [UIColor colorWithHexString:@"#6E6E6E"].CGColor;
        [_headerView addSubview:btn];
        btn.center = _headerView.center;
    }
    return _headerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _ledData = @[].mutableCopy;
    
    [self viewConfig];
    
    [self _initNavItems];
    
    [self _loadLedData];
}

-(void)_initNavItems
{
    self.title = @"发布新消息";
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIButton *rightBtn = [[UIButton alloc] init];
    rightBtn.frame = CGRectMake(0, 0, 40, 40);
    [rightBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
    [rightBtn setImage:[UIImage imageNamed:@"publiished_icon"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(_rightBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
//    self.navigationItem.rightBarButtonItem = rightItem;
    
    UITapGestureRecognizer *editTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditAction)];
    [self.view addGestureRecognizer:editTap];
}
- (void)endEditAction {
    [self.view endEditing:YES];
}

-(void)_leftBarBtnItemClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)_rightBarBtnItemClick:(id)sender
{
    LEDDetailViewController *LEDDetailVC = [[LEDDetailViewController alloc] init];
    [self.navigationController pushViewController:LEDDetailVC animated:YES];
}

// 为图片添加点击事件
//- (void)addTargetForImage{
//    for (UIButton * button in _photoPickerV.imageViews) {
//        [button addTarget:self action:@selector(addPhotos:) forControlEvents:UIControlEventTouchUpInside];
//    }
//}

- (void)viewConfig {
    __weak typeof(self) weakSelf = self;
    
    // 初始化输入视图
    _inputV = [[YQInputView alloc]init];
    _inputV.textV.delegate = self;
//    _inputV.placeholerLabel.hidden = YES;
    
//    _inputV.textV.text = @"<html><head><meta charset=utf-8><title></title></head><body><table ><tr><th style=\"color: red;\">请输入第一行内容</th></tr><tr style=\"color: red;\"><td>请输入第二行内容</td></tr></table></body></html>";
    
    // 图片选择视图
//    _photoPickerV = [[YQPhotoPickerView alloc]init];
//    _photoPickerV.frame = CGRectMake(0, _inputV.frame.size.height +10, KScreenWidth, IMAGE_SIZE);
//    _photoPickerV.reloadTableViewBlock = ^{
//        [weakSelf.tabelV reloadData];
//    };
//    [self addTargetForImage];
    
    // 初始化图片数组
//    _imageDataSource = [NSMutableArray array];
//    [_imageDataSource addObject:_photoPickerV.addImage];
    
    // 初始化图片编辑控制器
//    self.editVC = [[YQEditImageViewController alloc]init];
    
    _tabelV = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64) style:UITableViewStyleGrouped];
    _tabelV.delegate = self;
    _tabelV.dataSource = self;
    [_tabelV registerNib:[UINib nibWithNibName:@"ChooseLedTableViewCell" bundle:nil] forCellReuseIdentifier:@"ChooseLedTableViewCell"];
    [_tabelV registerNib:[UINib nibWithNibName:@"PostTimeTableViewCell" bundle:nil] forCellReuseIdentifier:@"PostTimeTableViewCell"];
    [_tabelV registerNib:[UINib nibWithNibName:@"LEDmsgTitleTableViewCell" bundle:nil] forCellReuseIdentifier:@"LEDmsgTitleTableViewCell"];
    [_tabelV registerNib:[UINib nibWithNibName:@"ClockTimeCell" bundle:nil] forCellReuseIdentifier:@"ClockTimeCell"];
    [_tabelV registerClass:[LEDpostMsgTableViewCell class] forCellReuseIdentifier:@"LEDpostMsgTableViewCell"];
    [self.view addSubview:_tabelV];
    _tabelV.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tabelV.backgroundColor = [UIColor colorWithHexString:@"E2E2E2"];
    
    self.view.backgroundColor = [UIColor clearColor];
}

/*
- (void)addPhotos:(UIButton *)button{
    
    __weak typeof(self) weakSelf = self;
    
    if ([button.currentBackgroundImage isEqual:_photoPickerV.addImage]) {
        TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:10 - _imageDataSource.count delegate:self];
        // You can get the photos by block, the same as by delegate.
        // 你可以通过block或者代理，来得到用户选择的照片.
        [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
            [_imageDataSource removeLastObject];
            [_imageDataSource addObjectsFromArray:photos];
            [_imageDataSource addObject:_photoPickerV.addImage];
            [self.photoPickerV setSelectedImages:_imageDataSource];
            [self addTargetForImage];
        }];
        [self presentViewController:imagePickerVc animated:YES completion:nil];
    }else{
        _editVC = [[YQEditImageViewController alloc]init];
        _editVC.currentOffset = (int)button.tag;
        _editVC.reloadBlock = ^(NSMutableArray * images){
            [weakSelf.photoPickerV setSelectedImages:images];
            [weakSelf addTargetForImage];
        };
        _editVC.images = _imageDataSource;
        [self.navigationController pushViewController:_editVC animated:YES];
    }
}
*/

#pragma mark --------------UITextViewDelegate
-(void)textViewDidChange:(UITextView *)textView{
    if (textView.text.length) {
        [_inputV.placeholerLabel removeFromSuperview];
    }else{
        [_inputV.textV addSubview:_inputV.placeholerLabel];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
//        [textView resignFirstResponder];
    }
    return YES;
}

#pragma mark 获取屏列表
- (void)_loadLedData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/equipment/getLedScreenList",Main_Url];
    [self showHudInView:self.tableView hint:@""];
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        [self hideHud];
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            [_ledData removeAllObjects];
            NSArray *responseData = responseObject[@"responseData"][@"ledScreenList"];
            [responseData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                LedListModel *model = [[LedListModel alloc] initWithDataDic:obj];
                [_ledData addObject:model];
            }];
            [_tabelV reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
        
    } failure:^(NSError *error) {
        [self hideHud];
        [self showHint:KRequestFailMsg];
    }];
}

#pragma mark --------------UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 1){
        return 1;
    }else{
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        ChooseLedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChooseLedTableViewCell"];
        cell.ledData = _ledData;
        cell.chooseLedDeleagte = self;
        return cell;
    }else if(indexPath.section == 1)
    {
//        if (indexPath.row == 0) {
//            LEDmsgTitleTableViewCell * cell1 = [tableView dequeueReusableCellWithIdentifier:@"LEDmsgTitleTableViewCell"];
//            return cell1;
//        }else{
            LEDpostMsgTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"LEDpostMsgTableViewCell"];
            [cell addSubview:_inputV];
//            [cell addSubview:_photoPickerV];
            return cell;
//        }
        
    }else if(indexPath.section == 2)
    {
        PostTimeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PostTimeTableViewCell"];
        cell.delegate = self;
        return cell;
    }else{
        ClockTimeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ClockTimeCell"];
        cell.delegate = self;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        CGFloat btHeight = (_ledData.count/3 + (_ledData.count%3>0 ? 1:0))*40;
        return 50 + btHeight;
    }else if(indexPath.section == 1){
//        if (indexPath.row == 0) {
//            return 60;
//        }else{
            CGFloat rowHeight = _inputV.frame.size.height;
            return rowHeight;
//        }
    }else{
        return 60;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.0001f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if(section == 1) {
        return 105.0f;
    }else {
        return 5.0f;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 1) {
        return self.headerView;
    }else{
        return [UIView new];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tabelV deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark --------------SystemVCDelegate
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [_inputV.textV resignFirstResponder];
}

#pragma mark LED发送新信息
-(void)postLEDMsgClick:(id)sender {
    NSMutableArray *selLeds = @[].mutableCopy;
    [_ledData enumerateObjectsUsingBlock:^(LedListModel *ledListModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if(ledListModel.isSelect){
            [selLeds addObject:ledListModel];
        }
    }];
    if(selLeds.count <= 0){
        [self showHint:@"请选择发布屏"];
        return;
    }
    
    if(_inputV.textV.text.length <= 0){
        [self showHint:@"请输入内容"];
        return;
    }
    
    NSArray *texts = [_inputV.textV.text componentsSeparatedByString:@"\n"];
    NSMutableString *postMsg = @"<html><head><meta charset=utf-8><title></title></head><body><table  style=\"font-size: 30px\">".mutableCopy;
    
    [texts enumerateObjectsUsingBlock:^(NSString *trText, NSUInteger idx, BOOL * _Nonnull stop) {
        [postMsg appendFormat:@"%@", [self trStr:trText]];
    }];
    [postMsg appendFormat:@"</table></body></html>"];
    
//    NSString *postMsg = [NSString stringWithFormat:@""];
    
//    NSString *postMsg = [NSString stringWithFormat:@"<html><head><meta charset=utf-8><title></title></head><body><table  border=\"1\"><tr><th style=\"color: red;\">Header 1</th></tr><tr style=\"color: red;\"><td>Row:1 Cell:1</td></tr></table></body></html>", _inputV.textV.text];
    
    
//    NSString *postMsg = _inputV.textV.text;
    
    [selLeds enumerateObjectsUsingBlock:^(LedListModel *ledListModel, NSUInteger idx, BOOL * _Nonnull stop) {
        [self sendLedMsg:ledListModel withConnect:postMsg];
    }];
}

- (NSString *)trStr:(NSString *)textStr {
    NSMutableString *trStr = @"<tr style=\"color: red;\">".mutableCopy;
    
    NSArray *tdTexts = [textStr componentsSeparatedByString:@" "];
    [tdTexts enumerateObjectsUsingBlock:^(NSString *tdText, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableString *tdStr = @"<td>".mutableCopy;
        [tdStr appendFormat:@"%@", tdText];
        [trStr appendFormat:@"</td>"];
        
        [trStr appendFormat:@"%@", tdStr];
    }];
    [trStr appendFormat:@"</tr>"];
    
    return trStr;
}

- (void)sendLedMsg:(LedListModel *)ledListModel withConnect:(NSString *)connect {
    NSString *urlStr = [NSString stringWithFormat:@"%@/udpController/sendMsgToUdpSer",Main_Url];
    NSMutableDictionary *searchParam = @{}.mutableCopy;
    [searchParam setObject:ledListModel.deviceId forKey:@"deviceId"];
    [searchParam setObject:@"SENDHTML" forKey:@"instructions"];
    [searchParam setObject:connect forKey:@"content"];
    
    [self showHudInView:self.tableView hint:@""];
    [[NetworkClient sharedInstance] POST:urlStr dict:searchParam progressFloat:nil succeed:^(id responseObject) {
        [self hideHud];
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        if(responseObject[@"message"] != nil && ![responseObject[@"message"] isKindOfClass:[NSNull class]]){
            [self showHint:responseObject[@"message"]];
        }
        
    } failure:^(NSError *error) {
        [self hideHud];
        [self showHint:KRequestFailMsg];
    }];
}

#pragma mark 选择上屏发布策略
-(void)ledPostTactics:(LEDPostTacticsType)type
{
    if (type == LEDPostTacticsDefiniteTime) {
//        nums = 4;
    }else{
//        nums = 3;
    }
    [_tabelV reloadData];
}

#pragma mark 选择定时时间
-(void)clockTimeWithTimeStr:(NSString *)time
{
    NSLog(@"%@",time);
}

#pragma mark 选择发送信息屏幕
- (void)chooseLed:(NSArray *)ledList {
    // 使用retain 不使用 copy ledList和原ledData 指向同一地址
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
