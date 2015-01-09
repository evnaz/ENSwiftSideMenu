//
//  ViewController.m
//  ObjCExample
//
//  Created by Evgeny on 09.01.15.
//  Copyright (c) 2015 Evgeny Nazarov. All rights reserved.
//

#import "ViewController.h"
#import "objcexample-Swift.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIBarButtonItem *toggleButton = [[UIBarButtonItem alloc] initWithTitle:@"Toggle" style:UIBarButtonItemStylePlain target:self action:@selector(toggleSideMenuView)];
    [self.navigationItem setLeftBarButtonItem:toggleButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
