//
//  RobotLiveViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2019/2/27.
//  Copyright © 2019 焦平. All rights reserved.
//

#import "RobotLiveViewController.h"

@interface RobotLiveViewController ()
{
    __weak IBOutlet UIView *_liveView;
    
    __weak IBOutlet UIButton *_saveBt;
    __weak IBOutlet UIButton *_screenshotBt;
    __weak IBOutlet UIButton *_deleteBt;
    
    __weak IBOutlet UILabel *_saveLabel;
    __weak IBOutlet UILabel *_screenshotLabel;
    __weak IBOutlet UILabel *_deleteLabel;
}
@end

@implementation RobotLiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initView];
}

- (void)_initView {
    self.view.backgroundColor = [UIColor blackColor];
    
    _saveBt.hidden = YES;
    _deleteBt.hidden = YES;
    _saveLabel.hidden = YES;
    _deleteLabel.hidden = YES;
}

- (IBAction)closeActionn:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveActionn:(id)sender {
    
}
- (IBAction)shootScreen:(id)sender {
    _saveBt.hidden = NO;
    _deleteBt.hidden = NO;
    _saveLabel.hidden = NO;
    _deleteLabel.hidden = NO;
    _screenshotBt.hidden = YES;
    _screenshotLabel.hidden = YES;
}
- (IBAction)deleteAction:(id)sender {
    
}

@end
