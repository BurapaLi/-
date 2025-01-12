
//
//  ClassFiyViewController.m
//  HappyWeekDayer
//
//  Created by scjy on 16/1/6.
//  Copyright © 2016年 李志鹏. All rights reserved.
//

#import "ClassFiyViewController.h"
#import "AcitivyViewController.h"
#import "GoodModel.h"
#import "GoodTableViewCell.h"
#import "goodViewController.h"

@interface ClassFiyViewController ()<UITableViewDelegate,UITableViewDataSource,PullingRefreshTableViewDelegate>
@property (nonatomic, strong) PullingRefreshTableView *tableView;
@property (nonatomic, assign) BOOL refreshing;
@property (nonatomic, strong) NSMutableArray *showDataArray;//展示数据
@property (nonatomic, strong) NSMutableArray *showArray;
@property (nonatomic, strong) NSMutableArray *touristArray;
@property (nonatomic, strong) NSMutableArray *studentArray;
@property (nonatomic, strong) NSMutableArray *familyArray;
@property (nonatomic, strong) VOSegmentedControl *segmentedControl;

@end

@implementation ClassFiyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"分类列表";
    self.tabBarController.tabBar.hidden = YES;
    [self.view addSubview:self.tableView];
    [self showBackButtonWithImage:@"back"];
    [self.tableView registerNib:[UINib nibWithNibName:@"GoodTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:self.segmentedControl];
    [self getFourRequest];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [ProgressHUD dismiss];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.showDataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GoodTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.goodModel = self.showDataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"123" bundle:nil];
    AcitivyViewController *activityVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"ActivityDetailVC"];
    //活动id
    GoodModel *model = self.showDataArray[indexPath.row];
    activityVC.activityId = model.ID;
    activityVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:activityVC animated:YES];
}

- (void)showPreviousSelectButton{
    switch (self.classifyType) {
        case ClassifyTypeShowRepertorie:{
            self.showDataArray = self.showArray;
        }
            break;
        case ClassifyTypeTouristPlace:{
            self.showDataArray = self.touristArray;
        }
            break;
        case ClassifyTypeFamilyTravel:{
            self.showDataArray = self.studentArray;
        }
            break;
        case ClassifyTypeStudyPUZ:{
            self.showDataArray = self.familyArray;
        }
            break;
            
        default:
            break;
    }
    
    //完成加载
    [self.tableView tableViewDidFinishedLoading];
    self.tableView.reachedTheEnd = NO;
    //刷新tableView，他会重新执行tableView的所有代理方法
    [self.tableView reloadData];
}

#pragma mark    //数据请求
- (void)getFourRequest{
    switch (self.classifyType) {
        case ClassifyTypeShowRepertorie:{
            [self makeShow];
        }
            break;
        case ClassifyTypeTouristPlace:{
            [self makeTourist];
        }
            break;
        case ClassifyTypeFamilyTravel:{
            [self makeStudy];
        }
            break;
        case ClassifyTypeStudyPUZ:{
            [self makeFamily];
        }
            break;
            
        default:
            break;
            
    }
}
- (void)makeShow{
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    //演出剧目typeid=6
    [sessionManager GET:[NSString stringWithFormat:@"%@&page=%@&typeid=%@", kclass , @(1),@(6)] parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //        fSLog(@"%@",responseObject);
        NSDictionary *resultDic = responseObject;
        NSString *ststus = resultDic[@"status"];
        NSInteger code = [resultDic[@"code"] integerValue];
        if ([ststus isEqualToString:@"success"] && code == 0) {
            NSDictionary *dic = resultDic[@"success"];
            NSArray *acDataArray = dic[@"acData"];
            for (NSDictionary *dic in acDataArray) {
                GoodModel *model = [[GoodModel alloc] initWithDicticionary:dic];
                [self.showArray addObject:model];
            }
            //根据上一页选择的按钮，确定显示第几页数据
            [self showPreviousSelectButton];
            //刷新tableView,他会重新执行tableView的所有代理方法
            [self.tableView reloadData];
        }
 
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         
        fSLog(@"%@", error);
    }];
    
    
}
- (void)makeTourist{
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    //= 景点场馆23
    [sessionManager GET:[NSString stringWithFormat:@"%@&page=%@&typeid=%@", kclass , @(1),@(23)] parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *resultDic = responseObject;
        NSString *ststus = resultDic[@"status"];
        NSInteger code = [resultDic[@"code"] integerValue];
        
        if ([ststus isEqualToString:@"success"] && code == 0) {
            NSDictionary *dic = resultDic[@"success"];
            NSArray *acDataArray = dic[@"acData"];
            for (NSDictionary *dic in acDataArray) {
                GoodModel *model = [[GoodModel alloc] initWithDicticionary:dic];
                [self.touristArray addObject:model];
            }
            
            //根据上一页选择的按钮，确定显示第几页数据
            [self showPreviousSelectButton];
            //刷新tableView,他会重新执行tableView的所有代理方法
            [self.tableView reloadData];
        }
        
         
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         
        fSLog(@"%@", error);
    }];
    
    
}
- (void)makeStudy{
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    //= 学习益智21
    [sessionManager GET:[NSString stringWithFormat:@"%@&page=%@&typeid=%@", kclass , @(1),@(21)] parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *resultDic = responseObject;
        NSString *ststus = resultDic[@"status"];
        NSInteger code = [resultDic[@"code"] integerValue];
        
        if ([ststus isEqualToString:@"success"] && code == 0) {
            NSDictionary *dic = resultDic[@"success"];
            NSArray *acDataArray = dic[@"acData"];
            for (NSDictionary *dic in acDataArray) {
                GoodModel *model = [[GoodModel alloc] initWithDicticionary:dic];
                [self.studentArray addObject:model];
            }
            
            //根据上一页选择的按钮，确定显示第几页数据
            [self showPreviousSelectButton];
            //刷新tableView,他会重新执行tableView的所有代理方法
            [self.tableView reloadData];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         
        fSLog(@"%@", error);
    }];
    
    
}
- (void)makeFamily{
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    //= 22
    [sessionManager GET:[NSString stringWithFormat:@"%@&page=%@&typeid=%@", kclass , @(1),@(22)] parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *resultDic = responseObject;
        NSString *ststus = resultDic[@"status"];
        NSInteger code = [resultDic[@"code"] integerValue];
        
        if ([ststus isEqualToString:@"success"] && code == 0) {
            NSDictionary *dic = resultDic[@"success"];
            NSArray *acDataArray = dic[@"acData"];
            for (NSDictionary *dic in acDataArray) {
                GoodModel *model = [[GoodModel alloc] initWithDicticionary:dic];
                [self.familyArray addObject:model];
            }
            
            //根据上一页选择的按钮，确定显示第几页数据
            [self showPreviousSelectButton];
            //刷新tableView,他会重新执行tableView的所有代理方法
            [self.tableView reloadData];
            
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [ProgressHUD showError:[NSString stringWithFormat:@"%@",error]];
    }];
    
    
}


