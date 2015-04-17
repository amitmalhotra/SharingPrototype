//
//  ViewController.m
//  SharingPrototype
//
//  Created by Amit Malhotra on 4/16/15.
//  Copyright (c) 2015 TrackVia. All rights reserved.
//

#import "EmailShareViewController.h"
#import "APAddressBook.h"
#import "APContact.h"


@interface EmailShareViewController () <THContactPickerDelegate>

@property (nonatomic, strong) NSArray *contacts;
@property (nonatomic, strong) NSArray *contactEmails;

@property (nonatomic, readonly) NSArray *selectedContacts;
@property (nonatomic) NSInteger selectedCount;
@property (nonatomic, readonly) NSArray *filteredEmailContacts;

- (NSPredicate *)newFilteringPredicateWithText:(NSString *) text;
- (void) didChangeSelectedItems;
- (NSString *) titleForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@implementation EmailShareViewController


#pragma mark - View Lifecycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.contactPickerView setPlaceholderLabelText:NSLocalizedString(@"type emails or pick contacts?",nil)];
    [self.contactPickerView setPromptLabelText:NSLocalizedString(@"To:", nil)];
    
    CALayer *layer = [self.contactPickerView layer];
    [layer setShadowColor:[[UIColor colorWithRed:225.0/255.0 green:226.0/255.0 blue:228.0/255.0 alpha:1] CGColor]];
    [layer setShadowOffset:CGSizeMake(0, 2)];
    [layer setShadowOpacity:1];
    [layer setShadowRadius:1.0f];
    
    // Fill the rest of the view with the table view
    CGRect tableFrame = CGRectMake(0, self.contactPickerView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.contactPickerView.frame.size.height);
    self.tableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view insertSubview:self.tableView belowSubview:self.contactPickerView];
    
    [self populateContacts];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    /*Register for keyboard notifications*/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Helper Methods

-(void)populateContacts{
    
    APAddressBook *addressBook = [[APAddressBook alloc] init];
    addressBook.fieldsMask = APContactFieldFirstName | APContactFieldEmails | APContactFieldLastName;
    addressBook.filterBlock = ^BOOL(APContact *contact)
    {
        return contact.emails.count > 0;
    };
    
    addressBook.sortDescriptors = @[
                                    [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES],
                                    [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES]
                                    ];
    
    
    __weak typeof(self) weakSelf = self;
    
    // don't forget to show some activity
    [addressBook loadContacts:^(NSArray *contacts, NSError *error)
     {
         // hide activity
         if (!error)
         {
             
             switch([APAddressBook access])
             {
                 case APAddressBookAccessUnknown:
                     // Application didn't request address book access yet
                     break;
                     
                 case APAddressBookAccessGranted:
                     // Access granted
                     break;
                     
                 case APAddressBookAccessDenied:
                     // Access denied or restricted by privacy settings
                 {
                     NSString* title = NSLocalizedString(@"No access to your contact list", nil);
                     NSString* subtitle = NSLocalizedString(@"By providing access to your contacts, you can easily share with other. Please allow access by going into settings", nil);
                     
                     // We are going to use TSMessage pod to display the alert ...
                     
                     
                 }
                     break;
             }
             
             weakSelf.contacts = contacts;
             [weakSelf.tableView reloadData];
         }
         else
         {
             // show error
         }
     }];

    
    
    
}

- (void)adjustTableViewInsetTop:(CGFloat)topInset bottom:(CGFloat)bottomInset {
    self.tableView.contentInset = UIEdgeInsetsMake(topInset,
                                                   self.tableView.contentInset.left,
                                                   bottomInset,
                                                   self.tableView.contentInset.right);
    self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
}

- (void)adjustTableViewInsetTop:(CGFloat)topInset {
    [self adjustTableViewInsetTop:topInset bottom:self.tableView.contentInset.bottom];
}

- (void)adjustTableViewInsetBottom:(CGFloat)bottomInset {
    [self adjustTableViewInsetTop:self.tableView.contentInset.top bottom:bottomInset];
}

#pragma  mark - NSNotificationCenter

- (void)keyboardDidShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGRect kbRect = [self.view convertRect:[[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:self.view.window];
    [self adjustTableViewInsetBottom:self.tableView.frame.origin.y + self.tableView.frame.size.height - kbRect.origin.y];
}

- (void)keyboardDidHide:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGRect kbRect = [self.view convertRect:[[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:self.view.window];
    [self adjustTableViewInsetBottom:self.tableView.frame.origin.y + self.tableView.frame.size.height - kbRect.origin.y];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
