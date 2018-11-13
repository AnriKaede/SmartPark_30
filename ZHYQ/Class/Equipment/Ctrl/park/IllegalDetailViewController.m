//
//  IllegalDetailViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/12/1.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "IllegalDetailViewController.h"
#import "CalculateHeight.h"

@interface IllegalDetailViewController ()
{
    __weak IBOutlet UILabel *_carnoLabel;
    __weak IBOutlet UILabel *_timeLabel;
    __weak IBOutlet UILabel *_contentLabel;
    
    __weak IBOutlet UIImageView *_photoImgView;
    
}
@end

@implementation IllegalDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initView];
}

- (void)_initView {
    self.title = @"违停详情";
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"E2E2E2"];
    self.tableView.bounces = NO;
    
    _carnoLabel.text = _illegaListModel.illegalCarno;
    
    NSString *string = _illegaListModel.illegalCreatetime;
    NSDateFormatter *inputFormatter= [[NSDateFormatter alloc] init];
    [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [inputFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *inputDate = [inputFormatter dateFromString:string];
    NSDateFormatter *outputFormatter= [[NSDateFormatter alloc] init];
    [outputFormatter setLocale:[NSLocale currentLocale]];
    [outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *str= [outputFormatter stringFromDate:inputDate];
    
    _timeLabel.text = [NSString stringWithFormat:@"%@",str];
    
    if(_illegaListModel.illegalContent != nil && ![_illegaListModel.illegalContent isKindOfClass:[NSNull class]]){
        _contentLabel.text = [_illegaListModel.illegalContent stringByReplacingOccurrencesOfString:@"违停说明：" withString:@""];
    }
    
    if(_illegaListModel.illegalPic != nil && ![_illegaListModel.illegalPic isKindOfClass:[NSNull class]]){
        [_photoImgView sd_setImageWithURL:[NSURL URLWithString:_illegaListModel.illegalPic]];
    }
}

-(void)_leftBarBtnItemClick:(id)sender
{
//    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            if(indexPath.row == 2){
                CGFloat contentHeight = 55;
                if(_illegaListModel.illegalContent != nil && ![_illegaListModel.illegalContent isKindOfClass:[NSNull class]]){
                    contentHeight += [CalculateHeight heightForString:_illegaListModel.illegalContent fontSize:17 andWidth:KScreenWidth - 97];
                }else {
                    contentHeight += 20;
                }
                return contentHeight;
            }else {
                return 75;
            }
            break;
            
        case 1:
        {
            return 260;
            break;
        }
            
        default:
            return 0;
            break;
    }
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
    if(section == 0){
        return 8;
    }else {
        return 0.1;
    }
}

@end
