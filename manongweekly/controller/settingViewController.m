//
//  settingViewController.m
//  manongweekly
//
//  Created by xiangwenwen on 15/5/8.
//  Copyright (c) 2015年 xiangwenwen. All rights reserved.
//

#import "settingViewController.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "MNSettingCell.h"
#import "referralPageViewController.h"
#import "readingChartViewController.h"
#import "privacyPolicyViewController.h"


@interface settingViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *settingTable;
@property (strong, nonatomic) NSArray *dataSource;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *showLoading;
@property (weak, nonatomic) IBOutlet UIView *showShade;
@property (strong, nonatomic) NSDictionary *identifierMap;
@property (strong, nonatomic) UISwitch *dknightSwitchView;
@property (strong, nonatomic) UIApplication *application;

@end

@implementation settingViewController

-(UIApplication *)application
{
    if (!_application) {
        _application = [UIApplication sharedApplication];
    }
    return _application;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //mailto:xiangwenwe@foxmail.com?SUBJECT=About 猿已阅
    //https://itunes.apple.com/cn/app/yuan-yi-yue/id990227579?l=en&mt=8
    /*
     @{
        @"setName":@"隐私政策",
        @"setIcon":@"PrivacyImage"
     }
     
     @"隐私政策":@"privacyPolicyPage"
     
     @{
        @"setName":@"订阅《码农周刊》快捷通道",
        @"setIcon":@"ManongRessImage"
     }
     
     */
    
    self.dataSource = @[
                        @[
                            @{
                                @"setName":@"图表天梯",
                                @"setIcon":@"RankFillImage"
                                },
                            @{
                                @"setName":@"应用介绍",
                                @"setIcon":@"ProtocolReadImage"
                                }
                            ],
                        @[
                            @{
                                @"setName":@"意见反馈",
                                @"setIcon":@"ToMessageMeImage"
                                },
                            @{
                                @"setName":@"给个好评",
                                @"setIcon":@"ToLikeMeImage"
                                },
                            @{
                                @"setName":@"更新分类",
                                @"setIcon":@"UpdateTagImage"
                                },
                            @{
                                @"setName":@"清除缓存",
                                @"setIcon":@"ClearCacheImage"
                                }
                            ]
                        ];
    
    self.navigationItem.title = @"设置";
    self.settingTable.dataSource = self;
    self.settingTable.delegate = self;
    self.identifierMap = @{
                           @"图表天梯":@"readingChart",
                           @"应用介绍":@"referralPage"
                           };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backIndexView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)toNightChange{}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource[section] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MNSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MNSettingCell" forIndexPath:indexPath];
    cell.section = indexPath.section;
    cell.MNSettingInfo = self.dataSource[indexPath.section][indexPath.row];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    __weak settingViewController *weakSelf = self;
    return [tableView fd_heightForCellWithIdentifier:@"MNSettingCell" configuration:^(MNSettingCell *cell) {
        cell.MNSettingInfo = weakSelf.dataSource[indexPath.section][indexPath.row];
    }];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *cellInfo =  self.dataSource[indexPath.section][indexPath.row];
    NSString *tag = cellInfo[@"setName"];
    
    if (!self.identifierMap[tag]) {
        if([tag isEqualToString:@"更新分类"]) {
            [self dismissViewControllerAnimated:YES completion:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kFetchGithubManongData" object:nil];
        }else{
            if([tag isEqualToString:@"清除缓存"]){
                self.showLoading.hidden = NO;
                self.showShade.hidden = NO;
                NSString *cache = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
                NSFileManager *manager = [[NSFileManager alloc] init];
                NSArray *files = [manager subpathsAtPath:cache];
                __weak settingViewController *weakSelf = self;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    for (NSString *filePath in files) {
                        NSError *error = nil;
                        NSString *fileP = [cache stringByAppendingPathComponent:filePath];
                        NSFileManager *fileManager = [[NSFileManager alloc] init];
                        if ([fileManager fileExistsAtPath:fileP]) {
                            [fileManager removeItemAtPath:fileP error:&error];
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf dismissViewControllerAnimated:YES completion:nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"kRemoveCacheSuccess" object:nil];
                    });
                });
            }
            
//            if ([tag isEqualToString:@"订阅《码农周刊》快捷通道"]) {
//                UIAlertView *alert = [[UIAlertView alloc] init];
//                alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
//                [alert addButtonWithTitle:@"取消"];
//                [alert addButtonWithTitle:@"确认"];
//                alert.title = @"输入email订阅《码农周刊》";
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [alert show];
//                });
//            }
            
            if ([tag isEqualToString:@"意见反馈"]) {
                NSMutableString *mailUrl = [[NSMutableString alloc]init];
                //添加收件人
                NSArray *toRecipients = [NSArray arrayWithObject: @"xiangwenwe@foxmail.com"];
                [mailUrl appendFormat:@"mailto:%@", [toRecipients componentsJoinedByString:@","]];
                //添加主题
                [mailUrl appendString:@"?subject=About 猿已阅"];
                NSString *email = [mailUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
                [self.application openURL:[NSURL URLWithString:email]];
            }
            
            if ([tag isEqualToString:@"给个好评"]) {
                NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/cn/app/yuan-yi-yue/id990227579?l=en&mt=8"];
                [self.application openURL:url];
            }
        }
    }else{
        NSString *identifier = self.identifierMap[tag];
        if ([identifier isEqualToString:@"referralPage"]) {
            referralPageViewController *referral = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
            referral.referraTitle = tag;
            [self.navigationController pushViewController:referral animated:YES];
        }else if ([identifier isEqualToString:@"readingChart"]){
            readingChartViewController *readChart = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
            readChart.readingChartTitle = tag;
            readChart.manager = self.manager;
            [self.navigationController pushViewController:readChart animated:YES];
        }
//        else if ([identifier isEqualToString:@"privacyPolicyPage"]){
//            privacyPolicyViewController *policy = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
//            policy.policyTitle = tag;
//            [self.navigationController pushViewController:policy animated:YES];
//        }
    }
    
}

-(void)dealloc
{
    NSLog(@"setting view controller 释放");
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
