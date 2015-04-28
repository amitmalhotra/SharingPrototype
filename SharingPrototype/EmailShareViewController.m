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
#import "EmailContactItem.h"


@interface EmailShareViewController () <THContactPickerDelegate>

@property (nonatomic, strong) NSArray *contacts;
@property (nonatomic, strong) NSMutableArray *privateSelectedContacts;
@property (nonatomic, strong) NSArray *filteredContacts;
@property (nonatomic) NSInteger selectedCount;
@property (nonatomic, assign) BOOL contactsAreDisplayed;

- (NSPredicate *)newFilteringPredicateWithText:(NSString *) text;
- (void) didChangeSelectedItems;
- (NSString *) titleForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@implementation EmailShareViewController

NSString *EmailShareViewCellReuseID = @"EmailShareViewCell";

#pragma mark - Public properties

- (NSArray *)filteredContacts {
    if (!_filteredContacts) {
        _filteredContacts = _contacts;
    }
    return _filteredContacts;
}

#pragma mark - Private properties

- (NSMutableArray *)privateSelectedContacts {
    if (!_privateSelectedContacts) {
        _privateSelectedContacts = [NSMutableArray array];
    }
    return _privateSelectedContacts;
}


#pragma mark - View Lifecycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.contactPickerView setPlaceholderLabelText:NSLocalizedString(@"type emails or pick contacts?",nil)];
    [self.contactPickerView setPromptLabelText:NSLocalizedString(@"To:", nil)];
    self.contactPickerView.delegate = self;
    
    self.subjectLabelView.text = NSLocalizedString(@"Subject:", nill);
    
    // Create and pre-initialize the table view
    CGRect tableFrame = CGRectMake(0, self.contactPickerView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.contactPickerView.frame.size.height);
    self.tableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.hidden = YES;
    [self.view insertSubview:self.tableView belowSubview:self.contactPickerView];
    self.contactsAreDisplayed = false;
    
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                      attribute:NSLayoutAttributeLeading
                                                                      relatedBy:0
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeLeft
                                                                     multiplier:1.0
                                                                       constant:0];
    [self.view addConstraint:leftConstraint];
    
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                       attribute:NSLayoutAttributeTrailing
                                                                       relatedBy:0
                                                                          toItem:self.view
                                                                       attribute:NSLayoutAttributeRight
                                                                      multiplier:1.0
                                                                        constant:0];
    [self.view addConstraint:rightConstraint];
    
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
             weakSelf.contacts = [weakSelf flattenEmailContacts:contacts];
             [weakSelf.tableView reloadData];
         }
         else
         {
             // show error
         }
     }];

    
}

- (NSArray *) flattenEmailContacts:(NSArray *) contacts
{
    NSMutableArray *flattenedContacts = [[NSMutableArray alloc] init];
    for (APContact *contact in contacts) {
        for (NSString *email in contact.emails)
        {
            NSString *firstName = [self nullProofString:contact.firstName];
            NSString *lastName = [self nullProofString:contact.lastName];
            EmailContactItem *contactItem = [[EmailContactItem alloc] initWithEmailAddress:email firstName:firstName lastName:lastName];
            [flattenedContacts addObject:contactItem];
        }
    }
    
    return flattenedContacts;
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

- (NSString *)titleForRowAtIndexPath:(NSIndexPath *)indexPath {
    EmailContactItem *contactItem = [self.filteredContacts objectAtIndex:indexPath.row];
    NSString* firstName = [self nullProofString:contactItem.firstName];
    NSString* lastName = [self nullProofString:contactItem.lastName];
    NSString* emailAddress = [self nullProofString:contactItem.emailAddress];
    
    return [NSString stringWithFormat:@"%@ %@ (%@)",firstName,lastName, emailAddress];
}

-(NSString*)nullProofString:(NSString*)string{
    return (string.length>0) ? string : @"";
}

- (void) didChangeSelectedItems {
    
}

- (NSPredicate *)newFilteringPredicateWithText:(NSString *) text {
    return [NSPredicate predicateWithFormat:@"self.firstName contains[cd] %@ || self.lastName contains[cd] %@ || self.emailAddress CONTAINS[c] %@", text, text, text];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.filteredContacts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:EmailShareViewCellReuseID];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:EmailShareViewCellReuseID];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    id contact = [self.filteredContacts objectAtIndex:indexPath.row];
    NSString *contactTitle = [self titleForRowAtIndexPath:indexPath];
    
    if ([self.privateSelectedContacts containsObject:contact]){ // contact is already selected so remove it from ContactPickerView
        self.contactPickerView.maxNumberOfLines = self.contactPickerView.maxNumberOfLines > 2 ? self.contactPickerView.maxNumberOfLines-- : 2;
        [self.privateSelectedContacts removeObject:contact];
        [self.contactPickerView removeContact:contact];
    } else {
        // Contact has not been selected, add it to THContactPickerView
        self.contactPickerView.maxNumberOfLines++;
        [self.privateSelectedContacts addObject:contact];
        [self.contactPickerView addContact:contact withName:contactTitle];
    }
    
    self.filteredContacts = self.contacts;
    
    self.contactsAreDisplayed = false;
