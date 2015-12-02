//
//  ViewController.m
//  objctest
//
//  Created by Main on 30.11.15.
//  Copyright © 2015 Aptito. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSArray *array1 = @[@"1", @"3", @"2"];
    NSArray *array2 = @[@"1", @"2", @"3"];
    
    if (array2.count != array1.count) {
        
    }
    
    NSMutableArray *intermediate = [NSMutableArray arrayWithArray:array1];
    [intermediate removeObjectsInArray:array2];
    NSUInteger difference = [intermediate count];
    
    if (difference==0) {
        NSLog(@"equal");
    }
    else {
        NSLog(@"not equal");
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
