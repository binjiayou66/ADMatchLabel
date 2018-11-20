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
    
    NSString *text = @"@某人 今天 10:26 来自 微博 weibo.com @某人 #蒋劲夫承认家暴#并道歉：“这一个月一直在忏悔和悔恨中度过”。蒋劲夫日本留学期间曾卷入“出柜”疑云，http://www.baidu.com 后与日籍女友公开恋情，http://baidu.com 同游母校、一起庆生、为爱纹身，https://baidu.com 恩爱甜蜜瞬间仿佛还在眼前。baidu.com 此次本人承认坐实“家暴”令人唏嘘。7月15日，蒋劲夫微博晒照公布恋情；7月25日，13655556666蒋劲夫首次晒出女友正面照，女方睡着后依偎在蒋劲夫臂弯，他用手托住女友下巴然后偷拍，十分甜蜜；8月14日，有网友爆料称在长沙雅礼中19266557788学偶遇蒋劲夫牵手日本女友同游母校；9月2日，蒋劲夫与女友共庆27岁生日；9月13日，蒋劲夫与日籍女友一同回京，穿白T恤情侣look亮相机场恩爱甜蜜；9月14日，蒋劲夫为爱纹身高调告白女友：相遇是上帝的安排；11月20日，蒋劲夫发微博承认家暴并道歉。";
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
