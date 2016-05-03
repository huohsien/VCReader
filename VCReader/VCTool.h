//
//  VCTool.h
//  VCReader
//
//  Created by victor on 1/30/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "VCReadingStatusMO+CoreDataProperties.h"

@import UIKit;
@interface VCTool : NSObject

+(void) storeIntoBook:(NSString *)bookName withField:(NSString *)field andData:(id)data;
+(id) getDatafromBook:(NSString *)bookName withField:(NSString *)field;

+(void) removeAllObjectIn:(NSMutableArray *)array ofClass:(Class)class;
+(int) removeAllSubviewsInView:(UIView *)view;
+(UIImage *) maskedImage:(UIImage *)image color:(UIColor *)color;
+(UIColor *) changeUIColor:(UIColor *)uicolor alphaValueTo:(CGFloat)alpha;
+(UIColor *) adjustUIColor:(UIColor *)uicolor brightness:(CGFloat)brightness;

+(void) showErrorAlertViewWithTitle:(NSString *)title andMessage:(NSString *)message;
+(AppDelegate *) appDelegate;
+(void) storeObject:(id)object withKey:(NSString *)key;
+(id) getObjectWithKey:(NSString *)key;
+(UIImage *) getImageFromURL:(NSString *)fileURL;
+(void) saveImage:(UIImage *)image;
+(void) deleteFilename:(NSString *)filename;
+(void)showActivityView;
+(void)hideActivityView;

@end
