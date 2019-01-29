//
//  PFFilterContentView.m
//  ZHYQ
//
//  Created by coder on 2018/10/24.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "PFFilterContentView.h"
#import "WSDatePickerView.h"

#define ZLUnselectedColor [UIColor colorWithRed:(241)/255.0 green:(242)/255.0 blue:(243)/255.0 alpha:1.0]
#define ZLSelectedColor [UIColor colorWithRed:(128)/255.0 green:(177)/255.0 blue:(34)/255.0 alpha:1.0]

@interface PFFilterContentView ()

// 标签数组
@property (nonatomic, strong) NSArray *markArray;
// 标签字典
@property (nonatomic, strong) NSDictionary *markDict;
// 选中标签数组(数字)
@property (nonatomic, strong) NSMutableArray *selectedMarkArray;
// 选中标签数组(文字字符串)
@property (nonatomic, strong) NSMutableArray *selectedMarkStrArray;
// 标签图片名称
@property (nonatomic, strong) NSMutableArray *markImageArr;

@property (weak, nonatomic) IBOutlet UITextField *orderNumTex;
@property (weak, nonatomic) IBOutlet UITextField *carNumTex;
@property (weak, nonatomic) IBOutlet UITextField *moneyNumTex1;
@property (weak, nonatomic) IBOutlet UITextField *moneyNumTex2;
@property (weak, nonatomic) IBOutlet UILabel *paymentLab;
@property (weak, nonatomic) IBOutlet UILabel *beginTimeLab;
@property (weak, nonatomic) IBOutlet UIImageView *beginCalendarView;
@property (weak, nonatomic) IBOutlet UIImageView *endCalendarView;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLab;
@property (weak, nonatomic) IBOutlet UIButton *resetBtn;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;

@end

@implementation PFFilterContentView

#pragma mark - 懒加载

- (NSArray *)markArray {
    if (!_markArray) {
        NSArray *array = [NSArray array];
        array = @[@"全部", @"微信", @"现金", @"翼支付", @"支付宝"];
        _markArray = array;
    }
    return _markArray;
}

- (NSMutableArray *)markImageArr {
    if (!_markImageArr) {
        NSMutableArray *array = [NSMutableArray array];
        array = @[@"park_payment_all", @"park_payment_wechat", @"park_payment_cash", @"park_payment_yi", @"park_payment_alipay"].mutableCopy;
        _markImageArr = array;
    }
    return _markImageArr;
}

// 上传通过文字key取数字value发送数字
- (NSDictionary *)markDict {
    if (!_markDict) {
        NSDictionary *dict = [NSDictionary dictionary];
        dict = @{
                 @"全部" : @"0" ,
                 @"微信" : @"1",
                 @"现金" : @"2",
                 @"翼支付" : @"3",
                 @"支付宝" : @"4",
                 };
        _markDict = dict;
    }
    return _markDict;
}



- (NSMutableArray *)selectedMarkArray {
    if (!_selectedMarkArray) {
        _selectedMarkArray = [NSMutableArray array];
    }
    return _selectedMarkArray;
}

- (NSMutableArray *)selectedMarkStrArray {
    if (!_selectedMarkStrArray) {
        _selectedMarkStrArray = [NSMutableArray array];
    }
    return _selectedMarkStrArray;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    [self initView];
}

