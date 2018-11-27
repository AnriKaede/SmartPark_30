//
//  AddAloneFaceViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/24.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "AddAloneFaceViewController.h"

@interface AddAloneFaceViewController ()
{
    __weak IBOutlet UIImageView *_faceImgView;
    __weak IBOutlet UIButton *_changeFaceBt;
    __weak IBOutlet UITextField *_nameTF;
}
@end

@implementation AddAloneFaceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initView];
    
}

- (void)_initView {
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    if(_selImg){
        _faceImgView.image = _selImg;
    }
}

-(void)_leftBarBtnItemClick:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)changeFace:(id)sender {
}

@end
