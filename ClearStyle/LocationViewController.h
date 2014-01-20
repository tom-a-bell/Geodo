//
//  LocationViewController.h
//  ClearStyle
//
//  Created by Tom Bell on 06/12/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreData/CoreData.h>

#import "Place.h"

@interface LocationViewController : UITableViewController <CLLocationManagerDelegate, NSFetchedResultsControllerDelegate,
                                                           UIPickerViewDataSource, UIPickerViewDelegate, MKMapViewDelegate,
                                                           UITextFieldDelegate, UITextViewDelegate>

// The location that this view edits
@property (nonatomic) Place *place;

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet UITextField *address;
@property (weak, nonatomic) IBOutlet UITextField *locationName;
@property (weak, nonatomic) IBOutlet UIButton *currentLocationButton;
@property (weak, nonatomic) IBOutlet UIButton *saveLocationButton;
@property (weak, nonatomic) IBOutlet UIPickerView *locationPicker;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

// Properties of the Core Data stack
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)beginSearch:(id)sender;
- (IBAction)useCurrentLocation:(id)sender;
- (IBAction)nameChanged:(id)sender;
- (IBAction)saveLocation:(id)sender;

@end
