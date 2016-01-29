//
//  VCBookContent.m
//  VCReader
//
//  Created by victor on 1/27/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import "VCBookContent.h"

@implementation VCBookContent

@synthesize contentString = _contentString;


-(instancetype) init {
    self = [super init];
    if (self) {
            _contentString = @"";
        [self setup];
    }
    return self;
}

-(instancetype) initWithContent:(NSString *)contentString {
    self = [super init];
    if (self) {
        _contentString = contentString;
        [self setup];

    }
    return self;
}

-(void) setup {
    
    _chapterTitleStringArray = [NSMutableArray new];
    _chapterContentRangeStringArray = [NSMutableArray new];
    [self splitChapters];
}

-(NSString *)getTextStringFromChapter:(NSUInteger)chapterNumber {
    
    return [_contentString substringWithRange:NSRangeFromString([_chapterContentRangeStringArray objectAtIndex: chapterNumber - 1])];
}

-(void) splitChapters {
    
    NSError *error = NULL;
    __block int count = 1;
    __block NSString *previousChapterString = @"";
    __block NSRange previousTitleRange;
    previousTitleRange = NSMakeRange(0, 0);
    
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"卷*.*第(一|二|三|四|五|六|七|八|九|十|零|百|[0-9])+章.*[\\n\\r\\s]"
                                  options:NSRegularExpressionCaseInsensitive
                                  error:&error];
    
    [regex enumerateMatchesInString:_contentString options:0 range:NSMakeRange(0, [_contentString length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
        
        NSRange range = [match rangeAtIndex:0];
        NSString *title = [_contentString substringWithRange:range];

        if ([[self getChapterStringFromString:previousChapterString] isEqualToString:[self getChapterStringFromString:title]]) {
            return;

        }
        
        NSMutableString *workingString = [[NSMutableString alloc] initWithString:title];

        int chapterNumber = [self getChapterNumberFromTitle:title];
        if (chapterNumber > 0) {
            if (chapterNumber != count) {
                [workingString replaceOccurrencesOfString:[NSString stringWithFormat:@"%d", chapterNumber] withString:[NSString stringWithFormat:@"%d", count] options:NSNumericSearch range:NSMakeRange(0, title.length)];
            }
        }
        [_chapterTitleStringArray addObject:workingString];
        if (previousTitleRange.length > 0) {
            
            [_chapterContentRangeStringArray addObject:NSStringFromRange(NSMakeRange(previousTitleRange.location + previousTitleRange.length, range.location - previousTitleRange.location - range.length))];

        }

        previousChapterString = title;
        previousTitleRange = range;
//        NSLog(@"title:%@ word count:%lu match number:%d",title, (unsigned long)range.length, count);
        count++;
    }];
    [_chapterContentRangeStringArray addObject:NSStringFromRange(NSMakeRange(previousTitleRange.location + previousTitleRange.length, _contentString.length))];

}

-(NSString *)getChapterStringFromString:(NSString *)string {
    
    NSError *error = NULL;

    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"第(一|二|三|四|五|六|七|八|九|十|零|百|[0-9])+章"
                                  options:NSRegularExpressionCaseInsensitive
                                  error:&error];
    NSRange stringRange = NSMakeRange(0, string.length);

    NSArray *matches = [regex matchesInString:string options:0 range:stringRange];
    NSString *matchedString = [string substringWithRange:[[matches lastObject] rangeAtIndex:0]];
    return matchedString;
}

-(int)getChapterNumberFromTitle:(NSString *)string {
    
    NSError *error = NULL;
    
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"第([0-9])+章"
                                  options:NSRegularExpressionCaseInsensitive
                                  error:&error];
    NSRange stringRange = NSMakeRange(0, string.length);
    
    NSArray *matches = [regex matchesInString:string options:0 range:stringRange];
    if (matches.count == 0) {
        return 0;
    }
    NSString *matchedString = [string substringWithRange:[[matches lastObject] rangeAtIndex:0]];
    NSRange range = {1, matchedString.length -1};
    int chapterNumber = [[matchedString substringWithRange:range] intValue];
    return chapterNumber;
}
@end
