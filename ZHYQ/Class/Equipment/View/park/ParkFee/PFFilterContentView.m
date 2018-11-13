//
//  PFFilterContentView.m
//  ZHYQ
//
//  Created by coder on 2018/10/24.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "PFFilterContentView.h"

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
    btnsBgView.backgroundColor = [UIColor whiteColor];
    [self addSubview:btnsBgView];
    
    // 循环创建按钮
    NSInteger maxCol = 3;
    for (NSInteger i = 0; i < 5; i++) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor = ZLUnselectedColor;
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
}

/**
 * 按钮多选处理
 */
- (void)chooseMark:(UIButton *)btn {
    
    btn.selected = !btn.selected;
    
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
    
}

//确定
- (IBAction)sureBtnAction:(id)sender {
    
}


@end
