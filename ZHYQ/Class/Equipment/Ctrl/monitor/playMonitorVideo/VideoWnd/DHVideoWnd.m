//
//  DHVideoWnd.m
//
//  Created by jbin on 14-2-19.
//  Copyright (c) 2014年 dh. All rights reserved.
//

#import "DHVideoWnd.h"
#import <QuartzCore/QuartzCore.h>

@implementation DHVideoWnd

+ (Class) layerClass
{
	return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		CAEAGLLayer *eaglLayer = (CAEAGLLayer*) self.layer;
		eaglLayer.opaque = NO;
		eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
										[NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
		
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)coder
{
	if((self = [super initWithCoder:coder]))
	{
		
	}
	
	return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
}



@end
