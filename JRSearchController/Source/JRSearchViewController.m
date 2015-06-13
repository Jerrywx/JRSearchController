//
//  JRSearchViewController.m
//  JRSearchController
//
//  Created by Jerry on 15/6/13.
//  Copyright (c) 2015年 Jerry. All rights reserved.
//

#import "JRSearchViewController.h"
#import "JRSearchBar.h"


@interface JRSearchViewController () <UITableViewDataSource,UITableViewDelegate, UISearchBarDelegate>

// 模型数组
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSMutableArray *tmpItems;

// tableView
@property (nonatomic, strong) UITableView *tableView;
// searchBar
@property (nonatomic, strong) JRSearchBar *searchBar;
// searchBar 状态
@property (nonatomic, assign) NSInteger searchBarStatus;
// 定时器
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation JRSearchViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self loadtableView];
}

#pragma mark - 加载 view
// 界面设置
- (void)loadtableView {
	// 1. 获取屏幕尺寸
	CGFloat wScreen = [UIScreen mainScreen].bounds.size.width;
	CGFloat hScreen = [UIScreen mainScreen].bounds.size.height;
	
	// 2. 创建 tableView
	self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0, wScreen, hScreen) style:UITableViewStylePlain];
	[self.view addSubview:self.tableView];
	
	self.tableView.dataSource = self;
	self.tableView.delegate = self;
	
	// 创建 搜索框
	self.searchBar = [[JRSearchBar alloc]initWithFrame: CGRectMake(0, -44, wScreen, 44)];
	self.tableView.tableHeaderView.hidden = YES;
	[self.view addSubview:self.searchBar];
	
	self.searchBar.showsCancelButton = YES;
	self.searchBar.delegate = self;
}

#pragma mark - tableView 数据源方法
// 设置行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// 判断当前搜索状态
	if (!self.searchBar.text.length ) {
		
		return self.items.count;
		
	}else{
		
		return self.tmpItems.count;
	}
	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// 创建 cell
	static NSString *ID = @"cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
	}
	
	// 设置 cell
	if (!self.searchBar.text.length) {
		
		cell.detailTextLabel.text = self.items[indexPath.row];
		cell.textLabel.text = [NSString stringWithFormat:@"第%d名",indexPath.row + 1];
		
	}else{
		cell.detailTextLabel.text = self.tmpItems[indexPath.row];
		int index = [self.items indexOfObject:self.tmpItems[indexPath.row]];
		cell.textLabel.text = [NSString stringWithFormat:@"第%d名",index + 1];
	}
	
	// 返回 cell
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	
	return 0.1;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	
	if (self.searchBarStatus == 0) {
		if (scrollView.contentOffset.y <= -44) {
			self.searchBarStatus = 1;
			[UIView animateWithDuration:0.3 animations:^{
				
				self.searchBar.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
				self.tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
			}];
			
			NSTimer *timer = [NSTimer timerWithTimeInterval:2.0 target:self selector:@selector(closeSearch) userInfo:nil repeats:NO];
			self.timer = timer;
			NSRunLoop *loop = [NSRunLoop currentRunLoop];
			[loop addTimer:timer forMode:NSDefaultRunLoopMode];
		}
	} else {
		
		if (scrollView.contentOffset.y > -44) {
			
			if (self.timer != nil) {
				
				[self.timer invalidate];
				self.timer = nil;
			}
			[self closeSearch];
		}
	}
	
}

- (void)closeSearch {
	if (![self.searchBar isFirstResponder] && self.searchBar.text.length == 0) {
		
		[UIView animateWithDuration:0.3 animations:^{
			self.searchBar.frame = CGRectMake(0, -44, self.view.frame.size.width, 44);
			self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
		}];
	}
	 
	self.searchBarStatus = 0;
}

#pragma mark - 键盘退出
// 点击退出键盘
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// 退出键盘
	[self.view endEditing:YES];
	
	if (self.searchBar.text.length == 0 && self.searchBarStatus) {
		
		if (self.timer != nil) {
			
			[self.timer invalidate];
			self.timer = nil;
		}
		[self closeSearch];
	}
}
// 滑动键盘方法
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	[self.view endEditing:YES];
}

#pragma mark - UISearchBarDelegate
// searchBar 代理方法
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	
	self.tmpItems = [self.searchBar searchTest:(NSString *)searchText InArray:(NSArray *)self.items];
	
	[self.tableView reloadData];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	
	self.searchBar.text = @"";
	[self.tmpItems removeAllObjects];
	[self.tableView reloadData];
	[self.searchBar resignFirstResponder];
	
	if (self.timer != nil) {
		
		[self.timer invalidate];
		self.timer = nil;
	}
	[self closeSearch];
	
}

#pragma mark - 状态栏
// 是否隐藏状态栏
- (BOOL)prefersStatusBarHidden
{
	return YES;
}

#pragma mark - 懒加载
// 模型数组懒加载
- (NSArray *)items
{
	if (!_items) {
		
		// 获取数据源地址
		NSString *path = [[NSBundle mainBundle]pathForResource:@"itemList.plist" ofType:nil];
		_items = [NSArray arrayWithContentsOfFile:path];
	}
	return _items;
}

// 临时模型懒加载
- (NSMutableArray*)tmpItems
{
	if (!_tmpItems) {
		
		_tmpItems = [NSMutableArray array];
		
	}
	return _tmpItems;
}



@end
