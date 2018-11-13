//
//  FaceListModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/3/28.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface FaceListModel : BaseModel

/*
{ 　　　　　　　　"annotation":0, 　　　　　　　　"camera_id":11, 　　　　　　　　"faceImageBase64":"data:image/jpg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAEBAQE=", 　　　　　　　　"face_image_id":4785074604152374, 　　　　　　　　"face_image_id_str":4785074604152374, 　　　　　　　　"face_image_uri":"normal://face-video/20180326/VV+biHK89eFsd0N6-yj5vA==@1", 　　　　　　　　"face_rect":{ 　　　　　　　　　　"h":112, 　　　　　　　　　　"w":112, 　　　　　　　　　　"x":873, 　　　　　　　　　　"y":395 　　　　　　　　}, 　　　　　　　　"is_hit":false, 　　　　　　　　"is_writable":false, 　　　　　　　　"picture_uri":"normal://face-video/20180326/GxDKlO4jtYlcSIc4XuHzdQ==@1", 　　　　　　　　"rec_age_range":1, 　　　　　　　　"rec_gender":1, 　　　　　　　　"rec_glasses":0, 　　　　　　　　"rec_uygur":0, 　　　　　　　　"repository_address":"1000237$1$0$3", 　　　　　　　　"repository_id":17, 　　　　　　　　"repository_name":"西侧入口人脸", 　　　　　　　　"similarity":86.66029638681427, 　　　　　　　　"timestamp":1522039438 　　　　　　}
 */

@property (nonatomic,strong) NSNumber *timestamp;
@property (nonatomic,strong) NSNumber *rec_gender;
@property (nonatomic,strong) NSNumber *rec_age_range;
@property (nonatomic,strong) NSNumber *rec_glasses;

@property (nonatomic,strong) NSNumber *camera_id;
@property (nonatomic,copy) NSString *repository_name;

@property (nonatomic,copy) NSString *faceImageBase64;

@property (nonatomic,strong) NSNumber *similarity;

@property (nonatomic,copy) NSString *picture_uri;
@property (nonatomic,copy) NSString *repository_address;

@end
