//
//  ViewController.h
//  SharingPrototype
//
//  Created by Amit Malhotra on 4/16/15.
//  Copyright (c) 2015 TrackVia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THContactPickerView.h"
#import "HPGrowingTextView.h"

@interface EmailShareViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView* scrollView;
@property (nonatomic, strong) IBOutlet UIView* contentView;
@property (strong, nonatomic) IBOutlet UIView* scrollableContentContainerView;
@property (strong, nonatomic) IBOutlet UILabel* subjectLabelView;
@property (nonatomic, strong) IBOutlet THContactPickerView *contactPickerView;
@property (nonatomic, strong) UITableView *tableView;
@property (strong, nonatomic) IBOutlet HPGrowingTextView *commentsTextView;
@property (strong, nonatomic) IBOutlet UIView *previewContentView;
@property (strong, nonatomic) IBOutlet UIWebView *previewWebView;
@property (strong, nonatomic) IBOutlet UILabel *characterCountLabelView;



@end

