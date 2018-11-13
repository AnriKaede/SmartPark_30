//
//  HomeBgMusicTabViewController.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/20.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "HomeBgMusicTabViewController.h"

@interface HomeBgMusicTabViewController ()

@property (weak, nonatomic) IBOutlet UIView *topBgView;
@property (weak, nonatomic) IBOutlet UILabel *inDoorMusicLab;
@property (weak, nonatomic) IBOutlet UILabel *outDoorMusicLab;
@property (weak, nonatomic) IBOutlet UILabel *indoorPlayLab;
@property (weak, nonatomic) IBOutlet UILabel *outDoorPlayLab;
@property (weak, nonatomic) IBOutlet UILabel *inDoorMusicDetailLab;
@property (weak, nonatomic) IBOutlet UILabel *outDoorMusicDetailLab;
@property (weak, nonatomic) IBOutlet UIButton *InDoorChangeBgMusicBtn;
@property (weak, nonatomic) IBOutlet UIButton *outDoorChangeBgMusicBtn;

@end

@implementation HomeBgMusicTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initView];
    
    [self _initNavItems];
}

-(void)_initView
{
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"E2E2E2"];
    self.indoorPlayLab.textColor = [UIColor colorWithHexString:@"#35FF33"];
    self.outDoorPlayLab.textColor = [UIColor colorWithHexString:@"#35FF33"];
    self.topBgView.backgroundColor = [UIColor colorWithHexString:@"1B82D1"];
    [self.InDoorChangeBgMusicBtn setTitleColor:[UIColor colorWithHexString:@"1B82D1"] forState:UIControlStateNormal];
    [self.outDoorChangeBgMusicBtn setTitleColor:[UIColor colorWithHexString:@"1B82D1"] forState:UIControlStateNormal];
    
    _inDoorMusicLab.text = _indoorMusic;
    _outDoorMusicLab.text = _outdoorMusic;
}

-(void)_initNavItems
{
    self.title = @"音乐";
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;

}

-(void)_leftBarBtnItemClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)inDoorChangeBgMusicClick:(id)sender {
    
    
}

- (IBAction)outDoorChangeBgMusicClick:(id)sender {
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
//    return 0;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
