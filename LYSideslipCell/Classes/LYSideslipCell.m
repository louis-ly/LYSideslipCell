//
//  LYSideslipCell.m
//  LYSideslipCellDemo
//
//  Created by Louis on 16/7/5.
//  Copyright © 2016年 Louis. All rights reserved.
//

#import "LYSideslipCell.h"
#import <objc/runtime.h>

#define LYSideslipCellButtonMargin 15
#define LYSideslipCellLeftLimitScrollMargin 15
#define LYSideslipCellRightLimitScrollMargin 30

static NSUInteger kLyTop = 1;
static NSUInteger kLyBottom = 2;
static NSUInteger kLyLeft = 3;
static NSUInteger kLyRight = 4;
static NSUInteger kLyWidth = 5;
static NSUInteger kLyHeight = 6;

@interface LYSideslipView : UIView
@end
@implementation LYSideslipView
@end

@interface LYSideslipCell () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *sideslipContainView;
@property (nonatomic, strong) UIView *sideslipView;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) NSLayoutConstraint *containLeftConstraint;
@property (nonatomic, strong) NSLayoutConstraint *sideslipLeftConstraint;
@property (nonatomic, assign) BOOL sideslip;
@property (nonatomic, assign) BOOL discardTouchDown;

@property (nonatomic, strong) NSMutableArray *actionBtns;
@end

@implementation LYSideslipCell
#pragma mark - NSLayoutConstraint Extension
- (NSLayoutConstraint *)item:(UIView *)view1 attr:(NSUInteger)attr1 toItem:(UIView *)view2 attr:(NSUInteger)attr2 cons:(CGFloat)constant {
    return [NSLayoutConstraint constraintWithItem:view1 attribute:[self transformFromLyAttr:attr1] relatedBy:NSLayoutRelationEqual toItem:view2 attribute:[self transformFromLyAttr:attr2] multiplier:1 constant:constant];
}
- (NSLayoutAttribute)transformFromLyAttr:(NSUInteger)attr {
    if (!attr || attr == 0) return NSLayoutAttributeNotAnAttribute;
    if (attr == kLyTop) return NSLayoutAttributeTop;
    if (attr == kLyBottom) return NSLayoutAttributeBottom;
    if (attr == kLyLeft) return NSLayoutAttributeLeft;
    if (attr == kLyRight) return NSLayoutAttributeRight;
    if (attr == kLyWidth) return NSLayoutAttributeWidth;
    if (attr == kLyHeight) return NSLayoutAttributeHeight; return NSLayoutAttributeNotAnAttribute;
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
    _containView = [UIView new];
    _containView.backgroundColor = [UIColor whiteColor];
    _containView.translatesAutoresizingMaskIntoConstraints = NO;
    NSArray *cellSubViews = self.subviews;
    [self insertSubview:_containView atIndex:0];
    for (UIView *subView in cellSubViews) {
        [_containView addSubview:subView];
    }
    
    _containLeftConstraint = [self item:_containView attr:kLyLeft toItem:self attr:kLyLeft cons:0];
    [self addConstraints:@[[self item:_containView attr:kLyTop toItem:self attr:kLyTop cons:0],
                           [self item:_containView attr:kLyBottom toItem:self attr:kLyBottom cons:0],
                           [self item:_containView attr:kLyWidth toItem:self attr:kLyWidth cons:0],
                           _containLeftConstraint]];

    _sideslipContainView = [LYSideslipView new];
    _sideslipContainView.clipsToBounds = YES;
    _sideslipContainView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_sideslipContainView];
    
    _sideslipLeftConstraint = [self item:_sideslipContainView attr:kLyLeft toItem:self attr:kLyRight cons:0];
    [self addConstraints:@[[self item:_sideslipContainView attr:kLyTop toItem:self attr:kLyTop cons:0],
                           [self item:_sideslipContainView attr:kLyBottom toItem:self attr:kLyBottom cons:0],
                           [self item:_sideslipContainView attr:kLyRight toItem:self attr:kLyRight cons:0],
                           _sideslipLeftConstraint]];
    _sideslipView = [UIView new];
    _sideslipView.translatesAutoresizingMaskIntoConstraints = NO;
    [_sideslipContainView addSubview:_sideslipView];
    [_sideslipContainView addConstraints:@[[self item:_sideslipView attr:kLyTop toItem:_sideslipContainView attr:kLyTop cons:0],
                                           [self item:_sideslipView attr:kLyBottom toItem:_sideslipContainView attr:kLyBottom cons:0],
                                           [self item:_sideslipView attr:kLyRight toItem:_sideslipContainView attr:kLyRight cons:0]]];
    
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTapped:)];
    _tapGesture.delegate = self;
    _tapGesture.cancelsTouchesInView = NO;
    _tapGesture.enabled = NO;
    [_containView addGestureRecognizer:_tapGesture];
    
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(containViewPan:)];
    _panGesture.delegate = self;
    [_containView addGestureRecognizer:_panGesture];
}


