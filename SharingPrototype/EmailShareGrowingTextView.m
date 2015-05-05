//
//  EmailShareGrowingTextView.m
//  
//
//  Created by Patrick Arthurs on 5/5/15.
//
//

#import "EmailShareGrowingTextView.h"

@implementation EmailShareGrowingTextView

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    [self refreshHeight];
}

@end