-(void)initView{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self addGestureRecognizer:tap];
    
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 5)];
    _orderNumTex.leftView = leftView;
    _orderNumTex.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *leftView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 5)];
    _carNumTex.leftViewMode = UITextFieldViewModeAlways;
    _carNumTex.leftView = leftView1;
    
    UILabel *moneyLab1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 25, 20)];
    moneyLab1.textAlignment = NSTextAlignmentCenter;
    moneyLab1.text = @"￥";
    moneyLab1.font = [UIFont systemFontOfSize:18];
    moneyLab1.textColor = [UIColor blackColor];
    
    _moneyNumTex1.leftViewMode = UITextFieldViewModeAlways;
    _moneyNumTex1.leftView = moneyLab1;
    
    UILabel *moneyLab2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 25, 20)];
    moneyLab2.textAlignment = NSTextAlignmentCenter;
    moneyLab2.text = @"￥";
    moneyLab2.font = [UIFont systemFontOfSize:18];
    moneyLab2.textColor = [UIColor blackColor];
    
    _moneyNumTex2.leftViewMode = UITextFieldViewModeAlways;
    _moneyNumTex2.leftView = moneyLab2;
    
    
    CGFloat UI_View_Width = KScreenWidth-_paymentLab.right-24;
    CGFloat marginX = 5;
    CGFloat top = 0;
    CGFloat btnH = 30;
    CGFloat marginH = 40;
    CGFloat height = 66;
    CGFloat width = (UI_View_Width - marginX * 4) / 3;
    
    // 按钮背景
    UIView *btnsBgView = [[UIView alloc] initWithFrame:CGRectMake(_paymentLab.right+12, _moneyNumTex1.bottom+10, KScreenWidth-_paymentLab.right-24, height)];
    btnsBgView.tag = 2000;
    btnsBgView.backgroundColor = [UIColor whiteColor];
    [self addSubview:btnsBgView];
    
    // 循环创建按钮
    NSInteger maxCol = 3;
    for (NSInteger i = 0; i < 5; i++) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor = ZLUnselectedColor;
        btn.tag = 3000+i;
        btn.layer.cornerRadius = 3.0; // 按钮的边框弧度
        btn.clipsToBounds = YES;
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [btn setTitleColor:[UIColor colorWithRed:(102)/255.0 green:(102)/255.0 blue:(102)/255.0 alpha:1.0] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(chooseMark:) forControlEvents:UIControlEventTouchUpInside];
        NSInteger col = i % maxCol; //列
        btn.x  = marginX + col * (width + marginX);
        NSInteger row = i / maxCol; //行
        btn.y = top + row * (btnH + marginX);
        btn.width = width;
        btn.height = btnH;
        [btn setTitle:self.markArray[i] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:self.markImageArr[i]] forState:UIControlStateNormal];
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 4, 0, 0)];
        [btn setImageEdgeInsets:UIEdgeInsetsMake(0, -4, 0, 0)];
        [btnsBgView addSubview:btn];
    }
    
    // 日历按钮点击事件
    UITapGestureRecognizer *beginCalendarTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(beginCalendar)];
    _beginTimeLab.userInteractionEnabled = YES;
    _beginCalendarView.userInteractionEnabled = YES;
    [_beginTimeLab addGestureRecognizer:beginCalendarTap];
    [_beginCalendarView addGestureRecognizer:beginCalendarTap];
    
    UITapGestureRecognizer *endCalendarTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endCalendar)];
    _endTimeLab.userInteractionEnabled = YES;
    _endCalendarView.userInteractionEnabled = YES;
    [_endTimeLab addGestureRecognizer:endCalendarTap];
    [_endCalendarView addGestureRecognizer:endCalendarTap];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    _beginTimeLab.text = [dateFormat stringFromDate:[NSDate dateYesterday]];
    _endTimeLab.text = [dateFormat stringFromDate:[NSDate date]];
}

- (void)beginCalendar {
    WSDatePickerView *datepicker = [[WSDatePickerView alloc] initWithDateStyle:DateStyleShowYearMonthDay scrollToDate:[self formatDayDate] CompleteBlock:^(NSDate *selectDate) {
        NSString *date = [selectDate stringWithFormat:@"yyyy-MM-dd"];
        _beginTimeLab.text = date;
    }];
    datepicker.dateLabelColor = [UIColor colorWithHexString:@"1B82D1"];//年-月-日-时-分 颜色
    datepicker.datePickerColor = [UIColor blackColor];//滚轮日期颜色
    datepicker.doneButtonColor = [UIColor colorWithHexString:@"1B82D1"];//确定按钮的颜色
    datepicker.yearLabelColor = [UIColor clearColor];//大号年份字体颜色
    [datepicker show];
}
- (void)endCalendar {
    WSDatePickerView *datepicker = [[WSDatePickerView alloc] initWithDateStyle:DateStyleShowYearMonthDay scrollToDate:[NSDate date] CompleteBlock:^(NSDate *selectDate) {
        NSString *date = [selectDate stringWithFormat:@"yyyy-MM-dd"];
        _endTimeLab.text = date;
    }];
    datepicker.dateLabelColor = [UIColor colorWithHexString:@"1B82D1"];//年-月-日-时-分 颜色
    datepicker.datePickerColor = [UIColor blackColor];//滚轮日期颜色
    datepicker.doneButtonColor = [UIColor colorWithHexString:@"1B82D1"];//确定按钮的颜色
    datepicker.yearLabelColor = [UIColor clearColor];//大号年份字体颜色
    [datepicker show];
}

