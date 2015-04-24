//
//  ViewController.h
//  SharingPrototype
//
//  Created by Amit Malhotra on 4/16/15.
//  Copyright (c) 2015 TrackVia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THContactPickerView.h"

@interface EmailShareViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView* scrollView;
@property (nonatomic, strong) IBOutlet UIView* contentView;
@property (nonatomic, strong) IBOutlet THContactPickerView* contactPickerView;
@property (nonatomic, strong) UITableView *tableView;



@end

