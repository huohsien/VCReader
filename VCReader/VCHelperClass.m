//
//  VCHelperClass.m
//  VCReader
//
//  Created by victor on 1/30/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import "VCHelperClass.h"

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

@end