//    [self.tableView removeFromSuperview];
    self.tableView.hidden = YES;
    
    [self didChangeSelectedItems];
    [self.tableView reloadData];
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.text = [self titleForRowAtIndexPath:indexPath];
}

#pragma mark - THContactPickerTextViewDelegate

- (void)contactPickerTextViewDidChange:(NSString *)textViewText {
    if ([textViewText isEqualToString:@""]){
        self.filteredContacts = self.contacts;
        self.contactsAreDisplayed = false;
        self.tableView.hidden = YES;
    } else {
        if (!self.contactsAreDisplayed) {
            CGRect tableFrame = CGRectMake(0, self.contactPickerView.frame.size.height + 5, self.view.frame.size.width, self.view.frame.size.height - self.contactPickerView.frame.size.height);
            self.tableView.frame = tableFrame;
            self.tableView.hidden = NO;
            self.contactsAreDisplayed = true;
        }
    }
    
    self.filteredContacts = [self getFilteredContacts:textViewText];
    
    if (self.filteredContacts.count == 0) {
        self.contactsAreDisplayed = false;
        [self.tableView removeFromSuperview];
    }
    
    [self.tableView reloadData];
}

- (NSArray *) getFilteredContacts:(NSString *)filterText {
    NSPredicate *predicate = [self newFilteringPredicateWithText:filterText];
    NSArray *candidateContents = [self.contacts filteredArrayUsingPredicate:predicate];
    NSMutableArray *resultContacts = [[NSMutableArray alloc] init];
    
    for (id contact in candidateContents) {
        if (![self.privateSelectedContacts containsObject:contact]) {
            [resultContacts addObject:contact];
        }
    }
    
    return resultContacts;
}

- (void)contactPickerDidResize:(THContactPickerView *)contactPickerView {
    CGRect frame = self.tableView.frame;
    CGRect scrollableContentContainerFrame = self.scrollableContentContainerView.frame;
    
    frame.origin.y = contactPickerView.frame.size.height + contactPickerView.frame.origin.y;
    scrollableContentContainerFrame.origin.y = frame.origin.y + 20;
    
    self.tableView.frame = frame;
    self.scrollableContentContainerView.frame = scrollableContentContainerFrame;
    
    
}

- (void)contactPickerDidRemoveContact:(id)contact {
    [self.privateSelectedContacts removeObject:contact];
    
    NSInteger index = [self.contacts indexOfObject:contact];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    [self didChangeSelectedItems];
}

- (BOOL)contactPickerTextFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length > 0){
        NSString *contact = [[NSString alloc] initWithString:textField.text];
        EmailContactItem *contactItem = [[EmailContactItem alloc] initWithEmailAddress:contact firstName:@"" lastName:@""];
        [self.privateSelectedContacts addObject:contactItem];
        [self.contactPickerView addContact:contact withName:textField.text];
    }
    return YES;
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
