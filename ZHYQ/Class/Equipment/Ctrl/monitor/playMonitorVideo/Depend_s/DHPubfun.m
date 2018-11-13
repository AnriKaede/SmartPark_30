//
//  DHPubfun.m
//  iDMSS
//
//  Created by Fei Wang on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DHPubfun.h"

#define APP_URL   @"http://itunes.apple.com/cn/lookup?id=675624243"


#define ILLEGALCHAR "!$&*()+=\\/'\"<>,~[]#@%^:?"

@implementation DHPubfun

+ (BOOL)illegalCharacterInString:(NSString*)cString
{
	char cExclued[] = ILLEGALCHAR ;
	const char* string = [cString cStringUsingEncoding:NSUTF8StringEncoding];
	if (string != NULL)
	{
		for (int i=0 ; i< strlen(cExclued); i++) 
		{
			if (NULL != strchr(string, cExclued[i])) 
			{
				return TRUE;
			}
		}
	}
	
	return FALSE;
}

+ (BOOL)AllNumerics:(NSString*)cString
{
    if (0 == [cString length]) {
        return NO;
    }
    
    char numbers[] = "1234567890";
    const char* string = [cString cStringUsingEncoding:NSUTF8StringEncoding];
	if (string != NULL)
	{
		for (int i=0 ; i< strlen(string); i++)
		{
			if (NULL == strchr(numbers, string[i]))
			{
				return NO;
			}
		}
	}
	
	return YES;
}

+ (NSString*) documentFolder
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	
	return documentsDirectory;

}

+ (NSString*) supportFolder
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	NSString *libraryDirectory = [paths objectAtIndex:0];
	
	
	NSString *supportDirectory = [libraryDirectory stringByAppendingPathComponent:@"Support"];
    
    return supportDirectory;

}


+ (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image waterPrint:(UIImage*)waterPrintImage size:(CGSize)asize
{
    
    UIImage *newimage;
    
    
    if (nil == image) {
        
        newimage = nil;
        
    }
    
    else{
        
        CGSize oldsize = image.size;
        
        CGRect rect;
        
        if (asize.width/asize.height > oldsize.width/oldsize.height) {
            
            rect.size.width = asize.height*oldsize.width/oldsize.height;
            
            rect.size.height = asize.height;
            
            rect.origin.x = 0;
            
            rect.origin.y = 0;
            
        }
        
        else{
            
            rect.size.width = asize.width;
            
            rect.size.height = asize.width*oldsize.height/oldsize.width;
            
            rect.origin.x = 0;
            
            rect.origin.y = (asize.height - rect.size.height)/2;
            
        }
        
        
        UIGraphicsBeginImageContext(asize);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
        
        UIRectFill(CGRectMake(0, 0, asize.width, asize.height));//clear background
        
        rect.size = asize;
        [image drawInRect:rect];
        
        if (waterPrintImage)
        {
            [waterPrintImage drawInRect:CGRectMake(0, 0, 70, 70)];
        }
        
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
    }
    
    
    return newimage;
    
}

+ (BOOL)writeImage:(UIImage*)image toFileAtPath:(NSString*)aPath
{
    if ((image == nil) || (aPath == nil) || ([aPath isEqualToString:@""]))
        return NO;
    
    @try
    {
        NSData *imageData = nil;
        NSString *ext = [aPath pathExtension];
        if ([ext isEqualToString:@"png"])
        {
            imageData = UIImagePNGRepresentation(image);
        }
        else
        {
            // the rest, we write to jpeg
            // 0. best, 1. lost. about compress.
            imageData = UIImageJPEGRepresentation(image, 0);
        }
        
        if ((imageData == nil) || ([imageData length] <= 0))
            return NO;
        
        [imageData writeToFile:aPath atomically:YES];
        return YES;
    }
    @catch (NSException *e)
    {
        NSLog(@"create thumbnail exception.");
    }
    
    return NO;
}

@end
