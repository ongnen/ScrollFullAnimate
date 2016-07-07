//
//  ViewController.m
//  FullSkimAnimate
//
//  Created by zyj on 16/7/7.
//  Copyright © 2016年 zyj. All rights reserved.
//

#define MainWidth [UIScreen mainScreen].bounds.size.width
#define MainHeight [UIScreen mainScreen].bounds.size.height
#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, weak) UITableView *testTableV;
@property (nonatomic, strong) UIImageView *coverImageV;
@property (nonatomic, assign) CGFloat currentOffsetY;
@property (nonatomic, assign) CGFloat previousOffsetY;
@property (nonatomic, assign) BOOL isEnd;
@property (nonatomic, assign) BOOL isHide;
@property (nonatomic, assign) BOOL isFirstDraw;
@property (nonatomic, assign) BOOL isMamualDrag;
@end

@implementation ViewController

- (UIImageView *)coverImageV
{
    if (!_coverImageV) {
        _coverImageV = [[UIImageView alloc] init];
    }
    return _coverImageV;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // 设置必要的属性
    self.automaticallyAdjustsScrollViewInsets = NO;
    // 初始化_isFirstDraw
    _isFirstDraw = YES;
    // 创建TestTableV
    [self setTestTableV];
}
// 创建TestTableV
- (void)setTestTableV
{
    // 创建好TestTableV，并设置上必要的属性
    UITableView  *testTableV = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, MainWidth, MainHeight+49) style:UITableViewStylePlain];
    testTableV.contentInset = UIEdgeInsetsMake(65, 0, 49, 0);
    testTableV.contentOffset = CGPointMake(0, -65);
    testTableV.delegate = self;
    testTableV.dataSource = self;
    [self.view addSubview:testTableV];
    _testTableV = testTableV;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"数据%ld",indexPath.row];
    return cell;
}


#pragma mark - 动画核心代码
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 1.以下情况不进行动画
    if (_isEnd || !_isMamualDrag) return;
    // 2.计算核心数据_currentOffsetY
    CGFloat offsetY = scrollView.contentOffset.y;
    // 2.1单次偏移差的计算oneTimeOffsetY
    CGFloat oneTimeOffsetY = offsetY - _previousOffsetY;
    if ((oneTimeOffsetY>=0 && _currentOffsetY<=128) || (oneTimeOffsetY<=0 && _currentOffsetY>=0)) {
        _currentOffsetY = _currentOffsetY + oneTimeOffsetY;
    }
    _currentOffsetY>=128 ? _currentOffsetY=128 : _currentOffsetY;
    _currentOffsetY<=0 ? _currentOffsetY=0 : _currentOffsetY;
    // 3.开始改变偏移值
    self.navigationController.tabBarController.view.frame = CGRectMake(0, 0, MainWidth, MainHeight+_currentOffsetY/2);
    _coverImageV.frame = CGRectMake(0, -_currentOffsetY/2, MainWidth, 65);
    // 4.获得当前偏移值，用以计算两次方法调用时的偏移差
    _previousOffsetY = offsetY;
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (_isFirstDraw) {
        // 第一次拖拽时画导航条
        UIImage *coverImage = [self drawNavBar];
        self.coverImageV.image = coverImage;
        _isFirstDraw = NO;
        _isMamualDrag = YES;
    }
    // 所需相关设置
    self.navigationController.navigationBarHidden = YES;;
    [[UIApplication sharedApplication].keyWindow addSubview:self.coverImageV];
    _isEnd = NO;
}
#pragma mark - 动画核心代码
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
    _isEnd = YES;
    // 结束时的动画代码
    if (_currentOffsetY>60) {
        [UIView animateWithDuration:0.2 animations:^{
            self.navigationController.tabBarController.view.frame = CGRectMake(0, 0, MainWidth, MainHeight+60);
            _coverImageV.frame = CGRectMake(0, -65, MainWidth, 65);
        } completion:^(BOOL finished) {
            [_coverImageV removeFromSuperview];
        }];
        _currentOffsetY = 128;
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            self.navigationController.tabBarController.view.frame = CGRectMake(0, 0, MainWidth, MainHeight);
            _coverImageV.frame = CGRectMake(0, 0, MainWidth, 65);
        } completion:^(BOOL finished) {
            self.navigationController.navigationBarHidden = NO;
            [_coverImageV removeFromSuperview];
        }];
        _currentOffsetY = 0;  
    }
}

// 将导航条截图
- (UIImage *)drawNavBar
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(MainWidth, 65), NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self.navigationController.tabBarController.view.layer renderInContext:ctx];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    return image;
    _isEnd = YES;
}
@end
