//
//  FilterCell.m
//  SplitScreenFilter
//
//  Created by Misaka on 2020/7/2.
//  Copyright © 2020 Misaka. All rights reserved.
//

#import "FilterCell.h"

@interface FilterCell ()

@property (nonatomic, strong) UILabel *titleLab;

@end

@implementation FilterCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.titleLab];
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLab.text = title;
}

- (void)setSelected:(BOOL)selected {
    if (selected) {
        self.titleLab.backgroundColor = [UIColor greenColor];
    }else {
        self.titleLab.backgroundColor = [UIColor grayColor];
    }
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] initWithFrame:self.bounds];
        _titleLab.font = [UIFont boldSystemFontOfSize:18];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.textColor = UIColor.blackColor;
        _titleLab.backgroundColor = [UIColor grayColor];
        _titleLab.layer.cornerRadius = 6;
        _titleLab.clipsToBounds = YES;
        _titleLab.numberOfLines = 0;
    }
    return _titleLab;
}

@end
