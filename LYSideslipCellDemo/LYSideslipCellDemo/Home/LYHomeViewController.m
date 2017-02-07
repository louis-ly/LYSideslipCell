//
//  ViewController.m
//  LYSideslipCellDemo
//
//  Created by Louis on 16/7/5.
//  Copyright © 2016年 Louis. All rights reserved.
//

#import "LYHomeViewController.h"
#import "LYSideslipCell.h"
#import "LYHomeCell.h"

#define kIcon @"kIcon"
#define kName @"kName"
#define kTime @"kTime"
#define kMessage @"kMessage"

@interface LYHomeViewController () <LYSideslipCellDelegate>
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation LYHomeViewController {
    UIImageView *_logoImageView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor colorWithRed:236/255.0 green:235/255.0 blue:243/255.0 alpha:1];
    self.tableView.rowHeight = 70;
    _dataArray = [LYHomeCellModel requestDataArray];
    
    _logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_logo"]];
    _logoImageView.contentMode = UIViewContentModeCenter;
    _logoImageView.alpha = 0.7;
    [self.tableView addSubview:_logoImageView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    _logoImageView.frame = CGRectMake(0, -100, self.tableView.frame.size.width, 100);
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LYHomeCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(LYSideslipCell.class)];
    if (!cell) {
        cell = [[LYHomeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass(LYSideslipCell.class)];
        cell.delegate = self;
    }
    cell.model = _dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.preservesSuperviewLayoutMargins = NO;
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 0)];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsMake(0, 10, 0, 0)];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - LYSideslipCellDelegate
- (NSArray<LYSideslipCellAction *> *)sideslipCell:(LYSideslipCell *)sideslipCell editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    LYHomeCellModel *model = _dataArray[indexPath.row];
    LYSideslipCellAction *action1 = [LYSideslipCellAction rowActionWithStyle:LYSideslipCellActionStyleNormal title:@"取消关注" handler:^(LYSideslipCellAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSLog(@"取消关注");
        [sideslipCell hideSideslip];
    }];
    LYSideslipCellAction *action2 = [LYSideslipCellAction rowActionWithStyle:LYSideslipCellActionStyleDestructive title:@"删除" handler:^(LYSideslipCellAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSLog(@"删除");
        [_dataArray removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }];
    LYSideslipCellAction *action3 = [LYSideslipCellAction rowActionWithStyle:LYSideslipCellActionStyleNormal title:@"置顶" handler:^(LYSideslipCellAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSLog(@"置顶");
        [sideslipCell hideSideslip];
    }];
    
    NSArray *array = @[];
    switch (model.messageType) {
        case LYHomeCellTypeMessage:
            array = @[action2];
            break;
        case LYHomeCellTypeSubscription:
            array = @[action1, action2];
            break;
        case LYHomeCellTypePubliction:
            array = @[action3, action2];
            break;
        default:
            break;
    }
    return array;
}

- (BOOL)sideslipCell:(LYSideslipCell *)sideslipCell canSideslipRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


@end
