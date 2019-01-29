//
//  HpTopView.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/12/17.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "HpTopView.h"
#import "NavGradient.h"

@implementation HpTopView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        [self _initView];
    }
    return self;
}

- (void)_initView {
    [self createTopView];
    
    [self createScroolView];
    
    [self _loadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_loadData) name:@"HpDoorDataUpdate" object:nil];
}

- (void)createTopView {
    UIView *topBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 138*hScale)];
    topBgView.tag = 100;
    [self addSubview:topBgView];
    
    // 添加渐变色
    [NavGradient viewAddGradient:topBgView];
    
    CGFloat itemWidth = topBgView.height - 10;
    UIView *roundView = [[UIView alloc] initWithFrame:CGRectMake((KScreenWidth - itemWidth)/2, 5, itemWidth, itemWidth)];
    roundView.tag = 101;
    roundView.backgroundColor = [UIColor clearColor];
    roundView.layer.cornerRadius = itemWidth/2;
    roundView.layer.borderColor = [UIColor colorWithHexString:@"#A0D6FF"].CGColor;
    roundView.layer.borderWidth = 10;
    [topBgView addSubview:roundView];
    
    UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 30, itemWidth - 10, 25)];
    numLabel.tag = 102;
    numLabel.text = @"-";
    numLabel.textColor = [UIColor whiteColor];
    numLabel.font = [UIFont systemFontOfSize:25];
    numLabel.textAlignment = NSTextAlignmentCenter;
    [roundView addSubview:numLabel];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, numLabel.bottom + 10, itemWidth - 20, 30)];
    label.text = @"人员进出总数\n（人）";
    label.textColor = [UIColor whiteColor];
    label.numberOfLines = 2;
    label.font = [UIFont systemFontOfSize:12];
    label.textAlignment = NSTextAlignmentCenter;
    [roundView addSubview:label];
}

- (void)createScroolView {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 138*hScale, KScreenWidth, self.height - 138*hScale)];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.tag = 200;
    scrollView.backgroundColor = [UIColor colorWithHexString:@"#EFEFEF"];
    CGFloat contentWidth = 568;
    if(KScreenWidth >= 568){
        contentWidth = KScreenWidth;
    }
    scrollView.contentSize = CGSizeMake(contentWidth, 0);
    [self addSubview:scrollView];
    
    CGFloat itemWidth = contentWidth/4.0;
    NSArray *msgData = @[@"员工进出总数(人)",@"陌生人进出总数(人)",@"车辆进出(辆)",@"远程开门(人)"];
    [msgData enumerateObjectsUsingBlock:^(NSString *msg, NSUInteger idx, BOOL * _Nonnull stop) {
        CGRect frame = CGRectMake(itemWidth*idx, 0, itemWidth, scrollView.height);
        UIView *itemView = [self createItemView:frame withMessage:msg withIndex:idx];
        [scrollView addSubview:itemView];
    }];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, scrollView.bottom - 1, KScreenWidth, 1)];
    lineView.backgroundColor = [UIColor colorWithHexString:@"#BFBFBF"];
    [self addSubview:lineView];
}
- (UIView *)createItemView:(CGRect)frame withMessage:(NSString *)msg withIndex:(NSInteger)index {
    UIView *itemView = [[UIView alloc] initWithFrame:frame];
    itemView.tag = 1000+index;
    
    CGFloat itemWidth = frame.size.width;
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((itemWidth - 27)/2, 12, 27, 27)];
    if(index == 0){
        imgView.image = [UIImage imageNamed:@"hp_person_icon"];
    }else if(index == 1){
        imgView.image = [UIImage imageNamed:@"hpDoor_no_icon"];
    }else if(index == 2){
        imgView.image = [UIImage imageNamed:@"hpDoor_car_icon"];
    }else if(index == 3){
        imgView.image = [UIImage imageNamed:@"hpDoor_door_icon"];
    }
    [itemView addSubview:imgView];
    
    UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, imgView.bottom + 11, itemWidth, 20)];
    numLabel.text = @"-";
    numLabel.tag = 2000+index;
    numLabel.textColor = [UIColor colorWithHexString:@"#3699FF"];
    numLabel.font = [UIFont systemFontOfSize:18];
    numLabel.textAlignment = NSTextAlignmentCenter;
    [itemView addSubview:numLabel];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, numLabel.bottom + 8, itemWidth, 15)];
    label.text = msg;
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:14];
    label.textAlignment = NSTextAlignmentCenter;
    [itemView addSubview:label];
    
    return itemView;
}

#pragma mark 加载数据
- (void)_loadData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/fumenController/getAllTypeNum", Main_Url];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            NSArray *data = responseObject[@"responseData"];
            if(data != nil && data.count > 0){
                [self dealData:data.firstObject];
            }
        }
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}
- (void)dealData:(NSDictionary *)responseData {
    NSString *peopleNum = [self formatParam:responseData[@"peopleNum"]];
    NSString *workerNum = [self formatParam:responseData[@"workerNum"]];
    NSString *visitorNum = [self formatParam:responseData[@"visitorNum"]];
    NSString *carNum = [self formatParam:responseData[@"carNum"]];
    NSString *longOpen = [self formatParam:responseData[@"longOpen"]];
    
    UIView *topBgView = [self viewWithTag:100];
    UIView *roundView = [topBgView viewWithTag:101];
    UILabel *numLabel = [roundView viewWithTag:102];
    numLabel.text = peopleNum;
    
    NSArray *dataAry = @[workerNum,visitorNum,carNum,longOpen];
    
    UIScrollView *scrollView = [self viewWithTag:200];
    [dataAry enumerateObjectsUsingBlock:^(NSString *num, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView *itemView = [scrollView viewWithTag:1000+idx];
        UILabel *numLabel = [itemView viewWithTag:2000+idx];
        numLabel.text = num;
    }];
    
}
- (NSString *)formatParam:(id)param {
    if(param != nil && ![param isKindOfClass:[NSNull class]]){
        return [NSString stringWithFormat:@"%@", param];
    }else {
        return @"";
    }
}

@end
