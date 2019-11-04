//
//  ViewController.m
//  XHAudioDemo
//
//  Created by 向洪 on 2019/11/4.
//  Copyright © 2019 向洪. All rights reserved.
//

#import "ViewController.h"
#import "XHAudioRecordView.h"

@interface ViewController ()

@property (nonatomic, strong) XHAudioRecordView *recordView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _recordView = [XHAudioRecordView recordWithDuration:20];
    [_recordView show];
}


@end
