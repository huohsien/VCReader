//
//  VCTool.m
//  VCReader
//
//  Created by victor on 1/30/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import "VCTool.h"
#import "UIAlertController+Window.h"
#import <QuartzCore/QuartzCore.h>

static UIView *_activityView;

@implementation VCTool

+(void) storeIntoBook:(NSString *)bookName withField:(NSString *)field andData:(id)data {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:data forKey:field];
    [defaults setObject:dict forKey:[NSString stringWithFormat:@"%@_%@", bookName, field]];
    [defaults synchronize];
}

+(void) removeFromBook:(NSString *)bookName withField:(NSString *)field {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:[NSString stringWithFormat:@"%@_%@", bookName, field]];
    [defaults synchronize];
}

+(id) getDatafromBook:(NSString *)bookName withField:(NSString *)field {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [defaults objectForKey:[NSString stringWithFormat:@"%@_%@", bookName, field]];
    return [dict objectForKey:field];
}

+(void) removeAllObjectIn:(NSMutableArray *)array ofClass:(Class)class {
    
    for (id obj in array) {
        if ([obj isKindOfClass:class]) {
            [array removeObject:obj];
        }
    }
}

+(int) removeAllSubviewsInView:(UIView *)view {
    
    int count = 0;
    for (UIView *v in view.subviews) {
        [v removeFromSuperview];
        count++;
    }
    return count;
}

+(UIImage *) maskedImage:(UIImage *)image color:(UIColor *)color {
    
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, image.scale);
    CGContextRef c = UIGraphicsGetCurrentContext();
    [image drawInRect:rect];
    CGContextSetFillColorWithColor(c, [color CGColor]);
    CGContextSetBlendMode(c, kCGBlendModeSourceAtop);
    CGContextFillRect(c, rect);
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

+(UIColor *) adjustUIColor:(UIColor *)uicolor brightenFactor:(CGFloat)factor {
    
    CGFloat h;
    CGFloat s;
    CGFloat b;
    CGFloat a;
    [uicolor getHue:&h saturation:&s brightness:&b alpha:&a];
    
    return [UIColor colorWithHue:h saturation:s brightness:b * factor alpha:a];
}

+(UIColor *) changeUIColor:(UIColor *)uicolor alphaValueTo:(CGFloat)alpha {
    
    CGColorRef color = [uicolor CGColor];
    
    int numComponents = (int)CGColorGetNumberOfComponents(color);
    
    UIColor *newColor;
    if (numComponents == 4)
    {
        const CGFloat *components = CGColorGetComponents(color);
        CGFloat red = components[0];
        CGFloat green = components[1];
        CGFloat blue = components[2];
        newColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
        return newColor;
    }
    return nil;
}

+(NSManagedObjectContext *) getContext {
    
    return ((AppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
}

+(void) showAlertViewWithTitle:(NSString *)title andMessage:(NSString *)message {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil];
    
    [alertController addAction:okAction];
    [alertController show];
}

+(void) showAlertViewWithMessage:(NSString *)message {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"错误"
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil];
    
    [alertController addAction:okAction];
    [alertController show];
}

+(void) showAlertViewWithMessage:(NSString *)message handler:(void(^)(UIAlertAction *action))handler {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"错误"
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:handler];
    
    [alertController addAction:okAction];
    [alertController show];
}

+(void) toastMessage:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController show];

    int duration = 2; // duration in seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [alertController dismissViewControllerAnimated:YES completion:nil];
    });
}
+(AppDelegate *) appDelegate {

    return (AppDelegate *)[[UIApplication sharedApplication] delegate];

}

