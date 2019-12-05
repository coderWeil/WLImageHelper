//
//  ViewController.m
//  ImageDemo
//
//  Created by weil on 2019/12/4.
//  Copyright © 2019 AllYoga. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+Handler.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _test1];
}
- (void) _test1 {
    UIImage *image = [UIImage imageNamed:@"statistic_month_bg.jpg"];
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = image;//[image wl_changeBrightness:-0.1 saturation:1 contrast:1]
    [self.view addSubview:imageView];
    imageView.frame = CGRectMake(50, 100, 300, 200);
    
    UIView *view = [UIView new];
    view.frame = CGRectMake(100, CGRectGetMaxY(imageView.frame) + 50, 80, 80);
    view.backgroundColor = [imageView.image wl_mostColor];
    [self.view addSubview:view];
    
    UIImageView *otherImageView = [[UIImageView alloc] init];
//    otherImageView.image = [image wl_changeImageWithHueOffset:0 saturationOffset:20 brightnessOffset:120];
    otherImageView.image = [image wl_changeImageWithTintColor:[UIColor orangeColor] blendMode:kCGBlendModeMultiply];
    [self.view addSubview:otherImageView];
    otherImageView.frame = CGRectMake(50, CGRectGetMaxY(view.frame) + 50, 300, 200);
}

@end
