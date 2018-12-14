//
//  EveMenuView.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/12/9.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "EveMenuView.h"
#import "EnvInfoModel.h"

@interface EveMenuView()
{
    UIView *_bgView;
}
@end

@implementation EveMenuView

- (instancetype)init {
    self = [super initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
    if(self){
        [self _initView];
    }
    return self;
}

- (void)_initView {
    self.hidden = YES;
    self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.5];
    
    UITapGestureRecognizer *hidTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidMenu)];
    [self addGestureRecognizer:hidTap];
    
    [[UIApplication sharedApplication].delegate.window addSubview:self];
    
    _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, KScreenHeight - 250, KScreenWidth, 250)];
    _bgView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_bgView];
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 50)];
    titleView.backgroundColor = [UIColor whiteColor];
    [_bgView addSubview:titleView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.frame = CGRectMake(50,15,KScreenWidth - 100,20);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"环境监测";
    titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:20];
    titleLabel.textColor = [UIColor colorWithRed:0/255 green:0/255 blue:0/255 alpha:1];
    [titleView addSubview:titleLabel];
    
    UIButton *closeBt = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBt.frame =CGRectMake(KScreenWidth - 40, 10, 30, 30);
    [closeBt setBackgroundImage:[UIImage imageNamed:@"show_menu_close"] forState:UIControlStateNormal];
    [closeBt addTarget:self action:@selector(hidMenu) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:closeBt];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, titleView.height - 0.5, KScreenWidth, 0.5)];
    lineView.backgroundColor = [UIColor colorWithHexString:@"#BEBEBE"];
    [titleView addSubview:lineView];
    
    CGFloat itemWidth = KScreenWidth/4;
    NSArray *imgs = @[@"eve_多云", @"eve_water", @"eve_noise", @"eve_pm", @"wind_direction_icon", @"wind_speed_icon", @"pressure_icon", @"PM10"];
    for (int i=0; i<8; i++) {
        UIView *itemView = [[UIView alloc] initWithFrame:CGRectMake(i%4*itemWidth, i/4*70 + titleView.bottom, itemWidth, 70)];
        itemView.tag = 3000 + i;
        [_bgView addSubview:itemView];
        
        UIImageView *iconImgView = [[UIImageView alloc] init];
        iconImgView.tag = 4000+i;
        if(i == 0){
            iconImgView.frame = CGRectMake((itemWidth - 24)/2, 23, 20, 20);
        }else {
            iconImgView.frame = CGRectMake((itemWidth - 24)/2, 23, 24, 20);
        }
        iconImgView.image = [UIImage imageNamed:imgs[i]];
        [itemView addSubview:iconImgView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, iconImgView.bottom + 13, itemWidth, 17)];
        label.tag = 5000+i;
        label.text = @"-";
        if(i == 3){
            label.textColor = [UIColor colorWithHexString:@"#FF4359"];
        }else {
            label.textColor = [UIColor blackColor];
        }
        label.font = [UIFont systemFontOfSize:17];
        label.textAlignment = NSTextAlignmentCenter;
        [itemView addSubview:label];
    }
    
    NSString *warnStr = @"今日重度污染，请注意防护";
    UIFont *warnFont = [UIFont systemFontOfSize:17];
    CGSize warnSize = [self measureSinglelineStringSize:warnStr andFont:warnFont];
    
    UILabel *warnLabel = [[UILabel alloc] initWithFrame:CGRectMake(KScreenWidth - warnSize.width - 24, titleView.bottom + 162, warnSize.width, 17)];
    warnLabel.tag = 6001;
    warnLabel.text = warnStr;
    warnLabel.hidden = YES;
    warnLabel.textColor = [UIColor colorWithHexString:@"#FF4359"];
    warnLabel.font = warnFont;
    warnLabel.textAlignment = NSTextAlignmentLeft;
    [_bgView addSubview:warnLabel];
    
    UIImageView *warnImgView = [[UIImageView alloc] initWithFrame:CGRectMake(warnLabel.left - 30, titleView.bottom + 160, 20, 20)];
    warnImgView.tag = 7001;
    warnImgView.hidden = YES;
    warnImgView.image = [UIImage imageNamed:@"eve_warn"];
    [_bgView addSubview:warnImgView];
}

- (void)setSubDeviceModel:(SubDeviceModel *)subDeviceModel {
    _subDeviceModel = subDeviceModel;
    
    [self _loadWeatherData];
}