+(void) storeObject:(id)object withKey:(NSString *)key {

    [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

+(id) getObjectWithKey:(NSString *)key {
    
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

+(UIImage *) getImageFromURL:(NSString *)fileURL {
    
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    UIImage * result = [UIImage imageWithData:data];
    
    return result;
}

+(void) saveImage:(UIImage *)image asPNGFileWithName:(NSString *)name {
    
    if (image) {
        
        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",name]];
        
        [UIImagePNGRepresentation(image) writeToFile:path options:NSAtomicWrite error:nil];
    }
}

+(NSString *) saveData:(NSData *)data toFileNamed:(NSString *)filename {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:filename];
    NSError *error;

    if ([fileManager fileExistsAtPath:filePath]) {
        
        BOOL success = [fileManager removeItemAtPath:filePath error:&error];
        if (success) {
            VCLOG(@"delete file successfully");
        } else {
            VCLOG(@"Could not delete file :%@ ", [error localizedDescription]);
        }
    } else {
        VCLOG(@"no file needs to be deleted");
    }
    
    [data writeToFile:filePath atomically:YES];
    return filePath;
}

+(void) deleteFilename:(NSString *)filename {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:filename];
    NSError *error;
    
    if ([fileManager fileExistsAtPath:filePath]) {
        
        BOOL success = [fileManager removeItemAtPath:filePath error:&error];
        if (success) {
            VCLOG(@"delete file successfully");
        }
        else
        {
            VCLOG(@"Could not delete file -:%@ ", [error localizedDescription]);
        }
    } else {
        VCLOG(@"no file needs to be deleted");
    }
}

+(void)showActivityView {
    
    [NSThread detachNewThreadSelector:@selector(showActivityViewInANewThread) toTarget:self withObject:nil];
    [NSThread sleepForTimeInterval:0.1]; // give a minimum time for method showActivityViewInANewThread to finish so that there is no chance of running hideActivityView before showActivityViewInANewThread is done
}

+ (void)showActivityViewInANewThread {
    
    @autoreleasepool {
        
        VCLOG();
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UIWindow *window = delegate.window;
        
        if (_activityView == nil) {
            
            _activityView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, window.bounds.size.width, window.bounds.size.height)];
            _activityView.backgroundColor = [UIColor blackColor];
            _activityView.alpha = 0.5;
            
            UIActivityIndicatorView *activityWheel = [[UIActivityIndicatorView alloc] initWithFrame: CGRectMake(window.bounds.size.width / 2 - 12, window.bounds.size.height / 2 - 12, 24, 24)];
            activityWheel.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
            activityWheel.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                              UIViewAutoresizingFlexibleRightMargin |
                                              UIViewAutoresizingFlexibleTopMargin |
                                              UIViewAutoresizingFlexibleBottomMargin);
            [_activityView addSubview:activityWheel];
        }
        
        [window addSubview: _activityView];

        [[[_activityView subviews] objectAtIndex:0] startAnimating];
    }
    
}

+(void)hideActivityView {
    
    VCLOG();
    [[[_activityView subviews] objectAtIndex:0] stopAnimating];
    [_activityView removeFromSuperview];

}

#pragma mark - file manager

+(NSString *)createDirectory:(NSString *)directoryName atFilePath:(NSString *)filePath
{
    NSString *filePathAndDirectory = [filePath stringByAppendingPathComponent:directoryName];
    NSError *error;
    
    if (![[NSFileManager defaultManager] createDirectoryAtPath:filePathAndDirectory
                                   withIntermediateDirectories:NO
                                                    attributes:nil
                                                         error:&error])
    {
        //        VCLOG(@"Create directory error: %@", error);
    }
    return filePathAndDirectory;
}

#pragma mark - Log

+(NSMutableArray *)errorLogData {
    
    NSUInteger maximumLogFilesToReturn = MIN([VCTool appDelegate].fileLogger.logFileManager.maximumNumberOfLogFiles, 10);
    
    NSMutableArray *errorLogFiles = [NSMutableArray arrayWithCapacity:maximumLogFilesToReturn];
    
    DDFileLogger *logger = [VCTool appDelegate].fileLogger;
    
    NSArray *sortedLogFileInfos = [logger.logFileManager sortedLogFileInfos];
    
    for (int i = 0; i < MIN(sortedLogFileInfos.count, maximumLogFilesToReturn); i++) {
        
        DDLogFileInfo *logFileInfo = [sortedLogFileInfos objectAtIndex:i];
        
        NSData *fileData = [NSData dataWithContentsOfFile:logFileInfo.filePath];
        
        [errorLogFiles addObject:fileData];
    }
    return errorLogFiles;
}


@end
