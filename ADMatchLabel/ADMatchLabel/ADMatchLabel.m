//
//  ADMatchLabel.m
//  ADMatchLabel
//
//  Created by Andy on 2018/11/20.
//  Copyright © 2018 Andy. All rights reserved.
//

#import "ADMatchLabel.h"

static NSString *const ADMatchLabelPatternURL = @"\\b(([\\w-]+://?|www[.])[^\\s()<>]+(?:\\([\\w\\d]+\\)|([^[:punct:]\\s]|/)))";
static NSString *const ADMatchLabelPatternNumber = @"\\d{3}-\\d{8}|\\d{3}-\\d{7}|\\d{4}-\\d{8}|\\d{4}-\\d{7}|1+[3578]+\\d{9}|[+]861+[3578]+\\d{9}|861+[3578]+\\d{9}|1+[3578]+\\d{1}-\\d{4}-\\d{4}|\\d{8}|\\d{7}|400-\\d{3}-\\d{4}|400-\\d{4}-\\d{3}";
static NSString *const ADMatchLabelPatternEmail = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,6}";
static NSString *const ADMatchLabelPatternTopic = @"#[^#]+#";
static NSString *const ADMatchLabelPatternAt = @"@[\\u4e00-\\u9fa5a-zA-Z0-9_-]{2,30}";

@interface ADMatchLabel ()<NSLayoutManagerDelegate>

/// NSAttributedString 子类 设置文本统一使用
@property (nonatomic, strong) NSTextStorage *textStorage;
/// 布局管理器 负责 字形 布局
@property (nonatomic, strong) NSLayoutManager *layoutManager;
/// 绘制区域
@property (nonatomic, strong) NSTextContainer *textContainer;

@end

@implementation ADMatchLabel

#pragma mark - super

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self _initializeEnvironment];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self _initializeEnvironment];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.textContainer.size = self.bounds.size;
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    
    [self _setupText:text];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    [super setAttributedText:attributedText];
    
    [self _setupText:attributedText];
}

- (void)setNumberOfLines:(NSInteger)numberOfLines
{
    [super setNumberOfLines:numberOfLines];
    
    self.textContainer.maximumNumberOfLines = numberOfLines;
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode
{
    [super setLineBreakMode:lineBreakMode];
    
    self.textContainer.lineBreakMode = lineBreakMode;
}

- (void)drawTextInRect:(CGRect)rect
{
    NSRange range = [self.layoutManager glyphRangeForTextContainer:self.textContainer];
    CGRect usedRect = [self.layoutManager usedRectForTextContainer:self.textContainer];
    CGPoint offset = [self _offsetWithDrawSize:usedRect.size];
    NSLog(@"---- %@ --- %@", NSStringFromCGSize(self.textContainer.size), NSStringFromCGRect(usedRect));
    [self.layoutManager drawBackgroundForGlyphRange:range atPoint:offset];
    [self.layoutManager drawGlyphsForGlyphRange:range atPoint:offset];
}

#pragma mark - touches

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (![self.delegate respondsToSelector:@selector(linkLabelDidSelectedType:content:)]) {
        return;
    }
    CGPoint location = [[touches anyObject] locationInView:self];
    [self.layoutManager glyphRangeForTextContainer:self.textContainer];
    CGRect usedRect = [self.layoutManager usedRectForTextContainer:self.textContainer];
    CGPoint offset = [self _offsetWithDrawSize:usedRect.size];
    location.x -= offset.x;
    location.y -= offset.y;
    
    // 获取点击了第几个字符
    NSUInteger index = [self.layoutManager glyphIndexForPoint:location inTextContainer:self.textContainer];
    // 判断index是否在 range里
    for (NSNumber *item in self.matchTypes) {
        NSString *pattern = [[self matchTypeAndPatternMap] objectForKey:item];
        for (NSString *rangeString in [self _findRangesWithPattern:pattern]) {
            NSRange range = NSRangeFromString(rangeString);
            if (NSLocationInRange(index, range)) {
                NSString *subString = [self.textStorage.string substringWithRange:range];
                [self.delegate linkLabelDidSelectedType:item.integerValue content:subString];
                return;
            }
        }
    }
}

#pragma mark - NSLayoutManagerDelegate