// 前一天时间
- (NSDate *)formatDayDate {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = nil;
    comps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
    NSDateComponents *adcomps = [[NSDateComponents alloc] init];
    [adcomps setYear:0];
    [adcomps setMonth:0];
    [adcomps setDay:-1];
    NSDate *newdate = [calendar dateByAddingComponents:adcomps toDate:[NSDate date] options:0];
    
    return newdate;
}

/**
 * 按钮多选处理
 */
- (void)chooseMark:(UIButton *)btn {
    
    btn.selected = !btn.selected;
    
    UIView *btnsBgView = [self viewWithTag:2000];
    if(btn.tag == 3000){
        if(btn.isSelected){
            [self.selectedMarkArray removeAllObjects];
            [self.selectedMarkStrArray removeAllObjects];
            for (int i=1; i<5; i++) {
                UIButton *itemBt = [btnsBgView viewWithTag:3000+i];
                itemBt.backgroundColor = ZLUnselectedColor;
                itemBt.selected = NO;
            }
        }
    }else {
        UIButton *allBt = [btnsBgView viewWithTag:3000];
        [self.selectedMarkArray enumerateObjectsUsingBlock:^(NSString *str, NSUInteger idx, BOOL * _Nonnull stop) {
            if([str isEqualToString:@"0"]){
                allBt.selected = NO;
                allBt.backgroundColor = ZLUnselectedColor;
                [self.selectedMarkArray removeObjectAtIndex:idx];
            }
        }];
        [self.selectedMarkStrArray enumerateObjectsUsingBlock:^(NSString *str, NSUInteger idx, BOOL * _Nonnull stop) {
            if([str isEqualToString:@"全部"]){
                allBt.selected = NO;
                allBt.backgroundColor = ZLUnselectedColor;
                [self.selectedMarkStrArray removeObjectAtIndex:idx];
            }
        }];
    }
    
    if (btn.isSelected) {
        btn.backgroundColor = ZLSelectedColor;
        [self.selectedMarkArray addObject:self.markDict[btn.titleLabel.text]];
        [self.selectedMarkStrArray addObject:btn.titleLabel.text];
    } else {
        btn.backgroundColor = ZLUnselectedColor;
        [self.selectedMarkArray removeObject:self.markDict[btn.titleLabel.text]];
        [self.selectedMarkStrArray removeObject:btn.titleLabel.text];
    }
}

//结束编辑
-(void)tapAction
{
    [self endEditing:YES];
}

//重置
- (IBAction)resetBtnAction:(id)sender {
    if([_delegate respondsToSelector:@selector(resetBtnCallBackAction)]){
        [_delegate resetBtnCallBackAction];
    }
}

