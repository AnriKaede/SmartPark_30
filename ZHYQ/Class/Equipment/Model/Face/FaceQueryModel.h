//
//  FaceQueryModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/3/28.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface FaceQueryModel : BaseModel

/*
{
    "faceImageId":"9222527611924644149",
    "faceImageIdStr":"9222527611924644149",
    "faceImageUrl":"normal://repository-builder/20180326/gtvHOWi9rgIt-nGWzrPZMw==@1",
    "imageUrl":"normal://repository-builder/20180326/tXAkdEH-d2qMuO0wnERw+Q==@1",
    "imgBase64":"data:image/png;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/…"
}
*/

@property (nonatomic,copy) NSString *faceImageId;
@property (nonatomic,copy) NSString *faceImageIdStr;
@property (nonatomic,copy) NSString *faceImageUrl;
@property (nonatomic,copy) NSString *imageUrl;
@property (nonatomic,copy) NSString *imgBase64;
 
@end
