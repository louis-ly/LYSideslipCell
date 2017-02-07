//
//  LYContactCell.m
//  LYSideslipCellDemo
//
//  Created by Louis on 16/7/7.
//  Copyright © 2016年 Louis. All rights reserved.
//

#import "LYContactCell.h"

@interface LYContactCell ()


@end
@implementation LYContactCell

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame = self.contentView.frame;
    frame.size.width = self.bounds.size.width;
    self.contentView.frame = frame;
}

@end
