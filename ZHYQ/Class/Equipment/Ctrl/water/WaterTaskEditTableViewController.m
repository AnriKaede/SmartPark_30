//
//  WaterTaskEditTableViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/3/9.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "WaterTaskEditTableViewController.h"

@interface WaterTaskEditTableViewController ()<UITextFieldDelegate>
{
    __weak IBOutlet UITableViewCell *_topBgView;
    
    __weak IBOutlet UITextField *_nameTF;
    
    __weak IBOutlet UITextField *_startTF;
    __weak IBOutlet UITextField *_endTF;
}
@end

@implementation WaterTaskEditTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initView];
}

- (void)_initView {
    [NavGradient viewAddGradient:_topBgView];
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveAction)];
    
    self.title = @"自动浇灌";
    
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"#EFEFEF"];
    
    _nameTF.text = _parkNightTaskModel.TASKNAME;
    
    _startTF.text = [NSString stringWithFormat:@"%.1f", _parkNightTaskModel.lowValue.floatValue];
    _endTF.text = [NSString stringWithFormat:@"%.1f", _parkNightTaskModel.upValue.floatValue];
    
    _startTF.delegate = self;
    _endTF.delegate = self;
}

- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveAction {
    [self.view endEditing:YES];
    
    // 保存
    if(_nameTF.text == nil || _nameTF.text.length <= 0){
        [self showHint:@"任务名称不能为空"];
        return;
    }
    
    if(_startTF.text == nil || _startTF.text.length <= 0){
        [self showHint:@"请设置浇灌开始条件"];
        return;
    }
    
    if(_endTF.text == nil || _endTF.text.length <= 0){
        [self showHint:@"请设置浇灌关闭条件"];
        return;
    }
    
    if(_startTF.text.floatValue > 100 || _startTF.text.floatValue < 0 || _endTF.text.floatValue > 100 || _endTF.text.floatValue < 0){
        [self showHint:@"水分比例需在0-100范围内"];
        return;
    }
    
    if(_endTF.text.floatValue < _startTF.text.floatValue){
        [self showHint:@"关闭条件水分不能低于开启条件水分"];
        return;
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/task/update", Main_Url];
    NSMutableDictionary *paramDic =@{}.mutableCopy;
    [paramDic setObject:_parkNightTaskModel.TASKID forKey:@"taskId"];
    [paramDic setObject:@"irrigation" forKey:@"deviceType"];
    [paramDic setObject:_nameTF.text forKey:@"taskName"];
    [paramDic setObject:[NSString stringWithFormat:@"%.1f", _startTF.text.floatValue] forKey:@"lowValue"];
    [paramDic setObject:[NSString stringWithFormat:@"%.1f", _endTF.text.floatValue] forKey:@"upValue"];
    [paramDic setObject:@"ON" forKey:@"jobAction"];
    [paramDic setObject:_parkNightTaskModel.ISVALID forKey:@"isValid"];
    
    NSString *paramStr = [Utils convertToJsonData:paramDic];
    NSDictionary *param =@{@"param" : paramStr};
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self showHudInView:self.view hint:nil];
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        [self hideHud];
        self.navigationItem.rightBarButtonItem.enabled = YES;
        
        if([responseObject[@"code"] isEqualToString:@"1"]){
            if(_addDelegate){
                [_addDelegate addTaskComplete];
            }
            // 成功
            // 记录修改日志
            [self logRecordUpdateTaskID:[NSString stringWithFormat:@"%@", _parkNightTaskModel.TASKID] withTaskName:_parkNightTaskModel.TASKNAME];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        
        if(responseObject[@"message"] != nil && ![responseObject[@"message"] isKindOfClass:[NSNull class]]){
            [self showHint:responseObject[@"message"]];
        }
        
    } failure:^(NSError *error) {
        [self hideHud];
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }];
    
}

#pragma mark UITableView 协议
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 5;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                    return 150;
                    break;
                    
                case 1:
                    return 60;
                    break;
                    
                default:
                    return 0;
                    break;
            }
        }
            break;
            
        case 1:
        {
            return 60;
        }
            break;
            
        default:
            return 0;
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 修改定时任务日志
- (void)logRecordUpdateTaskID:(NSString *)taskId withTaskName:(NSString *)taskName {
    // 是否修改开启和结束条件
    NSString *editStartStr = @"";
    if(_parkNightTaskModel.lowValue.floatValue != _startTF.text.floatValue){
        editStartStr = [NSString stringWithFormat:@"开启条件由%.1f%%改为%.1f%%", _parkNightTaskModel.lowValue.floatValue, _startTF.text.floatValue];
    }
    NSString *editEndStr = @"";
    if(_parkNightTaskModel.upValue.floatValue != _endTF.text.floatValue){
        editEndStr = [NSString stringWithFormat:@"关闭条件由%.1f%%改为%.1f%%", _parkNightTaskModel.upValue.floatValue, _endTF.text.floatValue];
    }
    
    NSMutableDictionary *logDic = @{}.mutableCopy;
    [logDic setObject:[NSString stringWithFormat:@"修改定时任务\"%@\"", taskName] forKey:@"operateName"];//操作动作名 说明
    [logDic setObject:[NSString stringWithFormat:@"修改定时任务\"%@\"%@ %@", taskName, editStartStr, editEndStr] forKey:@"operateDes"];//操作描述 说明
    [logDic setObject:@"task/update" forKey:@"operateUrl"];//操作url
    //    [logDic setObject:<#(nonnull id)#> forKey:@"operateLocation"];//操作地点
    //    [logDic setObject:<#(nonnull id)#> forKey:@"operateValue"];//操作值(如音量大小)
    [logDic setObject:taskId forKey:@"operateDeviceId"];//操作设备ID tagid
    [logDic setObject:@"智能浇灌" forKey:@"operateDeviceName"];//操作设备名  模块
    //    [logDic setObject:<#(nonnull id)#> forKey:@"expand1"];//扩展字段 (暂未用到)    操作前值比如音量
    
    [LogRecordObj recordLog:logDic];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return [self validateNumber:string];
}
- (BOOL)validateNumber:(NSString*)number {
    BOOL res = YES;
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
    int i = 0;
    while (i < number.length) {
        NSString * string = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) {
            res = NO;
            break;
        }
        i++;
    }
    return res;
    
    /*
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF IN {'0','1','2','3','4','5','6','7','8','9','.'}"];
    NSMutableArray *strAry = @[].mutableCopy;
    for (int i=0; i<number.length; i++) {
        [strAry addObject:[number substringWithRange:NSMakeRange(i, 1)]];
    }
    
    NSArray *filterAry = [strAry filteredArrayUsingPredicate:predicate];
    
    if(filterAry.count == strAry.count){
        return YES;
    }
    return NO;
     */
}

@end
