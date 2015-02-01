//
//  MenuItemsTVC.m
//  ObjCExample
//
//  Created by Evgeny on 09.01.15.
//  Copyright (c) 2015 Evgeny Nazarov. All rights reserved.
//

#import "MenuItemsTVC.h"
#import "objcexample-Swift.h"

@implementation MenuItemsTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView setContentInset:UIEdgeInsetsMake(64.f, 0, 0, 0)];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.backgroundColor = [UIColor clearColor];
        UIView *selectionView = [[UIView alloc] initWithFrame:cell.bounds];
        selectionView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3f];
        [cell setSelectedBackgroundView:selectionView];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"Row %ld", (long)indexPath.row];
    
    return cell;
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *destTVC = nil;
    switch (indexPath.row) {
        case 0:
            destTVC = [storyboard instantiateViewControllerWithIdentifier:@"ViewController1"];
            break;
        default:
            destTVC = [storyboard instantiateViewControllerWithIdentifier:@"ViewController2"];
            break;
    }
    
    [self.sideMenuController setContentViewController:destTVC];
}

@end
