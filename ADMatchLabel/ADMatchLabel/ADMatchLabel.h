//
//  ADMatchLabel.h
//  ADMatchLabel
//
//  Created by Andy on 2018/11/20.
//  Copyright © 2018 Andy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ADMatchLabelMatchType) {
    ADMatchLabelMatchTypeURL,
    ADMatchLabelMatchTypeNumber,
    ADMatchLabelMatchTypeEmail,
    ADMatchLabelMatchTypeTopic,
    ADMatchLabelMatchTypeAt,
};

@protocol ADMatchLabelDelegate <NSObject>

- (void)linkLabelDidSelectedType:(ADMatchLabelMatchType)type content:(NSString *)content;

@end

NS_ASSUME_NONNULL_BEGIN

@interface ADMatchLabel : UILabel

@property (nonatomic, weak) id<ADMatchLabelDelegate> delegate;
/// 文本匹配类型数组，点击时，按照数组顺序作为优先级进行匹配，一旦匹配到则不进行后面的匹配了
@property (nonatomic, strong) NSArray<NSNumber *> *matchTypes;
@property (nonatomic, strong) UIColor *matchColor;

@end

NS_ASSUME_NONNULL_END