#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == _panGesture) {
        if (!self.tableView.scrollEnabled) return YES;
        UIPanGestureRecognizer *gesture = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint translation = [gesture translationInView:gesture.view];
        BOOL shouldBegin = fabs(translation.y) <= fabs(translation.x);
        if (!shouldBegin) return NO;
        if ([_delegate respondsToSelector:@selector(sideslipCell:canSideslipRowAtIndexPath:)])
            shouldBegin = [_delegate sideslipCell:self canSideslipRowAtIndexPath:[self.tableView indexPathForCell:self]] || _sideslip;
        return shouldBegin;
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return ![touch.view isKindOfClass:UIControl.class];
}

#pragma mark - Response Events
- (void)scrollViewTapped:(UITapGestureRecognizer *)tap {
    if (_sideslip) [self hiddenAllSideslipButton];
}


- (void)containViewPan:(UIPanGestureRecognizer *)pan {
    CGPoint point = [pan translationInView:pan.view];
    UIGestureRecognizerState state = pan.state;
    [pan setTranslation:CGPointZero inView:pan.view];
    
    if (state == UIGestureRecognizerStateBegan) {
        if (_sideslip) {
            _discardTouchDown = YES;
            self.userInteractionEnabled = NO;
            [self hiddenAllSideslipButton];
        }
    } else if (state == UIGestureRecognizerStateChanged) {
        
        if (_discardTouchDown) return;
        if (CGRectGetWidth(_sideslipView.frame) == 0) return;

        CGRect frame = _containView.frame;
        frame.origin.x += point.x;
        if (frame.origin.x > LYSideslipCellLeftLimitScrollMargin) {
            frame.origin.x = LYSideslipCellLeftLimitScrollMargin;
        } else if (frame.origin.x < -LYSideslipCellRightLimitScrollMargin - CGRectGetWidth(_sideslipView.frame)) {
            frame.origin.x = -LYSideslipCellRightLimitScrollMargin - CGRectGetWidth(_sideslipView.frame);
        }
        
        _containLeftConstraint.constant = frame.origin.x;
        _sideslipLeftConstraint.constant = MIN(0, frame.origin.x);
        
    } else if (state == UIGestureRecognizerStateEnded) {
        
        if (_discardTouchDown) {
            _discardTouchDown = NO;
            self.userInteractionEnabled = YES;
            return;
        }
        
        if (_containLeftConstraint.constant == 0) return;
        
        if (_containLeftConstraint.constant > 5) {
            [self hiddenWithBounceAnimation];
        } else {
            if (fabs(_containLeftConstraint.constant) >= 30) {
                [self showSideslipButton];
            } else {
                [self hiddenSideslipButton];
            }
        }
    } else {
        _discardTouchDown = NO;
        self.userInteractionEnabled = YES;
        [self hiddenAllSideslipButton];
    }
}

- (void)actionBtnDidClicked:(UIButton *)btn {
    if ([self.delegate respondsToSelector:@selector(sideslipCell:rowAtIndexPath:didSelectedAtIndex:)]) {
        [self.delegate sideslipCell:self rowAtIndexPath:[self.tableView indexPathForCell:self] didSelectedAtIndex:btn.tag];
    }
    [self hiddenSideslipButton];
}

#pragma mark - Private Methods
- (void)closeAllOperation {
    self.tableView.scrollEnabled = NO;
    self.tableView.allowsSelection = NO;
    for (LYSideslipCell *cell in self.tableView.visibleCells)
        if ([cell isKindOfClass:LYSideslipCell.class]) {
            cell.sideslip = YES;
            cell.tapGesture.enabled = YES;
            cell.userInteractionEnabled = NO;
        }
}

- (void)openAllOperation {
    self.tableView.scrollEnabled = YES;
    self.tableView.allowsSelection = YES;
    for (LYSideslipCell *cell in self.tableView.visibleCells)
        if ([cell isKindOfClass:LYSideslipCell.class]) {
            cell.sideslip = NO;
            cell.tapGesture.enabled = NO;
            cell.userInteractionEnabled = YES;
        }
}

