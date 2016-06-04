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
+(UIColor *) adjustUIColor:(UIColor *)uicolor brightenFactor:(CGFloat)factor;

+(void) showAlertViewWithTitle:(NSString *)title andMessage:(NSString *)message;
+(void) showAlertViewWithMessage:(NSString *)message handler:(void(^)(UIAlertAction *action))handler;
+(void) toastMessage:(NSString *)message;

+(AppDelegate *) appDelegate;

+(void) storeObject:(id)object withKey:(NSString *)key;
+(id) getObjectWithKey:(NSString *)key;

+(UIImage *) getImageFromURL:(NSString *)fileURL;
+(void) saveImage:(UIImage *)image withName:(NSString *)name;
+(void) deleteFilename:(NSString *)filename;

+(void)showActivityView;
+(void)hideActivityView;

+(NSString *)createDirectory:(NSString *)directoryName atFilePath:(NSString *)filePath;

@end
