//
//  LYSideslipCell.h
//  LYSideslipCellDemo
//
//  Created by Louis on 16/7/5.
//  Copyright © 2016年 Louis. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, LYSideslipCellActionStyle) {
    LYSideslipCellActionStyleDefault = 0,
    LYSideslipCellActionStyleDestructive = LYSideslipCellActionStyleDefault, // 删除 红底
    LYSideslipCellActionStyleNormal // 正常 灰底
};

@interface LYSideslipCellAction : NSObject

+ (instancetype)rowActionWithStyle:(LYSideslipCellActionStyle)style title:(nullable NSString *)title handler:(void (^)(LYSideslipCellAction *action, NSIndexPath *indexPath))handler;

@property (nonatomic, readonly) LYSideslipCellActionStyle style;
@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, strong, nullable) UIImage *image;
@property (nonatomic, copy, nullable) UIColor *backgroundColor; // default background color is dependent on style

@end

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

- (nullable NSArray<LYSideslipCellAction *> *)sideslipCell:(LYSideslipCell *)sideslipCell editActionsForRowAtIndexPath:(NSIndexPath *)indexPath;
@end




@interface LYSideslipCell : UITableViewCell

@property (nonatomic, weak) id<LYSideslipCellDelegate> delegate;

/**
 *  隐藏侧滑按钮
 */
- (void)hiddenSideslipButton;

- (void)hideSideslip;
@end

NS_ASSUME_NONNULL_END
