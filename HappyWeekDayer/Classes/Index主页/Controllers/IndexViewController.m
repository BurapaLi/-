//
//  IndexViewController.m
//  HappyWeekDayer
//
//  Created by scjy on 16/1/4.
//  Copyright © 2016年 李志鹏. All rights reserved.
//

#import "IndexViewController.h"
#import "IndexTableViewCell.h"
#import "IndexModel.h"
#import "SeletCityViewController.h"
#import "SearchViewController.h"
#import "AcitivyViewController.h"
#import "ThemeViewController.h"
#import "ClassFiyViewController.h"
#import "goodViewController.h"
#import "hotViewController.h"
#import "HWTitleButton.h"
#import "HeadScrollView.h"

@interface IndexViewController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,SeletCityViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
/** 全部列表数据 */
@property (nonatomic, strong) NSMutableArray *listArray;
/** 活动 */
@property (nonatomic, strong) NSMutableArray *activityAray;
/** 专题 */
@property (nonatomic, strong) NSMutableArray *themeArray;
/** 广告 */
@property (nonatomic, strong) NSMutableArray *adArray;
@property (nonatomic, retain) UIScrollView   *scrollView;
@property (nonatomic, retain) UIPageControl  *pageControl;
@property (nonatomic, retain) NSTimer        *timer;
@property (nonatomic, strong) UIButton       *activityBtn;
@property (nonatomic, strong) UIButton       *themeBtn;
/** 左按钮 */
@property (nonatomic, strong) UIButton *leftBtn;
/** 城市iD */
@property (nonatomic, copy) NSString *cityId;
@end

@implementation IndexViewController
#pragma mark    //559 203

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
    self.cityId = @"1";
}
- (void)viewDidLoad {
    [super viewDidLoad];
     //注册CELL 96 185 191 // 98 288 288
    [self.tableView registerNib:[UINib nibWithNibName:@"IndexTableViewCell"bundle:nil] forCellReuseIdentifier:@"cell"];
    [self button];
    [self requestModel];
    
    }
- (void)getcityName:(NSString *)cityName cityId:(NSString *)cityId{
    [self.leftBtn setTitle:cityName forState:UIControlStateNormal];
    self.cityId = cityId;
    [self requestModel];
    
}

- (void)configTableViewHeaderView{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWidth, 343)];
    self.tableView.tableHeaderView = headerView;
#pragma mark    //轮播图
    HeadScrollView *headScrollView = [[HeadScrollView alloc] initWithFrame:headerView.frame andbannerList:self.adArray];
    headScrollView.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH * self.adArray.count, SCREEN_HEIGHT * 0.2);
    for (int i = 100; i < 105; i++) {
        UIButton *btnbn = [self.view viewWithTag:i];
        btnbn.tag = i;
        [btnbn addTarget:self action:@selector(touchAdvertiseMent:) forControlEvents:UIControlEventTouchUpInside];
    }
    [headerView addSubview:headScrollView.scrollView];
    headScrollView.pageControl.numberOfPages = 5;
    [headerView addSubview:headScrollView.pageControl];
  
    //4+2
    //按钮
    for (int i = 0; i < 4; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(i * kWidth / 4 + 10, 196, kWidth / 4 * 2 / 3, 157 / 2 - 10);
        NSString *imageStr = [NSString stringWithFormat:@"home_icon_%d", i + 1];
        [btn setImage:[UIImage imageNamed:imageStr] forState:UIControlStateNormal];
        btn.tag = 100 + i;
        [btn addTarget:self action:@selector(mainActivityButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:btn];
    }
    //精选活动
    [headerView addSubview:self.activityBtn];
    //热门专题
    [headerView addSubview:self.themeBtn];
 

}
#pragma mark    //滚图按钮
- (void)touchAdvertiseMent:(UIButton *)adButton{
    //从数组中的字典里取出type类型
    NSString *type = self.adArray[adButton.tag - 100][@"type"];
    if ([type integerValue] == 1) {
        
        UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Index" bundle:nil];
        AcitivyViewController *activityVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"123"];
        
        activityVC.activityId = self.adArray[adButton.tag - 100][@"id"];
        [self.navigationController pushViewController:activityVC animated:YES];
    } else {
        ThemeViewController *themeVC = [[ThemeViewController alloc] init];
//        themeVC.hidesBottomBarWhenPushed = YES;
        themeVC.themeid = self.adArray[adButton.tag - 100][@"id"];
        [self.navigationController pushViewController:themeVC animated:YES];
    }
}

