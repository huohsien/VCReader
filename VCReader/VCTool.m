//
//  VCTool.m
//  VCReader
//
//  Created by victor on 1/30/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import "VCTool.h"
#import "UIAlertController+Window.h"

static UIView *_activityView;

@implementation VCTool

+(void) storeIntoBook:(NSString *)bookName withField:(NSString *)field andData:(id)data {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:data forKey:field];
    [defaults setObject:dict forKey:[NSString stringWithFormat:@"%@_%@", bookName, field]];
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

+(UIColor *) adjustUIColor:(UIColor *)uicolor brightness:(CGFloat)brightness {
    
    CGFloat h;
    CGFloat s;
    CGFloat b;
    CGFloat a;
    [uicolor getHue:&h saturation:&s brightness:&b alpha:&a];
    
    return [UIColor colorWithHue:h saturation:s brightness:brightness alpha:a];
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

+(void) showAlertViewWithMessage:(NSString *)message handler:(void(^)(UIAlertAction *action))handler {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"错误"
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:handler];
    
    [alertController addAction:okAction];
    [alertController show];
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

+(void) saveImage:(UIImage *)image {
    
    if (image) {
        
        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"headshot.png"]];
        
        [UIImagePNGRepresentation(image) writeToFile:path options:NSAtomicWrite error:nil];
    }
}

+(void) deleteFilename:(NSString *)filename {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:filename];
    NSError *error;
    if ([fileManager fileExistsAtPath:filePath]) {
        
        BOOL success = [fileManager removeItemAtPath:filePath error:&error];
        if (success) {
            NSLog(@"%s --- delete file successfully", __PRETTY_FUNCTION__);
        }
        else
        {
            NSLog(@"%s --- Could not delete file -:%@ ", __PRETTY_FUNCTION__, [error localizedDescription]);
        }
    } else {
        NSLog(@"%s --- no file needs to be deleted", __PRETTY_FUNCTION__);
    }
}

+(void)showActivityView {
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    UIWindow *window = delegate.window;
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
    [window addSubview: _activityView];
    
    [[[_activityView subviews] objectAtIndex:0] startAnimating];
}

+(void)hideActivityView {
    
    [[[_activityView subviews] objectAtIndex:0] stopAnimating];
    [_activityView removeFromSuperview];
    _activityView = nil;
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
        //        NSLog(@"Create directory error: %@", error);
    }
    return filePathAndDirectory;
}
@end
