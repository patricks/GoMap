//
//  POIDetailsViewController.m
//  OSMiOS
//
//  Created by Bryce on 12/10/12.
//  Copyright (c) 2012 Bryce. All rights reserved.
//

#import "POICommonTagsViewController.h"
#import "POITabBarController.h"
#import "OsmObjects.h"
#import "POITabBarController.h"
#import "UITableViewCell+FixConstraints.h"

@implementation POICommonTagsViewController



- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	_tagMap = @[
		@[ _nameTextField,				@"name" ],
		@[ _altNameTextField,			@"alt_name" ],
		@[ _cuisineTextField,			@"cuisine" ],
		@[ _wifiTextField,				@"wifi" ],
		@[ _operatorTextField,			@"operator" ],
		@[ _refTextField,				@"ref" ],
		@[ _buildingTextField,			@"addr:housename" ],
		@[ _houseNumberTextField,		@"addr:housenumber" ],
		@[ _unitTextField,				@"addr:unit" ],
		@[ _streetTextField,			@"addr:street" ],
		@[ _cityTextField,				@"addr:city" ],
		@[ _postalCodeTextField,		@"addr:postcode" ],
		@[ _phoneTextField,				@"phone" ],
		@[ _websiteTextField,			@"website" ],
		@[ _designationTextField,		@"designation" ],
		@[ _sourceTextField,			@"source" ],
		@[ _fixmeTextField,				@"fixme" ],
		@[ _noteTextField,				@"note" ],
	];

	UIColor * textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1.0];
	for ( NSArray * a in _tagMap ) {
		UITextField * textField = a[0];
		textField.textColor = textColor;
	}
	_typeTextField.textColor = textColor;
}

- (void)loadState
{
	// copy values out of tab bar controller
	POITabBarController	* tabController = (id)self.tabBarController;
	for ( NSArray * a in _tagMap ) {
		NSString * tag = a[1];
		NSString * value = [tabController.keyValueDict valueForKey:tag];
		UITextField * field = a[0];
		field.text = value;
	}

	for ( NSString * tag in tabController.typeList ) {
		NSString * value = [tabController.keyValueDict valueForKey:tag];
		if ( value.length ) {
			NSString * text = [NSString stringWithFormat:@"%@ (%@)", value, tag];
			text = [text stringByReplacingOccurrencesOfString:@"_" withString:@" "];
			text = text.capitalizedString;
			_typeTextField.text = text;
			break;
		}
	}

	_saveButton.enabled = [tabController isTagDictChanged];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self loadState];
	[self resignAll];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	[cell fixConstraints];
}

- (void)resignAll
{
	for ( NSArray * a in _tagMap ) {
		UITextField * field = a[0];
		[field resignFirstResponder];
	}
}


- (IBAction)textFieldReturn:(id)sender
{
#if 1
	[sender resignFirstResponder];
#else
	UITextField * textField = sender;
	NSInteger nextTag = textField.tag + 1;
	// Try to find next responder
	UIView * tableView = [[[textField superview] superview] superview];
	UIView * nextResponder = [tableView viewWithTag:nextTag];
	if ( nextResponder ) {
		// Found next responder, so set it.
		[nextResponder becomeFirstResponder];
		_firstResponder = nextResponder;
		id cell = [[nextResponder superview] superview];
		NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
		[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
	} else {
		// Not found, so remove keyboard.
		[textField resignFirstResponder];
		_firstResponder = nil;
	}
#endif
}


- (IBAction)textFieldChanged:(UITextField *)textField
{
	_saveButton.enabled = YES;
}

- (IBAction)textFieldDidEndEditing:(UITextField *)textField
{
	NSString * tag = nil;
	for ( NSArray * a in _tagMap ) {
		if ( a[0] == textField ) {
			tag = a[1];
			break;
		}
	}
	assert(tag);
	NSString * value = textField.text;
	value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	textField.text = value;

	POITabBarController * tabController = (id)self.tabBarController;

	if ( value.length ) {
		[tabController.keyValueDict setObject:value forKey:tag];
	} else {
		[tabController.keyValueDict removeObjectForKey:tag];
	}

	_saveButton.enabled = [tabController isTagDictChanged];
}


-(IBAction)cancel:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)done:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];

	POITabBarController * tabController = (id)self.tabBarController;
	[tabController commitChanges];
}



#pragma mark - Table view data source


#pragma mark - Table view delegate


@end