#pragma mark    //精选活动
- (UIButton *)activityBtn{
    if (_activityBtn == nil) {
        self.activityBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.activityBtn.frame = CGRectMake(10, 186 + 157 / 2 + 10, kWidth / 2 - 10, 157 / 2 - 10);
        [self.activityBtn setImage:[UIImage imageNamed:@"home_huodong"] forState:UIControlStateNormal];
        self.activityBtn.tag = 104;
        [self.activityBtn addTarget:self action:@selector(goodActivityButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _activityBtn;
}

#pragma mark    //热门专题
- (UIButton *)themeBtn{
    if (_themeBtn == nil) {
        self.themeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.themeBtn.frame = CGRectMake(kWidth / 2, 186 + 157 / 2 + 10, kWidth / 2 - 10, 157 / 2 - 10);
        [self.themeBtn setImage:[UIImage imageNamed:@"home_zhuanti"] forState:UIControlStateNormal];
        self.themeBtn.tag = 105;
        [self.themeBtn addTarget:self action:@selector(hotActivityButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _themeBtn;
}

#pragma mark    //四个方框按钮方法
- (void)mainActivityButtonAction:(UIButton *)Btn{
    
    ClassFiyViewController *o = [[ClassFiyViewController alloc] init];
    o.classifyType = Btn.tag - 100 + 1;
    [self.navigationController pushViewController:o animated:YES];
}
#pragma mark    //下边两个方框按钮方法
- (void)goodActivityButtonAction{
    
    goodViewController *o = [[goodViewController alloc] init];
    [self.navigationController pushViewController:o animated:YES];
}
- (void)hotActivityButtonAction{
    
    hotViewController *o = [[hotViewController alloc] init];
    [self.navigationController pushViewController:o animated:YES];
}

//======================================================================
//======================================================================
#pragma mark    //数据请求
- (void)requestModel{
    NSNumber *lat = kUDDS(lat);
    NSNumber *lng = kUDDS(lng);
    NSString *URLString = [NSString stringWithFormat:kIndexDataList,self.cityId,lat,lng];
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [sessionManager GET:URLString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {

    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self make:responseObject];
        
        [self configTableViewHeaderView];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        fSLog(@"%@",error);
    }];
    
}

#pragma mark    //解析数据
- (void)make:(NSDictionary *)responseObject{
    NSDictionary *resultDic = responseObject;
    NSString *ststus = resultDic[@"status"];
    NSInteger code = [resultDic[@"code"] integerValue];
    
    if ([ststus isEqualToString:@"success"] && code == 0) {
        NSDictionary *dic = resultDic[@"success"];
        //推荐活动
        NSArray *acDataArray = dic[@"acData"];
        for (NSDictionary *dict in acDataArray) {
            IndexModel *model = [IndexModel getDictionary:dict];
            [self.activityAray addObject:model];
        }
        [self.listArray addObject:self.activityAray];
        
        //推荐专题
        NSArray *rcDataArray = dic[@"rcData"];
        for (NSDictionary *dict in rcDataArray) {
            IndexModel *model = [IndexModel getDictionary:dict];
            [self.themeArray addObject:model];
        }
        [self.listArray addObject:self.themeArray];
        [self.tableView reloadData];
        
        //推荐广告
        NSArray *adDataArray = dic[@"adData"];
        for (NSDictionary *dic in adDataArray) {
            NSDictionary *dict = @{@"url" : dic[@"url"], @"type" : dic[@"type"], @"id" : dic[@"id"]};
            [self.adArray addObject:dict];
        }
        [self configTableViewHeaderView];
        
        NSString *cityName = dic[@"cityname"];
        /* 以请求回来的城市作为导航栏按钮标题 */
        self.navigationItem.leftBarButtonItem.title = cityName;
    }
}

#pragma mark    //导航栏按钮
- (void)button{
    
//    HWTitleButton *titleButton = [[HWTitleButton alloc] init];
//    [titleButton setTitle:@"北京" forState:UIControlStateNormal];
//    self.navigationItem.titleView = titleButton;
    
//        UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithTitle:@"北京" style:UIBarButtonItemStylePlain target:self action:@selector(selectCityBtn:)];
//        self.navigationItem.leftBtnBarButtonItem = leftBtn;
    
//    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(seacherActityBtn:)];
//    self.navigationItem.rightBarButtonItem = right;
    
    self.leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.leftBtn.frame = CGRectMake(0, 0, 60, 60);
    [self.leftBtn setImage:[UIImage imageNamed:@"btn_chengshi"] forState:UIControlStateNormal];
    [self.leftBtn setTitle:@"北京" forState:UIControlStateNormal];
    self.leftBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 40, 0, 0);
    self.leftBtn.titleEdgeInsets = UIEdgeInsetsMake(0, - 40, 0, 0);
    [self.leftBtn addTarget:self action:@selector(selectCityBtn:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarBtn = [[UIBarButtonItem alloc] initWithCustomView:self.leftBtn];
    self.navigationItem.leftBarButtonItem = leftBarBtn;
 
   UIButton *right = [UIButton buttonWithType:UIButtonTypeCustom];
   right.frame = CGRectMake(kWidth - 20, 0, 20, 20);
   [right setImage:[UIImage imageNamed:@"btn_search.png"] forState:UIControlStateNormal];
   [right addTarget:self action:@selector(seacherActityBtn:) forControlEvents:UIControlEventTouchUpInside];
   UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithCustomView:right];
   self.navigationItem.rightBarButtonItem = rightBtn;
 
    
    
}

#pragma mark    //导航栏按钮点击方法
- (void)selectCityBtn:(UIBarButtonItem *)barButton{
    SeletCityViewController *o = [[SeletCityViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:o];
    o.delegate = self;
    o.city = self.leftBtn.titleLabel.text;

    [self presentViewController:nav animated:YES completion:nil];
    
}
- (void)seacherActityBtn:(UIBarButtonItem *)barButton{
    SearchViewController *o = [[SearchViewController alloc] init];
    [self.navigationController pushViewController:o animated:YES];
    
}

#pragma mark    //自定义头部
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *view = [[UIView alloc] init];
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(kWidth / 2 - 160, 5, 414, 16)];
    if (section == 0) {
        imageview.image = [UIImage imageNamed:@"home_recommed_ac"];
    }else{
        imageview.image = [UIImage imageNamed:@"home_recommd_rc"];
    }
    [view addSubview:imageview];
    
    
    return view;
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section == 0) {
        return self.activityAray.count;
    }
     return self.themeArray.count;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 203;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    IndexTableViewCell *indexCell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    indexCell.contentView.backgroundColor = [UIColor colorWithRed:arc4random() %256/255.0f green:arc4random() %256/255.0f blue:arc4random() %256/255.0f alpha:arc4random() %256/255.0f];
    indexCell.model = self.listArray[indexPath.section][indexPath.row];
    return indexCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        AcitivyViewController *o = [[AcitivyViewController alloc] init];
        [self.navigationController pushViewController:o animated:YES];

    }else{
        ThemeViewController *o = [[ThemeViewController alloc] init];
        [self.navigationController pushViewController:o animated:YES];
    }
}

- (NSMutableArray *)listArray
{
    if (!_listArray) {
        self.listArray = [[NSMutableArray alloc] init];
    }
    return _listArray;
}
- (NSMutableArray *)activityAray
{
    if (!_activityAray) {
        self.activityAray = [[NSMutableArray alloc] init];
    }
    return _activityAray;
}
- (NSMutableArray *)themeArray
{
    if (!_themeArray) {
        self.themeArray = [[NSMutableArray alloc] init];
    }
    return _themeArray;
}
- (NSMutableArray *)adArray
{
    if (!_adArray) {
        self.adArray = [[NSMutableArray alloc] init];
    }
    return _adArray;
}

@end




