#pragma mark 加载天气数据
-(void)_loadWeatherData {
    NSString *urkStr = [NSString stringWithFormat:@"%@/roadLamp/sensorNew",Main_Url];
    
    NSMutableDictionary *param = @{}.mutableCopy;
    [param setObject:_subDeviceModel.TAGID forKey:@"uid"];
    
    NSDictionary *paramDic =@{@"param":[Utils convertToJsonData:param]};
    
    [[NetworkClient sharedInstance] POST:urkStr dict:paramDic progressFloat:nil succeed:^(id responseObject) {
        
        NSDictionary *data = responseObject;
        if ([data[@"code"] isEqualToString:@"1"]) {
            NSDictionary *weatherDic = data[@"responseData"];
            if(weatherDic == nil || ![weatherDic isKindOfClass:[NSDictionary class]]){
                return ;
            }
            EnvInfoModel *model = [[EnvInfoModel alloc] initWithDataDic:weatherDic];
            
            UIView *weatherItemView = [self viewWithTag:3000];
            UIImageView *weatherIconImgView = [weatherItemView viewWithTag:4000];
            if(model.smallBlue != nil && ![model.smallBlue isKindOfClass:[NSNull class]]){
                [weatherIconImgView sd_setImageWithURL:[NSURL URLWithString:[model.smallBlue stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:@"eve_未知"]];
            }
            
            UILabel *weatherLabel = [weatherItemView viewWithTag:5000];
            weatherLabel.text = [NSString stringWithFormat:@"%.1f℃",model.temperature.floatValue];
            
            UIView *waterItemView = [self viewWithTag:3001];
            UILabel *waterLabel = [waterItemView viewWithTag:5001];
            waterLabel.text = [NSString stringWithFormat:@"%.1f%%",model.humidity.floatValue];
            
            UIView *noiseItemView = [self viewWithTag:3002];
            UILabel *noiseLabel = [noiseItemView viewWithTag:5002];
            noiseLabel.text = [NSString stringWithFormat:@"%.0f dpi",model.noise.floatValue];
            
            UIView *PMItemView = [self viewWithTag:3003];
            UILabel *PMLabel = [PMItemView viewWithTag:5003];
            PMLabel.text = [NSString stringWithFormat:@"%.0f",model.pm2_5.floatValue];
            
            UIView *winddirectionView = [self viewWithTag:3004];
            UILabel *winddirectionLabel = [winddirectionView viewWithTag:5004];
            winddirectionLabel.text = [NSString stringWithFormat:@"%@",model.winddirection];
            
            UIView *windspeedView = [self viewWithTag:3005];
            UILabel *windspeedLabel = [windspeedView viewWithTag:5005];
            windspeedLabel.text = [NSString stringWithFormat:@"%.0f米/秒",model.windspeed.floatValue];
            
            UIView *airpressureView = [self viewWithTag:3006];
            UILabel *airpressureLabel = [airpressureView viewWithTag:5006];
            airpressureLabel.text = [NSString stringWithFormat:@"%.0f hpa",model.airpressure.floatValue];
            
            UIView *pm10View = [self viewWithTag:3007];
            UILabel *pm10Label = [pm10View viewWithTag:5007];
            pm10Label.text = [NSString stringWithFormat:@"%.0f",model.pm10.floatValue];
            
            [self changeValueColor:[NSString stringWithFormat:@"%@", model.pm2_5]];
        }
        
    } failure:^(NSError *error) {
        
    }];
}

// 根据pm值改变数值颜色
- (void)changeValueColor:(NSString *)pm25 {
    UILabel *_pmStandLab = [_bgView viewWithTag:6001];
    UIView *PMItemView = [self viewWithTag:3003];
    UILabel *_pmDataLab = [PMItemView viewWithTag:5003];
    UIImageView *warnImgView = [_bgView viewWithTag:7001];
    
    if(pm25 != nil && ![pm25 isKindOfClass:[NSNull class]]){
        if(pm25.integerValue <= 35){
            // 优
            warnImgView.hidden = YES;
            _pmStandLab.hidden = YES;
            _pmDataLab.textColor = [UIColor colorWithHexString:@"#03ff01"];
            _pmStandLab.text = @"优";
        }else if(pm25.integerValue <= 75){
            // 良
            warnImgView.hidden = YES;
            _pmStandLab.hidden = YES;
            _pmDataLab.textColor = [UIColor blackColor];
            _pmStandLab.text = @"良";
        }else if(pm25.integerValue <= 115){
            // 轻
            _pmDataLab.textColor = [UIColor colorWithHexString:@"#ffc600"];
            _pmStandLab.text = @"今日轻度污染，请注意防护";
        }else if(pm25.integerValue <= 150){
            // 中
            _pmDataLab.textColor = [UIColor colorWithHexString:@"#ffff01"];
            _pmStandLab.text = @"今日中度污染，请注意防护";
        }else if(pm25.integerValue <= 250){
            // 重
            _pmDataLab.textColor = [UIColor colorWithHexString:@"#fe9900"];
            _pmStandLab.text = @"今日重度污染，请注意防护";
        }else {
            // 严重
            _pmDataLab.textColor = [UIColor colorWithHexString:@"#ff0e00"];
            _pmStandLab.text = @"今日严重污染，请注意防护";
        }
        _pmStandLab.textColor = _pmDataLab.textColor;
    }
}

- (void)showMenu {
    self.hidden = NO;
    
    CGRect bgFrame = _bgView.frame;
    _bgView.frame = CGRectMake(bgFrame.origin.x, KScreenHeight, bgFrame.size.width, bgFrame.size.height);
    [UIView animateWithDuration:0.15 animations:^{
        _bgView.frame = bgFrame;
    }];
}
- (void)hidMenu {
    self.hidden = YES;
}


- (CGSize)measureSinglelineStringSize:(NSString*)str andFont:(UIFont*)wordFont {
    if (str == nil) return CGSizeZero;
    CGSize measureSize = [str boundingRectWithSize:CGSizeMake(0, 0) options:NSStringDrawingUsesFontLeading attributes:[NSDictionary dictionaryWithObjectsAndKeys:wordFont, NSFontAttributeName, nil] context:nil].size;
    
    return measureSize;
}

@end

