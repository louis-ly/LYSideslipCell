//
//  LYSideslipCell.m
//  LYSideslipCellDemo
//
//  Created by Louis on 16/7/5.
//  Copyright © 2016年 Louis. All rights reserved.
//

#import "LYSideslipCell.h"

@interface LYSideslipCellAction ()
@property (nonatomic, copy) void (^handler)(LYSideslipCellAction *action, NSIndexPath *indexPath);
@property (nonatomic, assign) LYSideslipCellActionStyle style;
@end
@implementation LYSideslipCellAction
+ (instancetype)rowActionWithStyle:(LYSideslipCellActionStyle)style title:(NSString *)title handler:(void (^)(LYSideslipCellAction *action, NSIndexPath *indexPath))handler {
    LYSideslipCellAction *action = [LYSideslipCellAction new];
    action.title = title;
    action.handler = handler;
    action.style = style;
    return action;
}

- (CGFloat)margin {
    return _margin == 0 ? 15 : _margin;
}
@end

typedef NS_ENUM(NSInteger, LYSideslipCellState) {
    LYSideslipCellStateNormal,
    LYSideslipCellStateAnimating,
    LYSideslipCellStateOpen
};

@interface LYSideslipCell () <UIGestureRecognizerDelegate>
@property (nonatomic, assign) BOOL sideslip;
@property (nonatomic, assign) LYSideslipCellState state;
@end

@implementation LYSideslipCell {
    UITableView *_tableView;
    NSIndexPath *_indexPath;
    NSArray <LYSideslipCellAction *>* _actions;
    UIPanGestureRecognizer *_panGesture;
    UIPanGestureRecognizer *_tableViewPan;
}

#pragma mark - Life Cycle
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupSideslipCell];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setupSideslipCell];
    }
    return self;
}

- (void)setupSideslipCell {
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(contentViewPan:)];
    _panGesture.delegate = self;
    [self.contentView addGestureRecognizer:_panGesture];
    self.contentView.backgroundColor = [UIColor whiteColor];
}

- (void)layoutSubviews {
    CGFloat x = 0;
    if (_sideslip) x = self.contentView.frame.origin.x;
    
    [super layoutSubviews];
    CGFloat totalWidth = 0;
    for (UIButton *btn in _btnContainView.subviews) {
        btn.frame = CGRectMake(totalWidth, 0, btn.frame.size.width, self.frame.size.height);
        totalWidth += btn.frame.size.width;
    }
    _btnContainView.frame = CGRectMake(self.frame.size.width - totalWidth, 0, totalWidth, self.frame.size.height);
    
    // 侧滑状态旋转屏幕时, 保持侧滑
    if (_sideslip) [self setContentViewX:x];
    
    CGRect frame = self.contentView.frame;
    frame.size.width = self.bounds.size.width;
    self.contentView.frame = frame;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == _panGesture) {
        // 若 tableView 不能滚动时, 还触发手势, 则隐藏侧滑
        if (!self.tableView.scrollEnabled) {
            [self hiddenAllSideslip];
            return NO;
        }
        UIPanGestureRecognizer *gesture = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint translation = [gesture translationInView:gesture.view];
        
        // 如果手势相对于水平方向的角度大于45°, 则不触发侧滑
        BOOL shouldBegin = fabs(translation.y) <= fabs(translation.x);
        if (!shouldBegin) return NO;
        
        // 询问代理是否需要侧滑
        if ([_delegate respondsToSelector:@selector(sideslipCell:canSideslipRowAtIndexPath:)]) {
            shouldBegin = [_delegate sideslipCell:self canSideslipRowAtIndexPath:[self.tableView indexPathForCell:self]] || _sideslip;
        }
        
        if (shouldBegin) {
            // 向代理获取侧滑展示内容数组
            if ([_delegate respondsToSelector:@selector(sideslipCell:editActionsForRowAtIndexPath:)]) {
                NSArray <LYSideslipCellAction*> *actions = [_delegate sideslipCell:self editActionsForRowAtIndexPath:self.indexPath];
                if (!actions || actions.count == 0) return NO;
                [self setActions:actions];
            } else {
                return NO;
            }
        }
        return shouldBegin;
    } else if (gestureRecognizer == _tableViewPan) {
        if (self.tableView.scrollEnabled) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - Response Events
- (void)tableViewPan:(UIPanGestureRecognizer *)pan {
    if (!self.tableView.scrollEnabled && pan.state == UIGestureRecognizerStateBegan) {
        [self hiddenAllSideslip];
    }
}

- (void)contentViewPan:(UIPanGestureRecognizer *)pan {
    CGPoint point = [pan translationInView:pan.view];
    UIGestureRecognizerState state = pan.state;
    [pan setTranslation:CGPointZero inView:pan.view];
    
    if (state == UIGestureRecognizerStateChanged) {
        CGRect frame = self.contentView.frame;
        frame.origin.x += point.x;
        if (frame.origin.x > 15) {
            frame.origin.x = 15;
        } else if (frame.origin.x < -30 - _btnContainView.frame.size.width) {
            frame.origin.x = -30 - _btnContainView.frame.size.width;
        }
        self.contentView.frame = frame;
        
    } else if (state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [pan velocityInView:pan.view];
        if (self.contentView.frame.origin.x == 0) {
            return;
        } else if (self.contentView.frame.origin.x > 5) {
            [self hiddenWithBounceAnimation];
        } else if (fabs(self.contentView.frame.origin.x) >= 40 && velocity.x <= 0) {
            [self showSideslip];
        } else {
            [self hiddenSideslip];
        }
        
    } else if (state == UIGestureRecognizerStateCancelled) {
        [self hiddenAllSideslip];
    }
}

- (void)actionBtnDidClicked:(UIButton *)btn {
    if ([self.delegate respondsToSelector:@selector(sideslipCell:rowAtIndexPath:didSelectedAtIndex:)]) {
        [self.delegate sideslipCell:self rowAtIndexPath:self.indexPath didSelectedAtIndex:btn.tag];
    }
    if (btn.tag < _actions.count) {
        LYSideslipCellAction *action = _actions[btn.tag];
        if (action.handler) action.handler(action, self.indexPath);
    }
    self.state = LYSideslipCellStateNormal;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if (_sideslip) [self hiddenAllSideslip];
}

#pragma mark - Methods
- (void)hiddenWithBounceAnimation {
    self.state = LYSideslipCellStateAnimating;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self setContentViewX:-10];
    } completion:^(BOOL finished) {
        [self hiddenSideslip];
    }];
}

