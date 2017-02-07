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
@property (nonatomic, strong) NSArray *dataArray;
@end

@implementation LYHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = 70;
    _dataArray = [LYHomeCellModel requestDataArray];
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
        NSLog(@"点击了取消关注");
        [sideslipCell hideSideslip];
    }];
    LYSideslipCellAction *action2 = [LYSideslipCellAction rowActionWithStyle:LYSideslipCellActionStyleDestructive title:@"删除" handler:^(LYSideslipCellAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSLog(@"删除");
        [sideslipCell hideSideslip];
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
- (void)sideslipCell:(LYSideslipCell *)sideslipCell rowAtIndexPath:(NSIndexPath *)indexPath didSelectedAtIndex:(NSInteger)index {
    NSLog(@"选中了: %ld", index);
}

- (BOOL)sideslipCell:(LYSideslipCell *)sideslipCell canSideslipRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


@end
