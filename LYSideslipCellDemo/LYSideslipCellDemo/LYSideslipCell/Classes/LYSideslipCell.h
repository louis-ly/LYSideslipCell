//
//  LYSideslipCell.h
//  LYSideslipCellDemo
//
//  Created by Louis on 16/7/5.
//  Copyright © 2016年 Louis. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LYSideslipCell;
@protocol LYSideslipCellDelegate <NSObject>
@optional;
/**
 *  选中了侧滑按钮
 *
 *  @param sideslipCell 当前响应的cell
 *  @param indexPath    cell在tableView中的位置
 *  @param index        选中的是第几个action
 */
- (void)sideslipCell:(LYSideslipCell *)sideslipCell rowAtIndexPath:(NSIndexPath *)indexPath didSelectedAtIndex:(NSInteger)index;

/**
 *  告知当前位置的cell是否需要侧滑按钮
 *
 *  @param sideslipCell 当前响应的cell
 *  @param indexPath    cell在tableView中的位置
 *
 *  @return YES 表示当前cell可以侧滑, NO 不可以
 */
- (BOOL)sideslipCell:(LYSideslipCell *)sideslipCell canSideslipRowAtIndexPath:(NSIndexPath *)indexPath;
@end


typedef NS_ENUM(NSInteger, LYSideslipCellActionStyle) {
    LYSideslipCellActionStyleDefault = 0,
    LYSideslipCellActionStyleDestructive = LYSideslipCellActionStyleDefault, // 删除 红底
    LYSideslipCellActionStyleNormal // 正常 灰底
};

@interface LYSideslipCell : UITableViewCell

@property (nonatomic, strong) UIView *containView;

@property (nonatomic, weak) id<LYSideslipCellDelegate> delegate;
/**
 *  设置侧滑按钮
 *
 *  @param rightButtons 装侧滑按钮的数组. 按钮可以自己创建, 也可以用本类提供的方法 rowActionWithStyle:title 创建
 */
- (void)setRightButtons:(NSArray<UIButton*> *)rightButtons;

/**
 *  创建侧滑按钮(按钮实现可复用)
 *
 *  @param style 按钮风格
 *  @param title 按钮文字
 *
 *  @return 创建好的侧滑按钮
 */
- (UIButton *)rowActionWithStyle:(LYSideslipCellActionStyle)style title:(NSString *)title;

/**
 *  隐藏侧滑按钮
 */
- (void)hiddenSideslipButton;
@end