- (BOOL)layoutManager:(NSLayoutManager *)layoutManager shouldBreakLineByWordBeforeCharacterAtIndex:(NSUInteger)charIndex
{
    return YES;
}

- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager lineSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect
{
    return floorf(glyphIndex / 100);
}

- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager paragraphSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect
{
    return 10;
}

#pragma mark - private method

- (void)_initializeEnvironment
{
    self.userInteractionEnabled = YES;
    self.matchTypes = @[@(ADMatchLabelMatchTypeURL), @(ADMatchLabelMatchTypeEmail), @(ADMatchLabelMatchTypeTopic), @(ADMatchLabelMatchTypeAt), @(ADMatchLabelMatchTypeNumber)];
    self.matchColor = [UIColor colorWithRed:0.061 green:0.515 blue:0.862 alpha:1.000];
    
    [self.textStorage addLayoutManager:self.layoutManager];
    [self.layoutManager addTextContainer:self.textContainer];
}

- (void)_setupText:(id)text
{
    if ([text isKindOfClass:[NSString class]]) {
        [self.textStorage setAttributedString:[[NSAttributedString alloc] initWithString:text]];
    } else if ([text isKindOfClass:[NSAttributedString class]]) {
        [self.textStorage setAttributedString:text];
    } else {
        return;
    }
    [self _setupTextAttributes];
}

- (void)_setupTextAttributes
{
    [self.textStorage addAttributes:@{NSFontAttributeName : self.font, NSForegroundColorAttributeName : self.textColor} range:NSMakeRange(0, self.textStorage.length)];
    
    for (NSNumber *item in self.matchTypes) {
        NSString *pattern = [[self matchTypeAndPatternMap] objectForKey:item];
        for (NSString *rangeString in [self _findRangesWithPattern:pattern]) {
            [self.textStorage addAttributes:@{NSForegroundColorAttributeName : self.matchColor} range:NSRangeFromString(rangeString)];
        }
    }
}

- (NSArray *)_findRangesWithPattern:(NSString *)pattern
{
    NSError *error = nil;
    NSRegularExpression *regx = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    if (!regx || error) {
        return nil;
    }
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSArray<NSTextCheckingResult *> *matches = [regx matchesInString:self.textStorage.string options:NSMatchingReportProgress range:NSMakeRange(0, self.textStorage.length)];
    for (NSTextCheckingResult *match in matches) {
        [result addObject:NSStringFromRange([match rangeAtIndex:0])];
    }
    return result;
}

- (CGPoint)_offsetWithDrawSize:(CGSize)drawSize
{
    CGPoint offset = CGPointZero;
    offset.y = (self.bounds.size.height - drawSize.height) / 2;
    
    return offset;
}

#pragma mark - getter and setter

- (NSTextStorage *)textStorage
{
    if (!_textStorage) {
        _textStorage = [[NSTextStorage alloc] init];
    }
    return _textStorage;
}

- (NSLayoutManager *)layoutManager
{
    if (!_layoutManager) {
        _layoutManager = [[NSLayoutManager alloc] init];
        _layoutManager.allowsNonContiguousLayout = NO;
        _layoutManager.delegate = self;
    }
    return _layoutManager;
}

- (NSTextContainer *)textContainer
{
    if (!_textContainer) {
        _textContainer = [[NSTextContainer alloc] init];
        _textContainer.maximumNumberOfLines = self.numberOfLines;
        _textContainer.lineBreakMode = self.lineBreakMode;
        _textContainer.lineFragmentPadding = 0.0f;
        _textContainer.size = self.bounds.size;
    }
    return _textContainer;
}

- (NSDictionary *)matchTypeAndPatternMap
{
    return @{
             @(ADMatchLabelMatchTypeURL)     : ADMatchLabelPatternURL,
             @(ADMatchLabelMatchTypeNumber)  : ADMatchLabelPatternNumber,
             @(ADMatchLabelMatchTypeEmail)   : ADMatchLabelPatternEmail,
             @(ADMatchLabelMatchTypeTopic)   : ADMatchLabelPatternTopic,
             @(ADMatchLabelMatchTypeAt)      : ADMatchLabelPatternAt,
             };
}

@end
