//
//  GraphListTableViewController.m
//  Graph_Demo
//
//  Created by weiweilong on 2017/10/31.
//  Copyright © 2017年 weiweilong. All rights reserved.
//

#import "GraphListTableViewController.h"
#import "PostViewController.h"
#import "ThreadViewController.h"
#import "RoundViewController.h"

@interface GraphListTableViewController ()

@end

@implementation GraphListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
        {
            // 折线
            ThreadViewController *threadVC = [[ThreadViewController alloc] init];
            [self.navigationController pushViewController:threadVC animated:YES];
            break;
        }
            
        case 1:
        {
            // 柱状
            PostViewController *postVC = [[PostViewController alloc] init];
            [self.navigationController pushViewController:postVC animated:YES];
            break;
        }
            
        case 2:
        {
            // 饼状
            RoundViewController *roundVC = [[RoundViewController alloc] init];
            [self.navigationController pushViewController:roundVC animated:YES];
            break;
        }
            
                }
}

@end
