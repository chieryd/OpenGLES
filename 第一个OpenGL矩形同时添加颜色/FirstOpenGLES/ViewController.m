//
//  ViewController.m
//  FirstOpenGLES
//
//  Created by chiery on 2017/2/10.
//  Copyright © 2017年 qunar. All rights reserved.
//

#import "ViewController.h"
#import "glView.h"

@interface ViewController ()

@property (nonatomic, strong) glView *glView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view addSubview:self.glView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (glView *)glView {
    if (!_glView) {
        _glView = [[glView alloc] initWithFrame:self.view.bounds];
    }
    return _glView;
}


@end
