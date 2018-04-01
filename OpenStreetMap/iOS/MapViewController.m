//
//  FirstViewController.m
//  OSMiOS
//
//  Created by Bryce Cogswell on 12/6/12.
//  Copyright (c) 2012 Bryce Cogswell. All rights reserved.
//

#import "AppDelegate.h"
#import "DLog.h"
#import "EditorMapLayer.h"
#import "MapViewController.h"
#import "MapView.h"
#import "OsmNotesDatabase.h"
#import "NotesTableViewController.h"
#import "OsmMapData.h"
#import "PushPinView.h"


@interface MapViewController ()
@end

@implementation MapViewController


- (void)updateDeleteButtonState
{
	_trashcanButton.enabled = self.mapView.editorLayer.selectedPrimary && !self.mapView.editorLayer.hidden;
}

- (void)updateUndoRedoButtonState
{
	_undoButton.enabled = self.mapView.editorLayer.mapData.canUndo && !self.mapView.editorLayer.hidden;
	_redoButton.enabled = self.mapView.editorLayer.mapData.canRedo && !self.mapView.editorLayer.hidden;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.mapView.viewController = self;

	AppDelegate * delegate = [AppDelegate getAppDelegate];
	delegate.mapView = self.mapView;

	[self.mapView.editorLayer setSelectionChangeCallback:^{
		[self updateDeleteButtonState];
	}];

	// undo/redo buttons
	[self updateUndoRedoButtonState];

	[self.mapView.editorLayer.mapData addChangeCallback:^{
		[self updateUndoRedoButtonState];
	}];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:NULL];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.navigationController.navigationBarHidden = YES;
}


-(void)search:(UILongPressGestureRecognizer *)recognizer
{
	if ( recognizer.state == UIGestureRecognizerStateBegan ) {
		[self performSegueWithIdentifier:@"searchSegue" sender:recognizer];
	}
}


- (void)installLocationLongPressGestureRecognizer:(BOOL)install
{
	if ( [self.locationButton respondsToSelector:@selector(view)] ) {
		UIView * view = [(id)self.locationButton view];
		if ( install ) {
			if ( view.gestureRecognizers.count == 0 ) {
				UILongPressGestureRecognizer * gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(search:)];
				[view addGestureRecognizer:gesture];
			}
		} else {
			view.gestureRecognizers = nil;
		}
	}
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	
	DLog(@"memory warning: %f MB used", MemoryUsedMB() );

	[self.mapView flashMessage:NSLocalizedString(@"Low memory: clearing cache",nil)];

	[_mapView.editorLayer didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	CGRect rc = self.view.bounds;
	self.mapView.frame = rc;
	[self.mapView viewDidAppear];
	[self installLocationLongPressGestureRecognizer:YES];

	_toolbar.layer.zPosition = 9000;
}

-(void)setGpsState:(GPS_STATE)state
{
	if ( self.mapView.gpsState != state ) {
		self.mapView.gpsState = state;

	//	self.locationButton.tintColor = state != GPS_STATE_NONE ? [UIColor colorWithRed:0.6 green:0.3 blue:0.9 alpha:1] : nil;

		if ( self.mapView.gpsState == GPS_STATE_NONE ) {
			UIImage * image = [UIImage imageNamed:@"723-location-arrow-toolbar"];
			UIButton * button = self.locationButton.customView;
			[button setImage:image forState:UIControlStateNormal];
		} else {
			UIImage * image = [UIImage imageNamed:@"723-location-arrow-toolbar-selected"];
			UIButton * button = self.locationButton.customView;
			[button setImage:image forState:UIControlStateNormal];
		}

		// changing the button tint changes the view, so we have to install longpress again
		[self installLocationLongPressGestureRecognizer:YES];
	}
}

-(IBAction)toggleLocation:(id)sender
{
	switch (self.mapView.gpsState) {
		case GPS_STATE_NONE:
			[self setGpsState:GPS_STATE_LOCATION];
			break;
		case GPS_STATE_LOCATION:
			[self setGpsState:GPS_STATE_HEADING];
			break;
		default:
			[self setGpsState:GPS_STATE_NONE];
			break;
	}
}

-(void)applicationDidEnterBackground:(id)sender
{
	AppDelegate * appDelegate = [AppDelegate getAppDelegate];
	if ( appDelegate.mapView.gpsInBackground && appDelegate.mapView.enableBreadCrumb ) {
		// allow GPS collection in background
	} else {
		// turn off GPS tracking
		[self setGpsState:GPS_STATE_NONE];
	}
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
	[coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
		CGRect rc = self.mapView.frame;
		rc.size = size;
		self.mapView.frame = rc;
	} completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
	}];
}

// disable gestures inside toolbar buttons
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
	// http://stackoverflow.com/questions/3344341/uibutton-inside-a-view-that-has-a-uitapgesturerecognizer

	if ( [touch.view isKindOfClass:[UIControl class]] || [touch.view isKindOfClass:[UIToolbar class]] ) {
		// we touched a button, slider, or other UIControl
		return NO; // ignore the touch
	}
    return YES; // handle the touch
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ( [sender isKindOfClass:[OsmNote class]] ) {
		NotesTableViewController * con = segue.destinationViewController;
		if ( [con isKindOfClass:[NotesTableViewController class]] ) {
			con.note = sender;
			con.mapView = _mapView;
		}
	}
}

@end
