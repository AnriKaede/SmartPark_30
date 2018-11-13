//
//  DCFiltrateViewController.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/18.
//  Copyright © 2017年 焦平. All rights reserved.
//
#define FiltrateViewScreenW KScreenWidth * 0.8

#import "DCFiltrateViewController.h"

#import "DCFiltrateItem.h"
#import "DCContentItem.h"

#import "DCHeaderReusableView.h"
#import "DCFooterReusableView.h"
#import "DCAttributeItemCell.h"
#import "YQFooterReusableView.h"

#import <MJExtension.h>

@interface DCFiltrateViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    YQFooterReusableView *_footerView;
}
/* 筛选父View */
@property (strong , nonatomic) UIView *filtrateConView;
/* 已选 */
@property (strong , nonatomic) NSMutableArray *seleArray;
/* collectionView */
@property (strong , nonatomic) UICollectionView *collectView;

@property (nonatomic , strong) NSMutableArray<DCFiltrateItem *> *filtrateItem;

@end

static NSString * const DCAttributeItemCellID = @"DCAttributeItemCell";
static NSString * const YQFooterReusableViewID = @"YQFooterReusableView";
static NSString * const DCHeaderReusableViewID = @"DCHeaderReusableView";
static NSString * const DCFooterReusableViewID = @"DCFooterReusableView";

/** 常量数 */
CGFloat const DCMargin = 10;

@implementation DCFiltrateViewController

#pragma mark - LazyLoad

- (UICollectionView *)collectView
{
    if (!_collectView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.minimumLineSpacing = 10; //竖间距
        layout.itemSize = CGSizeMake((FiltrateViewScreenW - 6 * 5) / 3, 30);
        _collectView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectView.delegate = self;
        _collectView.dataSource = self;
        _collectView.alwaysBounceVertical = YES;
        _collectView.frame = CGRectMake(5, DCMargin, FiltrateViewScreenW - DCMargin, KScreenHeight - 60);
        _collectView.showsVerticalScrollIndicator = NO;
        
        [_collectView registerClass:[DCAttributeItemCell class] forCellWithReuseIdentifier:DCAttributeItemCellID];//cell
        [_collectView registerNib:[UINib nibWithNibName:NSStringFromClass([DCHeaderReusableView class]) bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:DCHeaderReusableViewID]; //头部
        [_collectView registerClass:[DCFooterReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:DCFooterReusableViewID]; //尾部
        [_collectView registerClass:[YQFooterReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:YQFooterReusableViewID]; //尾部
    }
    return _collectView;
}

- (NSMutableArray<DCFiltrateItem *> *)filtrateItem
{
    if (!_filtrateItem) {
        _filtrateItem = [NSMutableArray array];
    }
    return _filtrateItem;
}

#pragma mark - LifeCyle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpInit];
    
    [self setUpFiltrateData];
    
    [self setUpBottomButton];
}

#pragma mark - initialize
- (void)setUpInit
{
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.collectView.backgroundColor = [UIColor whiteColor];
    _filtrateConView = [UIView new];
    _filtrateConView.backgroundColor = [UIColor whiteColor];
    
    _filtrateConView.frame = CGRectMake(0, 0, FiltrateViewScreenW, KScreenHeight);
    [self.view addSubview:_filtrateConView];
    
    [_filtrateConView addSubview:self.collectView];
    
}

#pragma mark - 筛选Item数据
- (void)setUpFiltrateData
{
    /*
    NSArray *arr = @[@{@"headTitle":@"访问公司",
                       @"content":@[@{@"content":@"创发科技"},
                                    @{@"content":@"三力信息"},
                                    @{@"content":@"123"},
                                    @{@"content":@"321"},
                                    @{@"content":@"421"}]},
                     @{@"headTitle":@"访问公司",
                       @"content":@[@{@"content":@"创发科技"},
                                    @{@"content":@"三力信息"},
                                    @{@"content":@"123"},
                                    @{@"content":@"321"},
                                    @{@"content":@"421"}]},
                     @{@"headTitle":@"访问公司",
                       @"content":@[@{@"content":@"创发科技"},
                                    @{@"content":@"三力信息"},
                                    @{@"content":@"123"},
                                    @{@"content":@"321"},
                                    @{@"content":@"421"}]
                       }];
     */
    
    NSArray *arr = @[@{@"headTitle":@"",
                       @"content":@[]}];
    
    _filtrateItem = [DCFiltrateItem mj_objectArrayWithKeyValuesArray:arr];
}

#pragma mark - 底部重置确定按钮
- (void)setUpBottomButton
{
    CGFloat buttonW = FiltrateViewScreenW/2;
    CGFloat buttonH = 50;
    CGFloat buttonY = KScreenHeight - buttonH;
    NSArray *titles = @[@"重置",@"确定"];
    for (NSInteger i = 0; i < titles.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:titles[i] forState:UIControlStateNormal];
        button.tag = i;
        [button setTitleColor:(i == 0) ? [UIColor whiteColor] : [UIColor colorWithHexString:@"CCFF00"] forState:UIControlStateNormal];
        CGFloat buttonX = i*buttonW;
        button.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
        button.titleLabel.font = PFR16Font;
        button.backgroundColor = (i == 0) ? [UIColor colorWithPatternImage:[UIImage imageNamed:@"reset_btn_bg"]] : [UIColor colorWithHexString:@"1B82D1"];
        [button addTarget:self action:@selector(bottomButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [_filtrateConView addSubview:button];
    }
}

#pragma mark - <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.filtrateItem.count;
}

#pragma mark - <UICollectionViewDelegate>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filtrateItem[section].content.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    DCAttributeItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DCAttributeItemCellID forIndexPath:indexPath];
    
    DCContentItem *contentItem = _filtrateItem[indexPath.section].content[indexPath.row];
    
    cell.contentItem = contentItem;
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind  isEqualToString:UICollectionElementKindSectionHeader]) {
        
        DCHeaderReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:DCHeaderReusableViewID forIndexPath:indexPath];
        WEAKSELF
        headerView.sectionClick = ^{
            weakSelf.filtrateItem[indexPath.section].isOpen = !weakSelf.filtrateItem[indexPath.section].isOpen; //打开取反
            
            [collectionView reloadData]; //刷新
        };
        
        //给每组的header的已选label赋值~
        NSArray *array = _seleArray[indexPath.section];
        NSString *selectName = @"";
        for (NSInteger i = 0; i < array.count; i ++ ) {
            if (i == array.count - 1) {
                selectName = [selectName stringByAppendingString:[NSString stringWithFormat:@"%@",array[i]]];
            }else{
                selectName = [selectName stringByAppendingString:[NSString stringWithFormat:@"%@,",array[i]]];
            }
            
        }

        headerView.upDownButton.hidden = YES;
        headerView.selectHeadLabel.hidden = YES;
        headerView.headFiltrate = _filtrateItem[indexPath.section];
        
        return headerView;
    }else {
        
        UICollectionReusableView *view;
        
        if (indexPath.section == _filtrateItem.count-1) {
            _footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:YQFooterReusableViewID forIndexPath:indexPath];
            view = _footerView;
        }else{
            DCFooterReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:DCFooterReusableViewID forIndexPath:indexPath];
            view = footerView;
        }
        
        return view;
    }
}
#pragma mark - <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    _filtrateItem[indexPath.section].content[indexPath.row].isSelect = !_filtrateItem[indexPath.section].content[indexPath.row].isSelect;
    
    //数组mutableCopy初始化,for循环加数组 结构大致：@[@[],@[]] 如此
    _seleArray = [@[] mutableCopy];
    for (NSInteger i = 0; i < _filtrateItem.count; i++) {
        NSMutableArray *section = [@[] mutableCopy];
        [_seleArray addObject:section];
    }
    
    //把所选的每组Item分别加入每组的数组中
    for (NSInteger i = 0; i < _filtrateItem.count; i++) {
        for (NSInteger j = 0; j < _filtrateItem[i].content.count; j++) {
            if (_filtrateItem[i].content[j].isSelect == YES) {
                [_seleArray[i] addObject:_filtrateItem[i].content[j].content];
            }else{
                [_seleArray[i] removeObject:_filtrateItem[i].content[j].content];
            }
        }
    }
    
    [collectionView reloadData];
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
//    return CGSizeMake(self.collectView.width, 55);
    return CGSizeMake(self.collectView.width, 0.1);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    if (section == _filtrateItem.count-1) {
        return CGSizeMake(self.collectView.width, 200);
    }else{
        return CGSizeMake(self.collectView.width, DCMargin);
    }
}

