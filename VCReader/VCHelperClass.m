//
//  VCHelperClass.m
//  VCReader
//
//  Created by victor on 1/30/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import "VCHelperClass.h"
#import "UIAlertController+Window.h"

@implementation VCHelperClass

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


+(void) showErrorAlertViewWithTitle:(NSString *)title andMessage:(NSString *)message {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    
    [alertController show];
}

+(NSString *)getCurrentEpochTimeInMilliSeconds {

    NSDate *date = [NSDate new];
    NSTimeInterval time = [date timeIntervalSince1970];
    NSString *timestampString = [NSString stringWithFormat:@"%ld", (long)(time * 1000.0)];
    return timestampString;
}

+(AppDelegate *) appDelegate {

    return (AppDelegate *)[[UIApplication sharedApplication] delegate];

}

@end
