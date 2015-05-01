//
//  SeparatorLine.m
//  SharingPrototype
//
//  Created by Patrick Arthurs on 4/28/15.
//  Copyright (c) 2015 TrackVia. All rights reserved.
//

#import "SeparatorLine.h"

@implementation SeparatorLine

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void) viewWillAppear
{
    float psuedoPixel = 1.0/[UIScreen mainScreen].scale;
    UIView *topSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, psuedoPixel)];
    
    topSeparatorView.userInteractionEnabled = NO;
    [topSeparatorView setBackgroundColor:self.backgroundColor];
    [self addSubview:topSeparatorView];
    
    self.userInteractionEnabled = NO;
}

@end
