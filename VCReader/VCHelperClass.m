//
//  VCHelperClass.m
//  VCReader
//
//  Created by victor on 1/30/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import "VCHelperClass.h"
#import "VCReadingStatusMO+CoreDataProperties.h"
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

+(void)saveReadingStatusForBook:(NSString *)bookName andUserID:(NSString *)userID chapterNumber:(int)chapterNumber wordNumber:(int)wordNumber inViewController:(UIViewController *)vc {
    
    NSManagedObjectContext *context = [self getContext];
    
    VCReadingStatusMO *readingStatus = [NSEntityDescription insertNewObjectForEntityForName:@"ReadingStatus" inManagedObjectContext:context];
    readingStatus.bookName = bookName;
    readingStatus.chapterNumber = chapterNumber;
    readingStatus.wordNumber = wordNumber;
    readingStatus.updateTime = [[NSDate new] timeIntervalSince1970];
    readingStatus.userID = userID;
    
    // Save the context
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"%s: Unresolved error %@, %@",__PRETTY_FUNCTION__,error,[error userInfo]);
        [VCHelperClass showErrorAlertViewWithTitle:@"Core Data Error" andMessage:@"Can not save data"];
        abort();
    }
}

+(VCReadingStatusMO *) getReadingStatusForBook:(NSString *)bookName andUserID:(NSString *)userID inViewController:(UIViewController *)vc {
    
    NSManagedObjectContext *context = [self getContext];

    // Retrieve all the shapes
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ReadingStatus"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bookName == %@", bookName];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *statusArray = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"%s: Unresolved error %@, %@",__PRETTY_FUNCTION__,error,[error userInfo]);
        abort();
    }
    VCReadingStatusMO *readingStatus = [statusArray lastObject];
    if (readingStatus == nil) {
        
//        VCReadingStatusMO *readingStatus = [NSEntityDescription insertNewObjectForEntityForName:@"ReadingStatus" inManagedObjectContext:context];
//        readingStatus.bookName = bookName;
//        readingStatus.userID = userID;
//        readingStatus.chapterNumber = 0;
//        readingStatus.pageNumber = 0;
//        readingStatus.updateTime = [[NSDate new] timeIntervalSince1970];
//        // Save the context
//        NSError *error = nil;
//        if (![context save:&error]) {
//            NSLog(@"%s: Unresolved error %@, %@",__PRETTY_FUNCTION__,error,[error userInfo]);
//            abort();
//        }

        [VCHelperClass showErrorAlertViewWithTitle:@"Core Data Error" andMessage:@"Can not find user's reading status"];
        
    } else if (readingStatus.updateTime > [[NSDate new] timeIntervalSince1970]) {
        NSLog(@"%s: timeStamp error", __PRETTY_FUNCTION__);
        abort();
    }
    return readingStatus;
}

+(void) showErrorAlertViewWithTitle:(NSString *)title andMessage:(NSString *)message {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    
    [alertController show];
}

@end
