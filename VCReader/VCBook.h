//
//  VCBook.h
//  VCReader
//
//  Created by victor on 1/27/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VCBook : NSObject

@property (strong, nonatomic) NSString *contentString;
@property (strong, nonatomic) NSString *bookName;

-(instancetype) initWithBookName:(NSString *)bookName;
-(NSString *)getTextContentStringFromChapterNumber:(NSUInteger)chapterNumber;
-(NSString *)getChapterTitleStringFromChapterNumber:(NSUInteger)chapterNumber;


@end