- (void)hiddenAllSideslip {
    [self.tableView hiddenAllSideslip];
}

- (void)hiddenSideslip {
    if (self.contentView.frame.origin.x == 0) return;
    
    self.state = LYSideslipCellStateAnimating;
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self setContentViewX:0];
    } completion:^(BOOL finished) {
        self.state = LYSideslipCellStateNormal;
    }];
}

- (void)showSideslip {
    self.state = LYSideslipCellStateAnimating;
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self setContentViewX:-_btnContainView.frame.size.width];
    } completion:^(BOOL finished) {
        self.state = LYSideslipCellStateOpen;
    }];
}

#pragma mark - Setter
- (void)setContentViewX:(CGFloat)x {
    CGRect frame = self.contentView.frame;
    frame.origin.x = x;
    self.contentView.frame = frame;
}

- (void)setActions:(NSArray <LYSideslipCellAction *>*)actions {
    _actions = actions;

    if (_btnContainView) {
        [_btnContainView removeFromSuperview];
        _btnContainView = nil;
    }
    _btnContainView = [UIView new];
    [self insertSubview:_btnContainView belowSubview:self.contentView];
    
    for (int i = 0; i < actions.count; i++) {
        LYSideslipCellAction *action = actions[i];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.adjustsImageWhenHighlighted = NO;
        
        [btn setTitle:action.title forState:UIControlStateNormal];
    
        if (action.backgroundColor) {
            btn.backgroundColor = action.backgroundColor;
        } else {
            btn.backgroundColor = action.style == LYSideslipCellActionStyleNormal? [UIColor colorWithRed:200/255.0 green:199/255.0 blue:205/255.0 alpha:1] : [UIColor redColor];
        }
        
        if (action.image) {
            [btn setImage:action.image forState:UIControlStateNormal];
        }
        
        if (action.fontSize != 0) {
            btn.titleLabel.font = [UIFont systemFontOfSize:action.fontSize];
        }
        
        if (action.titleColor) {
            [btn setTitleColor:action.titleColor forState:UIControlStateNormal];
        }
        
        CGFloat width = [action.title boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : btn.titleLabel.font} context:nil].size.width;
        width += (action.image ? action.image.size.width : 0);
        btn.frame = CGRectMake(0, 0, width + action.margin*2, self.frame.size.height);
        
        btn.tag = i;
        [btn addTarget:self action:@selector(actionBtnDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_btnContainView addSubview:btn];
    }
}

- (void)setState:(LYSideslipCellState)state {
    _state = state;
    
    if (state == LYSideslipCellStateNormal) {
        self.tableView.scrollEnabled = YES;
        self.tableView.allowsSelection = YES;
        for (LYSideslipCell *cell in self.tableView.visibleCells) {
            if ([cell isKindOfClass:LYSideslipCell.class]) {
                cell.sideslip = NO;
            }
        }
        
    } else if (state == LYSideslipCellStateAnimating) {

    } else if (state == LYSideslipCellStateOpen) {
        self.tableView.scrollEnabled = NO;
        self.tableView.allowsSelection = NO;
        for (LYSideslipCell *cell in self.tableView.visibleCells) {
            if ([cell isKindOfClass:LYSideslipCell.class]) {
                cell.sideslip = YES;
            }
        }
    }
}

#pragma mark - Getter
- (UITableView *)tableView {
    if (!_tableView) {
        id view = self.superview;
        while (view && [view isKindOfClass:[UITableView class]] == NO) {
            view = [view superview];
        }
        _tableView = (UITableView *)view;
        _tableViewPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(tableViewPan:)];
        _tableViewPan.delegate = self;
        [_tableView addGestureRecognizer:_tableViewPan];
    }
    return _tableView;
}

- (NSIndexPath *)indexPath {
    if (!_indexPath) _indexPath = [self.tableView indexPathForCell:self];
    return _indexPath;
}
@end


@implementation UITableView (LYSideslipCell)
- (void)hiddenAllSideslip {
    for (LYSideslipCell *cell in self.visibleCells) {
        if ([cell isKindOfClass:LYSideslipCell.class]) {
            [cell hiddenSideslip];
        }
    }
}
@end
