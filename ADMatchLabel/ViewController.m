//
//  ViewController.m
//  ADMatchLabel
//
//  Created by Andy on 2018/11/20.
//  Copyright © 2018 Andy. All rights reserved.
//

#import "ViewController.h"
#import "ADMatchLabel.h"

@interface ViewController ()<ADMatchLabelDelegate>

@property (nonatomic, strong) ADMatchLabel *label;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *text = nil;
    if (1) {
        // use this string can draw text in right way. :)
        // correct usedRectForTextContainer height, logged in ADMatchLabel.m line 88.
        text = @"今天 10:26 来自 微博 weibo.com#蒋劲夫承认家暴#并道歉：“这一个月一直在忏悔和悔恨中度过”。蒋劲夫日本留学期间曾卷入“出柜”疑云，后与日籍女友公开恋情，同游母校、一起庆生、为爱纹身";
    } else {
        // use this string can not draw text in right way. :(
        // incorrect usedRectForTextContainer height, logged in ADMatchLabel.m line 88.
        text = @"今天 10:26 来自 微博 weibo.com#蒋劲夫承认家暴#并道歉：“这一个月一直在忏悔和悔恨中度过”。蒋劲夫日本留学期间曾卷入“出柜”疑云，后与日籍女友公开恋情，同游母校、一起庆生、为爱纹身，恩爱甜蜜";
    }
    CGSize size = [text boundingRectWithSize:CGSizeMake(self.view.bounds.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18]} context:nil].size;
    NSLog(@"---- size -- %@", NSStringFromCGSize(size));
    
    self.label = [[ADMatchLabel alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, size.height)];
    self.label.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.3];
    self.label.numberOfLines = 0;
    self.label.delegate = self;
    self.label.font = [UIFont systemFontOfSize:18];
    self.label.text = text;
    
    [self.view addSubview:self.label];
}

- (void)linkLabelDidSelectedType:(ADMatchLabelMatchType)type content:(NSString *)content
{
    NSLog(@"--- %ld -- %@", (NSInteger)type, content);
}

@end
