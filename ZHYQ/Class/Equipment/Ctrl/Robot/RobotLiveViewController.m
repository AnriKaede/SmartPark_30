//
//  RobotLiveViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2019/2/27.
//  Copyright © 2019 焦平. All rights reserved.
//

#import "RobotLiveViewController.h"
#import <NodeMediaClient/NodeMediaClient.h>
#import "MQTTTool.h"

@interface RobotLiveViewController ()<NodePlayerDelegate>
{
    __weak IBOutlet UIView *_liveView;
    
    __weak IBOutlet UIButton *_saveBt;
    __weak IBOutlet UIButton *_screenshotBt;
    __weak IBOutlet UIButton *_deleteBt;
    
    __weak IBOutlet UILabel *_saveLabel;
    __weak IBOutlet UILabel *_screenshotLabel;
    __weak IBOutlet UILabel *_deleteLabel;
    __weak IBOutlet UIImageView *shootScreenImgView;
    __weak IBOutlet UIView *moveBgView;
}
@property (strong,nonatomic) NodePlayer *np;
@end

@implementation RobotLiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initView];
    
    [self _initPlay];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [_np stop];
}

- (void)_initView {
    self.view.backgroundColor = [UIColor blackColor];
    
    _saveBt.hidden = YES;
    _deleteBt.hidden = YES;
    _saveLabel.hidden = YES;
    _deleteLabel.hidden = YES;
}

- (void)_initPlay {
    _np = [[NodePlayer alloc] init];
    [_np setPlayerView:_liveView];
    [_np setInputUrl:@"rtmp://demo.easydss.com:10085/live/stream_299555?k=stream_299555.27ab2b67a1262f5c07"];
    _np.nodePlayerDelegate = self;
    [_np start];
}
- (void)onEventCallback:(nonnull id)sender event:(int)event msg:(nonnull NSString*)msg {
    NSLog(@"event: %d,===== %@", event, msg);
}

- (IBAction)closeActionn:(id)sender {
    [[MQTTTool shareInstance] sendDataToTopic:@"liveClose" string:@""];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveActionn:(id)sender {
    shootScreenImgView.hidden = YES;
    
    if(shootScreenImgView.image){
        UIImageWriteToSavedPhotosAlbum(shootScreenImgView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    [self showHint:@"截图保存成功"];
    shootScreenImgView.hidden = YES;
    
    _saveBt.hidden = YES;
    _deleteBt.hidden = YES;
    _saveLabel.hidden = YES;
    _deleteLabel.hidden = YES;
    _screenshotBt.hidden = NO;
    _screenshotLabel.hidden = NO;
    moveBgView.hidden = NO;
}

- (IBAction)shootScreen:(id)sender {
    _saveBt.hidden = NO;
    _deleteBt.hidden = NO;
    _saveLabel.hidden = NO;
    _deleteLabel.hidden = NO;
    _screenshotBt.hidden = YES;
    _screenshotLabel.hidden = YES;
    moveBgView.hidden = YES;
    
    shootScreenImgView.hidden = NO;
    
    shootScreenImgView.image = [self nomalSnapshotImage];
}
- (IBAction)deleteAction:(id)sender {
    shootScreenImgView.hidden = YES;
    
    _saveBt.hidden = YES;
    _deleteBt.hidden = YES;
    _saveLabel.hidden = YES;
    _deleteLabel.hidden = YES;
    _screenshotBt.hidden = NO;
    _screenshotLabel.hidden = NO;
    moveBgView.hidden = NO;
}

- (UIImage *)nomalSnapshotImage
{
    CGSize size = _liveView.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    [_liveView drawViewHierarchyInRect:rect afterScreenUpdates:YES];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return snapshotImage;
}

- (IBAction)moveRight:(id)sender {
    [[MQTTTool shareInstance] sendDataToTopic:@"move" string:@"right"];
}

- (IBAction)moveTop:(id)sender {
    [[MQTTTool shareInstance] sendDataToTopic:@"move" string:@"front"];
}

- (IBAction)moveDown:(id)sender {
    [[MQTTTool shareInstance] sendDataToTopic:@"move" string:@"back"];
}

- (IBAction)moveLeft:(id)sender {
    [[MQTTTool shareInstance] sendDataToTopic:@"move" string:@"left"];
}

@end
