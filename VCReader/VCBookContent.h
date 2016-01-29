//
//  VCBookContent.h
//  VCReader
//
//  Created by victor on 1/27/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VCBookContent : NSObject

@property (strong, nonatomic) NSString *contentString;
@property (readonly, strong, nonatomic) NSMutableArray *chapterTitleStringArray;
@property (readonly, strong, nonatomic) NSMutableArray *chapterContentRangeStringArray;

-(instancetype) init;
-(instancetype) initWithContent:(NSString *)contentString;
-(NSString *)getTextStringFromChapter:(NSUInteger)chapterNumber;

@end