- (VOSegmentedControl *)segmentedControl
{
    if (!_segmentedControl) {
        self.segmentedControl = [[VOSegmentedControl alloc] initWithSegments:@[
                                                      @{VOSegmentText: @"演出剧目"},
                                                      @{VOSegmentText: @"景点场馆"},
                                                      @{VOSegmentText: @"学习益智"},
                                                      @{VOSegmentText: @"亲子旅游"}]];
        self.segmentedControl.contentStyle = VOContentStyleTextAlone;
        self.segmentedControl.indicatorStyle = VOSegCtrlIndicatorStyleBottomLine;
        self.segmentedControl.backgroundColor = [UIColor groupTableViewBackgroundColor];
        self.segmentedControl.selectedBackgroundColor = self.segmentedControl.backgroundColor;
        self.segmentedControl.allowNoSelection = NO;
        self.segmentedControl.frame = CGRectMake(0, 64, kWidth, 40);
        self.segmentedControl.indicatorThickness = 4;
        self.segmentedControl.tag = self.classifyType - 1;
        //返回点击的是哪个按钮
        [self.segmentedControl setIndexChangeBlock:^(NSInteger index) {
        }];
        [self.segmentedControl addTarget:self action:@selector(segmentCtrlValuechange:) forControlEvents:UIControlEventValueChanged];
    }
    return _segmentedControl;
}
- (void)segmentCtrlValuechange: (VOSegmentedControl *)segmentCtrl{
    self.classifyType = segmentCtrl.selectedSegmentIndex + 1;
    [self getFourRequest];
}
- (PullingRefreshTableView *)tableView
{
    if (!_tableView) {
        self.tableView = [[PullingRefreshTableView alloc] initWithFrame:CGRectMake(0, 40 + 64, kWidth, kHeight - 40 - 64) pullingDelegate:self];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.rowHeight = 90;
    }
    return _tableView;
}
- (NSMutableArray *)showArray
{
    if (!_showArray) {
        self.showArray = [[NSMutableArray alloc] init];
    }
    return _showArray;
}
- (NSMutableArray *)touristArray
{
    if (!_touristArray) {
        self.touristArray = [[NSMutableArray alloc] init];
    }
    return _touristArray;
}
- (NSMutableArray *)studentArray
{
    if (!_studentArray) {
        self.studentArray = [[NSMutableArray alloc] init];
    }
    return _studentArray;
}
- (NSMutableArray *)familyArray
{
    if (!_familyArray) {
        self.familyArray = [[NSMutableArray alloc] init];
    }
    return _familyArray;
}

@end

