//
//  FaceWranModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/23.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FaceWranModel : BaseModel

/*
{
    "born_year": 0,
    "faceImageBase64": "data:image/jpg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBD...",
    "face_image_id": 5348024557502493,
    "face_image_id_str": "5348024557502493",
    "face_image_uri": "normal://repository-builder/20181121/L3H0xShPc0k8-V4fh8A5zA==@1",
    "face_rect": {
        "h": 257,
        "w": 257,
        "x": 114,
        "y": 71
    },
    "gender": 0,
    "is_writable": true,
    "name": "姓名",
    "nation": 0,
    "permission_map": {
        "0": 2,
        "1": 2,
        "101": 2,
        "102": 2,
        "400": 2,
        "452": 2,
        "501": 2,
        "502": 2,
        "503": 2,
        "504": 2,
        "505": 2,
        "553": 2,
        "554": 2,
        "601": 2,
        "602": 2,
        "603": 2,
        "604": 2,
        "605": 2
    },
    "person_id": "",
    "picture_uri": "normal://repository-builder/20181121/VgSk55Cty5yFcm+1hF7lNA==@1",
    "repository_id": 19,
    "timestamp": 1542788314
}
 */

@property (nonatomic,copy) NSString *faceImageBase64;
@property (nonatomic,copy) NSString *face_image_id;
@property (nonatomic,copy) NSString *face_image_uri;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *picture_uri;

@property (nonatomic,assign) BOOL isSelDelete;

@end

NS_ASSUME_NONNULL_END