//确定
- (IBAction)sureBtnAction:(id)sender {
    if(_moneyNumTex1.text.length > 0 && _moneyNumTex2.text.length > 0 && _moneyNumTex1.text.integerValue > _moneyNumTex2.text.integerValue){
        [self.viewController showHint:@"结束时间不能小于开始时间"];
    }
    
    NSDateFormatter *showFormat = [[NSDateFormatter alloc] init];
    [showFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [showFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *showStartDate = [showFormat dateFromString:_beginTimeLab.text];
    NSDate *showEndDate = [showFormat dateFromString:_endTimeLab.text];
    
    // 结束时间不能小于开始时间
    NSComparisonResult result = [showStartDate compare:showEndDate];
    if (result == NSOrderedDescending) {
        //end比start小
        [self.viewController showHint:@"结束时间不能小于开始时间"];
        return;
    }
    
    ParkFeeFilterModel *filterModel = [[ParkFeeFilterModel alloc] init];
    filterModel.orderCode = [NSString stringWithFormat:@"%@", _orderNumTex.text];
    filterModel.carNo = [NSString stringWithFormat:@"%@", _carNumTex.text];
    filterModel.lowMoney = [NSString stringWithFormat:@"%@", _moneyNumTex1.text];
    filterModel.heightMoney = [NSString stringWithFormat:@"%@", _moneyNumTex2.text];
    filterModel.parkPayTypes = [self payTypes];
    filterModel.beginTime = [NSString stringWithFormat:@"%@", _beginTimeLab.text];
    filterModel.endTime = [NSString stringWithFormat:@"%@", _endTimeLab.text];
    
    if([_delegate respondsToSelector:@selector(completeBtnCallBackAction:)]){
        [_delegate completeBtnCallBackAction:filterModel];
    }
}

- (NSArray *)payTypes {
    NSMutableArray *pays = self.selectedMarkArray.mutableCopy;
    return pays;
}

- (void)setParkFeeFilterModel:(ParkFeeFilterModel *)parkFeeFilterModel {
    _parkFeeFilterModel = parkFeeFilterModel;
    
//    filterModel.orderCode = [NSString stringWithFormat:@"%@", _orderNumTex.text];
//    filterModel.carNo = [NSString stringWithFormat:@"%@", _carNumTex.text];
//    filterModel.lowMoney = [NSString stringWithFormat:@"%@", _moneyNumTex1.text];
//    filterModel.heightMoney = [NSString stringWithFormat:@"%@", _moneyNumTex2.text];
//    filterModel.parkPayTypes = [self payTypes];
//    filterModel.beginTime = [NSString stringWithFormat:@"%@", _beginTimeLab.text];
//    filterModel.endTime = [NSString stringWithFormat:@"%@", _endTimeLab.text];
    
    if(parkFeeFilterModel.orderCode != nil){
        _orderNumTex.text = [NSString stringWithFormat:@"%@", parkFeeFilterModel.orderCode];
    }
    if(parkFeeFilterModel.carNo != nil){
        _carNumTex.text = [NSString stringWithFormat:@"%@", parkFeeFilterModel.carNo];
    }
    if(parkFeeFilterModel.lowMoney != nil){
        _moneyNumTex1.text = [NSString stringWithFormat:@"%@", parkFeeFilterModel.lowMoney];
    }
    if(parkFeeFilterModel.heightMoney != nil){
        _moneyNumTex2.text = [NSString stringWithFormat:@"%@", parkFeeFilterModel.heightMoney];
    }
    if(parkFeeFilterModel.beginTime != nil){
        _beginTimeLab.text = [NSString stringWithFormat:@"%@", parkFeeFilterModel.beginTime];
    }
    if(parkFeeFilterModel.endTime != nil){
        _endTimeLab.text = [NSString stringWithFormat:@"%@", parkFeeFilterModel.endTime];
    }
    
    [parkFeeFilterModel.parkPayTypes enumerateObjectsUsingBlock:^(NSString *string, NSUInteger idx, BOOL * _Nonnull stop) {
        [self payType:string];
    }];
    
}

- (void)payType:(NSString *)typeStr {
    UIView *btnsBgView = [self viewWithTag:2000];
    if ([typeStr isEqualToString:@"0"]) {
        UIButton *bt = [btnsBgView viewWithTag:3000];
        [self chooseMark:bt];
    }else if ([typeStr isEqualToString:@"1"]) {
        UIButton *bt = [btnsBgView viewWithTag:3001];
        [self chooseMark:bt];
    }else if ([typeStr isEqualToString:@"2"]) {
        UIButton *bt = [btnsBgView viewWithTag:3002];
        [self chooseMark:bt];
    }else if ([typeStr isEqualToString:@"3"]) {
        UIButton *bt = [btnsBgView viewWithTag:3003];
        [self chooseMark:bt];
    }else if ([typeStr isEqualToString:@"4"]) {
        UIButton *bt = [btnsBgView viewWithTag:3004];
        [self chooseMark:bt];
    }
}

@end