- (void)hiddenWithBounceAnimation {
    if (_containLeftConstraint.constant == 0) return;
    
    [self closeAllOperation];
    _containLeftConstraint.constant = _sideslipLeftConstraint.constant = -10;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self hiddenSideslipButton];
    }];
}

- (void)hiddenAllSideslipButton {
    if (_containLeftConstraint.constant == 0) {
        for (LYSideslipCell *cell in self.tableView.visibleCells)
            if ([cell isKindOfClass:LYSideslipCell.class])
                [cell hiddenSideslipButton];
    } else {
        [self hiddenSideslipButton];
    }
}

- (void)hiddenSideslipButton {
    if (_containLeftConstraint.constant == 0) return;
    
    [self closeAllOperation];
    _containLeftConstraint.constant = _sideslipLeftConstraint.constant = 0;
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self openAllOperation];
    }];
}

- (void)showSideslipButton {
    [self closeAllOperation];
    _containLeftConstraint.constant = _sideslipLeftConstraint.constant = -CGRectGetWidth(_sideslipView.frame);
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        for (LYSideslipCell *cell in self.tableView.visibleCells)
            if ([cell isKindOfClass:LYSideslipCell.class]) {
                cell.userInteractionEnabled = YES;
            }
    }];
}


#pragma mark - Public Methods
- (void)setRightButtons:(NSArray <UIButton *>*)rightButtons {
    if (!rightButtons || rightButtons.count == 0) return;
    UIView *lastView = _sideslipView;
    
    for (UIButton *actionBtn in _sideslipView.subviews) {
        [self.actionBtns addObject:actionBtn];
        [actionBtn removeFromSuperview];
    }
    for (int i = 0; i < rightButtons.count; i++) {
        UIButton *btn = rightButtons[i];
        btn.tag = i;
        [btn removeTarget:self action:@selector(actionBtnDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        [btn addTarget:self action:@selector(actionBtnDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        btn.translatesAutoresizingMaskIntoConstraints = NO;
        [_sideslipView addSubview:btn];
        [_sideslipView addConstraints:@[[self item:btn attr:kLyLeft toItem:lastView attr:i == 0 ? kLyLeft : kLyRight cons:0],
                                        [self item:btn attr:kLyTop toItem:_sideslipView attr:kLyTop cons:0],
                                        [self item:btn attr:kLyBottom toItem:_sideslipView attr:kLyBottom cons:0]]];
        
        lastView = btn;
        if (i == rightButtons.count - 1) {
            [_sideslipView addConstraint:[self item:btn attr:kLyRight toItem:_sideslipView attr:kLyRight cons:0]];
        }
    }
    [_sideslipView layoutIfNeeded];
}

- (UIButton *)rowActionWithStyle:(LYSideslipCellActionStyle)style title:(NSString *)title {
    UIButton *actionBtn = [self dequeueReusableActionBtn];
    actionBtn.backgroundColor = style == LYSideslipCellActionStyleNormal? [UIColor lightGrayColor] : [UIColor redColor];
    [actionBtn setTitle:title forState:UIControlStateNormal];
    return actionBtn;
}

- (UIButton *)dequeueReusableActionBtn {
    UIButton *actionBtn = nil;
    if (self.actionBtns.count > 0) {
        actionBtn = [self.actionBtns firstObject];
        [self.actionBtns removeObjectAtIndex:0];
    } else {
        actionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        actionBtn.contentEdgeInsets = UIEdgeInsetsMake(0, LYSideslipCellButtonMargin, 0, LYSideslipCellButtonMargin);
    }
    return actionBtn;
}

#pragma mark - Getter/Setter
- (UITableView *)tableView {
    if (!_tableView) {
        id view = self.superview;
        while (view && [view isKindOfClass:[UITableView class]] == NO) {
            view = [view superview];
        }
        _tableView = (UITableView *)view;
    }
    return _tableView;
}

- (NSMutableArray *)actionBtns {
    if (!_actionBtns) {
        _actionBtns = [NSMutableArray arrayWithCapacity:0];
    }
    return _actionBtns;
}


- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (_sideslip) return;
    [super setHighlighted:highlighted animated:animated];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    if (_sideslip) return;
    [super setSelected:selected animated:animated];
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(addSubview:);
        SEL swizzledSelector = @selector(ly_addSubview:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (void)ly_addSubview:(UIView *)view {
    if ([view isKindOfClass:NSClassFromString(@"UITableViewCellContentView")] || [view isKindOfClass:NSClassFromString(@"_UITableViewCellSeparatorView")] || [view isKindOfClass:LYSideslipView.class]) {
        [self ly_addSubview:view];
    } else {
        [self.contentView addSubview:view];
    }
}

@end
