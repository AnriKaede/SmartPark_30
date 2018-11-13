//
//  FaceTraceCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/3/28.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "FaceTraceCell.h"

@implementation FaceTraceCell
{
    __weak IBOutlet UILabel *_timeLabel;
    
    __weak IBOutlet UIImageView *_traceImgView;
    
    __weak IBOutlet UILabel *_sexLabel;
    __weak IBOutlet UILabel *_ageLabel;
    __weak IBOutlet UILabel *_glassesLabel;
    __weak IBOutlet UILabel *_camearLabel;
    __weak IBOutlet UILabel *_locationLabel;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _traceImgView.layer.cornerRadius = _traceImgView.width/2;
}

- (void)setFaceListModel:(FaceListModel *)faceListModel {
    _faceListModel = faceListModel;
    
    // 时间
    _timeLabel.text = [self timeSimp:faceListModel.timestamp];
    
    // 图像
    NSString *base64Str = [_faceListModel.faceImageBase64 componentsSeparatedByString:@"base64,"].lastObject;
    NSData *decodedImageData = [[NSData alloc] initWithBase64EncodedString:base64Str options:NSDataBase64DecodingIgnoreUnknownCharacters];
    UIImage *decodedImage = [UIImage imageWithData:decodedImageData];
    
    _traceImgView.image = decodedImage;
    
    // 性别
    if(faceListModel.rec_gender.integerValue == 1){
        _sexLabel.text = @"男";
    }else {
        _sexLabel.text = @"女";
    }
    
    // 年龄
    if(faceListModel.rec_age_range.integerValue == 0){
        _ageLabel.text = @"少年";
    }else if(faceListModel.rec_age_range.integerValue == 1){
        _ageLabel.text = @"青年";
    }else if(faceListModel.rec_age_range.integerValue == 2){
        _ageLabel.text = @"中年";
    }else {
        _ageLabel.text = @"老年";
    }
    
    // 是否眼镜
    if(faceListModel.rec_glasses.integerValue == 0){
        _glassesLabel.text = @"无";
    }else {
        _glassesLabel.text = @"有";
    }
    
    // 人脸相机id
    _camearLabel.text = [NSString stringWithFormat:@"%@", faceListModel.repository_address];
    
    // 人脸相机位置
    _locationLabel.text = faceListModel.repository_name;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    //设置虚线颜色
    CGContextSetStrokeColorWithColor(currentContext, [UIColor colorWithHexString:@"#1B82D1"].CGColor);
    //设置虚线宽度
    CGContextSetLineWidth(currentContext, 1);
    //设置虚线绘制起点
    CGContextMoveToPoint(currentContext, 23, 30);
    //设置虚线绘制终点
    CGContextAddLineToPoint(currentContext, 23, 160);
    //设置虚线排列的宽度间隔:下面的arr中的数字表示先绘制3个点再绘制1个点
    CGFloat arr[] = {2,1};
    //下面最后一个参数“2”代表排列的个数。
    CGContextSetLineDash(currentContext, 0, arr, 2);
    CGContextDrawPath(currentContext, kCGPathStroke);
}

- (NSString *)timeSimp:(NSNumber *)time {
    NSTimeInterval interval = [time doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd    HH:mm:ss"];
    NSString *dateString = [formatter stringFromDate: date];
    
    return dateString;
}

@end
