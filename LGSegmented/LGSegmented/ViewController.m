//
//  ViewController.m
//  LGSegmented
//
//  Created by 李堪阶 on 16/7/5.
//  Copyright © 2016年 DM. All rights reserved.
//

#import "ViewController.h"
#import "WJItemsControlView.h"

#define screenWidth [UIScreen mainScreen].bounds.size.width
#define screenHeiht [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property (strong,nonatomic) UIScrollView *scrollView;

@property (strong ,nonatomic) WJItemsControlView *itemControlView;

@property (strong ,nonatomic) NSMutableArray *dataArray;

@property (strong ,nonatomic) NSMutableArray *tableArray;

@property (strong ,nonatomic) NSArray *typeArray;

@property (strong ,nonatomic) NSMutableSet *set;

@property (assign ,nonatomic) NSInteger index;

@property (assign ,nonatomic) BOOL isRefresh;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.index = 0;
    
    [self setupUI];
    
    [self loadData];
}


- (void)loadData{
    
    
    NSMutableArray *array = self.dataArray[self.index];
    
    for (int i = 0; i < 20; i++) {
        
        [array addObject:[NSString stringWithFormat:@"%@随机数据---%d",self.typeArray[self.index], arc4random_uniform(1000000)]];
    }
    
    self.dataArray[self.index] = array;
    
    UITableView *tableView = self.tableArray[self.index];
    
    [tableView reloadData];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (scrollView == self.scrollView) {
        
        CGFloat offset = scrollView.contentOffset.x;
        
        offset = offset / CGRectGetWidth(scrollView.frame);
        
        [_itemControlView moveToIndex:offset];
        
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    if (scrollView == self.scrollView) {
        
        CGFloat offset = scrollView.contentOffset.x;
        
        offset = offset / CGRectGetWidth(scrollView.frame);
        
        [_itemControlView endMoveToIndex:offset];
        
        self.index = (int)offset;
        
        NSString *type = [NSString stringWithFormat:@"%zd",self.index];
        
        [self.set enumerateObjectsUsingBlock:^(NSString *obj, BOOL * _Nonnull stop) {
           
            self.isRefresh = [obj isEqualToString:type];
            
            *stop = self.isRefresh;
        }];
        
        [self.set addObject:type];
        
        if (!self.isRefresh) {//需要刷新
            
            //加载数据
            [self loadData];
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSMutableArray *array = self.dataArray[self.index];
    
    UITableView *table = self.tableArray[self.index];
    
    if (tableView == table) {
        
        return array.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *ID = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    NSMutableArray *array = self.dataArray[self.index];
    
    
    cell.textLabel.text = array[indexPath.row];
    
    return cell;
}

#pragma mark - UI

- (void)setupUI{
    
    self.typeArray = @[@"要闻",@"视频",@"广东",@"广州",@"财经",@"娱乐",@"社会",@"军事"];
    
    //头部控制的segMent
    WJItemsConfig *config = [[WJItemsConfig alloc]init];
    config.itemWidth = screenWidth / 5;
    
    _itemControlView = [[WJItemsControlView alloc]initWithFrame:CGRectMake(0, 64, screenWidth, 45)];
    
    _itemControlView.backgroundColor = [UIColor whiteColor];
    
    _itemControlView.tapAnimation = NO;
    
    _itemControlView.config = config;
    
    _itemControlView.titleArray = self.typeArray;
    
    __weak typeof(self)weakSelf = self;
    
    [_itemControlView setTapItemWithIndex:^(NSInteger index,BOOL animation){
        
        weakSelf.index = index;
        
        [weakSelf.scrollView setContentOffset:CGPointMake(screenWidth * index, 0) animated:NO];
        
        NSString *type = [NSString stringWithFormat:@"%zd",index];
        
        [weakSelf.set enumerateObjectsUsingBlock:^(NSString  *obj, BOOL * _Nonnull stop) {
            
            weakSelf.isRefresh = [obj isEqualToString:type];
            
            *stop = weakSelf.isRefresh;
            
        }];
        
        [weakSelf.set addObject:type];
        
        if (!weakSelf.isRefresh) {
            
            [weakSelf loadData];
        }
        
    }];
    
    [self.view addSubview:_itemControlView];
    
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 109, screenWidth, screenHeiht - 109)];
    
    self.scrollView.delegate = self;
    
    self.scrollView.pagingEnabled = YES;
    
    self.scrollView.showsHorizontalScrollIndicator = NO;
    
    self.scrollView.contentSize = CGSizeMake(self.typeArray.count * screenWidth, 0);
    
    [self.view addSubview:self.scrollView];
    
    
    for (int i = 0; i < self.typeArray.count; i ++) {
        
        UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(i *screenWidth, 0, screenWidth, screenHeiht - 109) style:UITableViewStylePlain];
        
        tableView.delegate = self;
        
        tableView.dataSource = self;
        
        tableView.backgroundColor = [UIColor colorWithRed:236/255.0f green:237/255.0f blue:243/255.0f alpha:1.0];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [self.scrollView addSubview:tableView];
        
        [self.tableArray addObject:tableView];
        
        NSMutableArray *array = [NSMutableArray array];
        
        [self.dataArray addObject:array];
    }
}

#pragma mark - getter

- (NSMutableArray *)dataArray{

    if (!_dataArray) {
        
        _dataArray = [NSMutableArray array];
    }
    
    return _dataArray;
}

- (NSMutableArray *)tableArray{
    
    if (!_tableArray) {
        _tableArray = [NSMutableArray array];
    }
    return _tableArray;
}

- (NSMutableSet *)set{
    
    if (!_set) {
        
        _set = [NSMutableSet set];
        
        [_set addObject:@"0"];
    }
    return _set;
}

@end