#pragma mark - 点击事件
- (void)bottomButtonClick:(UIButton *)button
{
    if (button.tag == 0) {//重置点击
        for (NSInteger i = 0; i < _filtrateItem.count; i++) {
            for (NSInteger j = 0; j < _filtrateItem[i].content.count; j++) {
                _filtrateItem[i].content[j].isSelect = NO;
                [_seleArray[i] removeAllObjects];
            }
        }
        !_sureClickBlock ? : _sureClickBlock(_seleArray);
        [self.collectView reloadData];
        
        // 重置
        [[NSNotificationCenter defaultCenter] postNotificationName:@"VisitorResSet" object:nil userInfo:nil];
    }else if (button.tag == 1){//确定点击
        
        DLog(@"%@",_footerView.leaveTimeDetailLab.text);
        DLog(@"%@",_footerView.arriveTimeDetailLab.text);
        
        !_sureClickBlock ? : _sureClickBlock(_seleArray);
        if (_seleArray != 0) {
            for (NSInteger i = 0; i < _seleArray.count; i++) {
                NSArray *array = _seleArray[i];
                NSString *selectName = @"";
                for (NSInteger i = 0; i < array.count; i ++ ) {
                    if (i == array.count - 1) {
                        selectName = [selectName stringByAppendingString:[NSString stringWithFormat:@"%@",array[i]]];
                    }else{
                        selectName = [selectName stringByAppendingString:[NSString stringWithFormat:@"%@,",array[i]]];
                    }
                }
                if (selectName.length != 0) {
                    NSLog(@"已选：第%zd组 的 %@",i,selectName);
                }
            }
        }
        
        // 发送筛选通知
        NSDictionary *filterDic = @{@"startTime":_footerView.arriveTimeDetailLab.text,
                                    @"endTime":_footerView.leaveTimeDetailLab.text
                                    };
        [[NSNotificationCenter defaultCenter] postNotificationName:@"VisitorFilter" object:nil userInfo:filterDic];
    }
}


@end
