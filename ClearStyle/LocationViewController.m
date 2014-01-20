//
//  LocationViewController.m
//  ClearStyle
//
//  Created by Tom Bell on 06/12/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import "LocationViewController.h"

#import <MapKit/MapKit.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import <AddressBookUI/AddressBookUI.h>

#import "PlacemarkAnnotation.h"
#import "GooglePlacesLoader.h"
#import "NavigationController.h"

NSString * const kNameKey = @"name";
NSString * const kReferenceKey = @"reference";
NSString * const kAddressKey = @"vicinity";
NSString * const kLatitudeKeypath = @"geometry.location.lat";
NSString * const kLongitudeKeypath = @"geometry.location.lng";

static NSString *AnnotationViewIdentifier = @"PlaceAnnotation";

@implementation LocationViewController
{
    // Store the change state of the location
    BOOL _locationHasChanged;

    // Store the current location of the user
    CLLocation *_currentLocation;

    // Store the selected placemark annotation
    PlacemarkAnnotation *_selectedAnnotation;
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    // Check that location services are not restricted
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied &&
        [CLLocationManager authorizationStatus] != kCLAuthorizationStatusRestricted)
    {
        // Instantiate the location manager
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;

        // Only trigger updates if the location changes by 10m or more
        _locationManager.distanceFilter = 10.0f;
    }

    // Set the location state as initially unchanged
    _locationHasChanged = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Set the navigation bar properties
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor darkTextColor], NSForegroundColorAttributeName,
                                    [UIColor darkTextColor], NSBackgroundColorAttributeName, nil];

    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
    IF_IOS7_OR_GREATER(self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];);
    [self.navigationItem setHidesBackButton:YES animated:NO];

    // Retrieve the managed object context from the navigation controller
    NavigationController *navigationController = (NavigationController *)[self navigationController];
    self.managedObjectContext = navigationController.managedObjectContext;

    // Create a default list of favourite places
    if ([[self.fetchedResultsController sections] count] == 0 || [[self.fetchedResultsController sections][0] numberOfObjects] == 0)
    {
        NSLog(@"Adding default favourite places...");
        [self createDefaultPlaces];
        [self.locationPicker reloadAllComponents];
        NSLog(@"...default favourite places saved!");
    }

    // Set the current location button text and font
    [self.currentLocationButton setTitle:@"\uf124" forState:UIControlStateNormal];
//    [self.currentLocationButton setTitle:@"\uf124" forState:UIControlStateHighlighted];
    [self.currentLocationButton.titleLabel setFont:[UIFont fontWithName:@"FontAwesome" size:17]];

    if ([[self.fetchedResultsController fetchedObjects] containsObject:self.place])
    {
        [self.locationPicker selectRow:[[self.fetchedResultsController indexPathForObject:self.place] row] inComponent:0 animated:NO];
    }
    else
    {
        [self.locationPicker selectRow:0 inComponent:0 animated:NO];
    }

    if (self.place)
    {
        [self.locationName setText:self.place.name];
        [self displayPlace:self.place];
    }
    else
    {
        // Centre the map on the user's current location
        [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Start monitoring the geofence associated with the current place if it has been modified
    if (_locationHasChanged)
    {
        // If location services are restricted, do nothing
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied ||
            [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted)
        {
            return;
        }

        // Start monitoring the region (if it is already being monitored, the region is updated)
        NSLog(@"Start monitoring for region: %@", self.place.name);
        for (CLCircularRegion *region in self.place.location)
        {
            [_locationManager startMonitoringForRegion:region];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)beginSearch:(id)sender
{
    if ([self.address.text isEqualToString:@""])
    {
        return;
    }

    // Lock the UI to prevent user interaction while searching
    [self lockUI:YES];
    [self.locationName setText:@""];

    // Remove any previous annotations from the Map View
    [self.mapView removeAnnotations:self.mapView.annotations];

//    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
//    [geocoder geocodeAddressString:self.address.text inRegion:nil completionHandler:^(NSArray *placemarks, NSError *error)
//    {
//        if (error)
//        {
//            NSLog(@"Geocode failed with error:\n%@", error);
//            [self displayError:error];
//            return;
//        }
//
////        NSLog(@"Received Geocoder Results:\n%@", placemarks);
//        [self displayPlacemarks:placemarks];
//
//    }];

    [[GooglePlacesLoader sharedInstance] loadPOIsForKeywords:self.address.text location:self.mapView.userLocation.location
                                                      radius:2000 successHandler:^(NSDictionary *response)
    {
        [self processGooglePlacesResponse:response];
    } errorHandler:^(NSError *error)
    {
        NSLog(@"Google Places search failed with error:\n%@", error);
        [self displayError:error];
    }];
}

- (IBAction)useCurrentLocation:(id)sender
{
    // Clear the search and location name fields
    [self.address setText:@""];
    [self.locationName setText:@""];

    // Remove any previous annotations from the Map View
    [self.mapView removeAnnotations:self.mapView.annotations];

    [self startUpdatingCurrentLocation];
}

- (IBAction)nameChanged:(id)sender
{
    self.place.name = self.locationName.text;
}

- (IBAction)saveLocation:(id)sender
{
    // If a name is not specified, alert the user and return
    if (self.locationName.text == nil || [self.locationName.text isEqualToString:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc] init];
        alert.title = @"Name Required";
        alert.message = @"Enter a name for the location to be saved.";
        [alert addButtonWithTitle:NSLocalizedString(@"OK", nil)];
        [alert show];
        return;
    }

    // If a location is not specified, alert the user and return
    if (!self.place.location || self.place.location.count == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] init];
        alert.title = @"Location Required";
        alert.message = @"A location must be specified before it can be saved.";
        [alert addButtonWithTitle:NSLocalizedString(@"OK", nil)];
        [alert show];
        return;
    }

    // Check if a favourite place already exists with the given name
    for (Place *favourite in [self.fetchedResultsController fetchedObjects])
    {
        if ([self.locationName.text localizedCaseInsensitiveCompare:favourite.name] == NSOrderedSame)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Replace Location?", nil)
                                                            message:[NSString
                                                                     stringWithFormat:@"A location with the name “%@” already exists. Do you want to replace it?",
                                                                     self.locationName.text] delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                      otherButtonTitles:NSLocalizedString(@"Replace", nil), nil];
            [alert show];
            return;
        }
    }

    // Create a new place to prevent overwriting an existing favourite
    Place *place = [NSEntityDescription insertNewObjectForEntityForName:@"Place" inManagedObjectContext:self.managedObjectContext];

    // Assign it the properties of the current place
    place.name = self.locationName.text;
    place.address = self.place.address;
    place.location = self.place.location;
    place.favourite = YES;

    // Assign a new reference ID and creation date
    place.reference = [[NSUUID UUID] UUIDString];
    place.created = [NSDate date];

    // Update the identifier for each location
    NSMutableArray *newLocation = [NSMutableArray array];
    for (CLCircularRegion *location in self.place.location)
    {
        CLCircularRegion *geofence = [[CLCircularRegion alloc] initWithCenter:location.center radius:location.radius identifier:place.reference];
        [newLocation addObject:geofence];
    }
    place.location = newLocation;

    // Add the place to the list of favourites
    [self saveContext];

    self.place = place;
    _locationHasChanged = YES;

    [self.locationPicker selectRow:[[self.fetchedResultsController indexPathForObject:self.place] row] inComponent:0 animated:YES];
    [self.locationName setText:self.place.name];
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // Close the keyboard on pressing enter
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] != 1)
    {
        [self.address resignFirstResponder];
    }
    if ([indexPath row] != 3)
    {
        [self.locationName resignFirstResponder];
    }
}

#pragma mark - UIPickerViewDataSource Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    id <NSFetchedResultsSectionInfo> componentInfo = [self.fetchedResultsController sections][component];
    return [componentInfo numberOfObjects];
}

#pragma mark - UIPickerViewDelegate Methods

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    // Fetch the appropriate favourite place
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:component];
    Place *place = [self.fetchedResultsController objectAtIndexPath:indexPath];

    // Return the place name
    return place.name;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _locationHasChanged = YES;

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:component];
    self.place = [self.fetchedResultsController objectAtIndexPath:indexPath];
    self.locationName.text = self.place.name;

    // Check that the selected place is valid, set to nil if not
    if ([self.place.location count] == 0)
    {
        self.place = nil;
    }

    // Mark the location(s) associated with the selected place on the map
    if (self.place)
    {
        [self displayPlace:self.place];
    }
}

#pragma mark - UIAlertViewDelegate Methods

// Handle responses selected from the various alert views presented to the user
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[alertView buttonTitleAtIndex:buttonIndex] localizedCompare:@"Remove"] == NSOrderedSame)
    {
        // Delete the placemark and its associated location
        [self.mapView removeAnnotation:_selectedAnnotation];

        for (NSUInteger index = 0; index < self.place.location.count; index++)
        {
            CLCircularRegion *location = [self.place.location objectAtIndex:index];
            if (location.center.latitude  == _selectedAnnotation.coordinate.latitude &&
                location.center.longitude == _selectedAnnotation.coordinate.longitude)
            {
                NSMutableArray *newLocation = [NSMutableArray arrayWithArray:self.place.location];
                [newLocation removeObjectAtIndex:index];
                self.place.location = [NSArray arrayWithArray:newLocation];
                break;
            }
        }
    }

    if ([[alertView buttonTitleAtIndex:buttonIndex] localizedCompare:@"Replace"] == NSOrderedSame)
    {
        // Find the favourite place with matching name to be replaced
        for (Place *favourite in [self.fetchedResultsController fetchedObjects])
        {
            if ([self.locationName.text localizedCaseInsensitiveCompare:favourite.name] == NSOrderedSame)
            {
                [self replaceFavourite:favourite];
                break;
            }
        }
    }
}

#pragma mark - MKMapViewDelegate Methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    // If the annotation is for the user's current location, use the default view
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
		return nil;
    }

    // Re-use or create an annotation view
    MKPinAnnotationView *view = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewIdentifier];

    if (view == nil)
    {
        view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewIdentifier];

        // Configure the annotation view properties
        [self configureAnnotationView:view forAnnotation:annotation];
    }
    else
    {
        // Update the annotation assigned to this view
        view.annotation = annotation;
    }

    return view;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    // Get the annotation associated with the view
    _selectedAnnotation = view.annotation;

    if (control == view.leftCalloutAccessoryView)
    {
        // Present an alert asking the user to confirm deletion of the placemark and its associated location
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Remove Location?", nil)
                                                            message:[NSString stringWithFormat:@"Remove the location “%@” from the current collection?",
                                                                     view.annotation.title] delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                  otherButtonTitles:NSLocalizedString(@"Remove", nil), nil];
        [alertView show];
    }
    else if (control == view.rightCalloutAccessoryView)
    {
        UIAlertView *infoView = [[UIAlertView alloc] initWithTitle:view.annotation.title message:[(PlacemarkAnnotation *)view.annotation details] delegate:nil
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [infoView show];
    }
    else
    {
        NSLog(@"Neither left nor right callout accessory button pressed!");
    }
}

#pragma mark - CLLocationManagerDelegate Methods

- (void)startUpdatingCurrentLocation
{
    // If location services are restricted, do nothing
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted)
    {
        return;
    }

    [_locationManager startUpdatingLocation];
//    [self showCurrentLocationSpinner:YES];
}

- (void)stopUpdatingCurrentLocation
{
    [_locationManager stopUpdatingLocation];
//    [self showCurrentLocationSpinner:NO];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if (![locations count]) return;

    // Fetch the current location
    CLLocation *currentLocation = [locations objectAtIndex:0];

    // Update the map view based on the accuracy of the current location
    CLLocationCoordinate2D coordinate = [currentLocation coordinate];
    CLLocationAccuracy accuracy = [currentLocation horizontalAccuracy];
    NSLog(@"Received location %@ with accuracy %f", currentLocation, accuracy);

    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, MAX(2*accuracy, 500.0f), MAX(2*accuracy, 500.0f));
    [_mapView setRegion:region animated:YES];

    // Do not accept the current location until its accuracy is better than 50m
    if (accuracy > 50.0f)
    {
        return;
    }

    // Store the current location
    _currentLocation = currentLocation;

    // Create a new place with the associated geofence
    NSString *identifier = [[NSUUID UUID] UUIDString];
    NSString *address = [NSString stringWithFormat:@"%.4f, %.4f", _currentLocation.coordinate.latitude, _currentLocation.coordinate.longitude];
    CLCircularRegion *geofence = [[CLCircularRegion alloc] initWithCenter:_currentLocation.coordinate radius:50.0f identifier:identifier];

    Place *place = [NSEntityDescription insertNewObjectForEntityForName:@"Place" inManagedObjectContext:self.managedObjectContext];
    place.name = @"Current Location";
    place.address = address;
    place.location = [NSArray arrayWithObject:geofence];
    place.reference = identifier;
    place.created = [NSDate date];

    self.place = place;
    _locationHasChanged = YES;
    [self.locationPicker selectRow:0 inComponent:0 animated:YES];

    // Lock the UI to prevent user interaction while searching
    [self lockUI:YES];

    NSLog(@"Retrieving address for current location...");

    // Retrieve the address of the current location
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:_currentLocation completionHandler:^(NSArray *placemarks, NSError *error)
    {
        if (error)
        {
            NSLog(@"Geocode lookup failed with error:\n%@", error);
            [self displayError:error];
            return;
        }

//        NSLog(@"Received placemarks:\n%@", placemarks);
        [self displayPlacemarks:placemarks];

    }];

    // After obtaining the current location, stop updating
    [self stopUpdatingCurrentLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location manager failed with error:\n%@", error);

    // Stop updating
    [self stopUpdatingCurrentLocation];

    // Set the current location to the invalid coordinate
    _currentLocation = [[CLLocation alloc] initWithCoordinate:kCLLocationCoordinate2DInvalid altitude:0
                                           horizontalAccuracy:kCLLocationAccuracyKilometer
                                             verticalAccuracy:kCLLocationAccuracyKilometer timestamp:[NSDate date]];

    // Show the error alert
    UIAlertView *alert = [[UIAlertView alloc] init];
    alert.title = @"Error obtaining the current location";
    alert.message = [error localizedDescription];
    [alert addButtonWithTitle:@"OK"];
    [alert show];
}

#pragma mark - CLGeocoder Methods

// Display the result(s) returned by the CLGeocoder search
- (void)displayPlacemarks:(NSArray *)placemarks
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self lockUI:NO];

        if (placemarks.count == 0) return;

        // Retrieve the first search result
        CLPlacemark *firstResult = [placemarks firstObject];

        // Create a new place with the associated geofences and addresses from the search results
        NSString *identifier = [[NSUUID UUID] UUIDString];
        NSString *address = ABCreateStringWithAddressDictionary(firstResult.addressDictionary, NO);
        NSMutableArray *geofences = [NSMutableArray array];
        for (CLPlacemark *placemark in placemarks)
        {
            CLCircularRegion *geofence = [[CLCircularRegion alloc] initWithCenter:placemark.location.coordinate radius:50.0f identifier:identifier];
            [geofences addObject:geofence];
        }

        Place *place = [NSEntityDescription insertNewObjectForEntityForName:@"Place" inManagedObjectContext:self.managedObjectContext];
        place.name = [self.address.text isEqualToString:@""] ? [firstResult.addressDictionary objectForKey:(id)kABPersonAddressStreetKey] : self.address.text;
        place.address = address;
        place.location = geofences;
        place.reference = identifier;
        place.created = [NSDate date];

        self.place = place;
        _locationHasChanged = YES;

        [self.locationName setText:self.place.name];
        [self.locationPicker selectRow:0 inComponent:0 animated:YES];

        // Display the placemark(s) on the Map View
        for (CLPlacemark *placemark in placemarks)
        {
            // Add a pin for the placemark on the map using the MKAnnotation protocol
            PlacemarkAnnotation *annotation = [[PlacemarkAnnotation alloc] initWithPlacemark:placemark];
            [self.mapView addAnnotation:annotation];
        }

        // Adjust the Map View region to show the placemark(s)
        if (placemarks.count == 1)
        {
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(firstResult.location.coordinate, 500.0f, 500.0f);
            [self.mapView setRegion:region animated:YES];
        }
        else
        {
            [self.mapView showAnnotations:self.mapView.annotations animated:YES];
        }
    });
}

// Display the location(s) associated with a place on the Map View
- (void)displayPlace:(Place *)place
{
    // Remove any previous annotations from the Map View
    [self.mapView removeAnnotations:self.mapView.annotations];

    NSMutableArray *allAnnotations = [NSMutableArray array];
    for (CLCircularRegion *region in place.location)
    {
        // Create a placemark for this location
        CLLocationCoordinate2D coordinate = region.center;
        NSDictionary *addressDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                           place.name, @"Name",
                                           place.address, @"Thoroughfare",
                                           place.address, kABPersonAddressStreetKey, nil];

        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:addressDictionary];

        // Add a pin for the placemark on the map using the MKAnnotation protocol
        PlacemarkAnnotation *annotation = [[PlacemarkAnnotation alloc] initWithPlacemark:placemark];
        [self.mapView addAnnotation:annotation];
        [allAnnotations addObject:annotation];
    }

    // Adjust the Map View region to show the location(s)
    [self.mapView showAnnotations:allAnnotations animated:YES];
//    if (place.location.count == 1)
//    {
//        CLCircularRegion *location = [place.location firstObject];
//        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location.center, 500.0f, 500.0f);
//        [self.mapView setRegion:region animated:YES];
//    }
//    else
//    {
//        [self.mapView showAnnotations:allAnnotations animated:YES];
//    }
}

// Display a given NSError in a UIAlertView
- (void)displayError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self lockUI:NO];

        NSString *message;
        switch ([error code])
        {
            case kCLErrorGeocodeFoundNoResult:
                message = @"No results were found matching the search terms.";
                break;
            case kCLErrorGeocodeCanceled:
                message = @"kCLErrorGeocodeCanceled";
                break;
            case kCLErrorGeocodeFoundPartialResult:
                message = @"kCLErrorGeocodeFoundNoResult";
                break;
            case kCLErrorNetwork:
                message = @"The Internet connection appears to be offline.";
                break;
            default:
                message = [error description];
                break;
        }

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location search failed" message:message delegate:nil
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    });   
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController)
    {
        return _fetchedResultsController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Place"];

    // Set the batch size to fetch enough items to fill the table's content view
    [fetchRequest setFetchBatchSize:10];

    // Include only favourite places
    NSPredicate *favouritePlaces = [NSPredicate predicateWithFormat:@"favourite == YES"];
    [fetchRequest setPredicate:favouritePlaces];

    // Sort the places by creation date
    NSSortDescriptor *sortByDate = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortByDate]];

    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:self.managedObjectContext
                                                                      sectionNameKeyPath:nil cacheName:nil];
    _fetchedResultsController.delegate = self;

	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error])
    {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate.
        // You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}

    return _fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.locationPicker reloadAllComponents];
}

#pragma mark - Utility Methods

// Prevent user interaction while processing the geocoding
- (void)lockUI:(BOOL)enable
{
    self.tableView.allowsSelection = !enable;
    self.address.enabled = !enable;
    self.locationName.enabled = !enable;
    self.saveLocationButton.enabled = !enable;
    self.currentLocationButton.enabled = !enable;
    self.locationPicker.userInteractionEnabled = !enable;
    self.mapView.userInteractionEnabled = !enable;
}

- (void)createDefaultPlaces
{
    Place *null = [NSEntityDescription insertNewObjectForEntityForName:@"Place" inManagedObjectContext:self.managedObjectContext];
    null.favourite = YES;
    null.name = @"";
    null.address = nil;
    null.reference = @"";
    null.created = [NSDate date];
    null.location = [NSArray array];
//    null.location = [NSArray arrayWithObject:[[CLCircularRegion alloc] initWithCenter:kCLLocationCoordinate2DInvalid radius:50.0f identifier:null.reference]];

    Place *home = [NSEntityDescription insertNewObjectForEntityForName:@"Place" inManagedObjectContext:self.managedObjectContext];
    home.favourite = YES;
    home.name = @"Home";
    home.address = @"Calle de los Cañizares, 1, 28012 Madrid, Spain";
    home.created = [NSDate date];
    home.reference = [[NSUUID UUID] UUIDString];
    home.location = [NSArray arrayWithObject:[[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(+40.41325800, -3.70148320)
                                                                               radius:50.0f identifier:home.reference]];

    Place *work = [NSEntityDescription insertNewObjectForEntityForName:@"Place" inManagedObjectContext:self.managedObjectContext];
    work.favourite = YES;
    work.name = @"Work";
    work.address = @"Centro de Astrobiología, Carretera de Ajalvir, km 4, 28850 Torrejón de Ardoz, Spain";
    work.created = [NSDate date];
    work.reference = [[NSUUID UUID] UUIDString];
    work.location = [NSArray arrayWithObject:[[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(+40.50322700, -3.46661500)
                                                                               radius:50.0f identifier:work.reference]];

    Place *food = [NSEntityDescription insertNewObjectForEntityForName:@"Place" inManagedObjectContext:self.managedObjectContext];
    food.favourite = YES;
    food.name = @"Supermarket";
    food.address = @"Calle del Príncipe, 9, 28012 Madrid, Spain";
    food.created = [NSDate date];
    food.reference = [[NSUUID UUID] UUIDString];
    food.location = [NSArray arrayWithObject:[[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(+40.41590800, -3.70029200)
                                                                               radius:50.0f identifier:food.reference]];

    Place *apple = [NSEntityDescription insertNewObjectForEntityForName:@"Place" inManagedObjectContext:self.managedObjectContext];
    apple.favourite = YES;
    apple.name = @"Apple Store";
    apple.address = @"235 Regent Street, London, W1B 2EL, United Kingdom";
    apple.created = [NSDate date];
    apple.reference = [[NSUUID UUID] UUIDString];
    apple.location = [NSArray arrayWithObject:[[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(+51.51424445, -0.14197898)
                                                                                radius:1000.0f identifier:apple.reference]];

    Place *parents = [NSEntityDescription insertNewObjectForEntityForName:@"Place" inManagedObjectContext:self.managedObjectContext];
    parents.favourite = YES;
    parents.name = @"Parents";
    parents.address = @"12 Corby Road, Cottingham, Market Harborough, LE16 8XH, United Kingdom";
    parents.created = [NSDate date];
    parents.reference = [[NSUUID UUID] UUIDString];
    parents.location = [NSArray arrayWithObject:[[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(+52.50206700, -0.75424000)
                                                                                  radius:50.0f identifier:parents.reference]];

    [self saveContext];
}

- (void)replaceFavourite:(Place *)favourite
{
    NSLog(@"Replacing favourite:\n%@", favourite);
    NSLog(@"With current place:\n%@", self.place);

    // Assign it the properties of the current place
    favourite.name = self.place.name;
    favourite.address = self.place.address;
    favourite.location = self.place.location;

    // Update the identifier for each location
    NSMutableArray *newLocation = [NSMutableArray array];
    for (CLCircularRegion *location in self.place.location)
    {
        CLCircularRegion *geofence = [[CLCircularRegion alloc] initWithCenter:location.center radius:location.radius identifier:favourite.reference];
        [newLocation addObject:geofence];
    }
    favourite.location = newLocation;

    NSLog(@"Updated favourite properties:\n%@", favourite);

    // Update the list of favourite places
    [self saveContext];

    // Select the place in the Picker View
    [self.locationPicker selectRow:[[self.fetchedResultsController indexPathForObject:favourite] row] inComponent:0 animated:YES];
    [self.locationName setText:favourite.name];
}

- (void)saveContext
{
    NSError *error = nil;
    if (![self.managedObjectContext save:&error])
    {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate.
        // You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (void)processGooglePlacesResponse:(NSDictionary *)response
{
    if (![[response objectForKey:@"status"] isEqualToString:@"OK"])
    {
        return;
    }

    NSMutableArray *placemarks = [NSMutableArray array];

    id places = [response objectForKey:@"results"];

    if ([places isKindOfClass:[NSArray class]])
    {
        for (NSDictionary *resultsDictionary in places)
        {
            CLLocation *location = [[CLLocation alloc] initWithLatitude:[[resultsDictionary valueForKeyPath:kLatitudeKeypath] floatValue]
                                                              longitude:[[resultsDictionary valueForKeyPath:kLongitudeKeypath] floatValue]];

            NSDictionary *addressDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                               [resultsDictionary objectForKey:kNameKey], @"Name",
                                               [resultsDictionary objectForKey:kAddressKey], @"Thoroughfare",
                                               [resultsDictionary objectForKey:kAddressKey], kABPersonAddressStreetKey, nil];

            MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:location.coordinate addressDictionary:addressDictionary];
            [placemarks addObject:placemark];
        }
    }

//    NSLog(@"Received Google Places:\n%@", placemarks);
    [self displayPlacemarks:placemarks];
}

- (void)configureAnnotationView:(MKPinAnnotationView *)view forAnnotation:(PlacemarkAnnotation *)annotation
{
    // Specify the colour of the pin
    view.pinColor = MKPinAnnotationColorRed;

    // Animate the dropping of the pin onto the map
    view.animatesDrop = YES;

    // Display a standard callout bubble when the user taps the annotation view
    view.canShowCallout = YES;

    // Add a delete button to the left side of the callout bubble
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [deleteButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [deleteButton setContentVerticalAlignment:UIControlContentVerticalAlignmentBottom];
    [deleteButton setTitle:@"\u00d7" forState:UIControlStateNormal];
    [deleteButton.titleLabel setTextAlignment:NSTextAlignmentRight];
    [deleteButton.titleLabel setFont:[UIFont systemFontOfSize:24]];
    [deleteButton setFrame:CGRectMake(0, 0, 22, 28)];
    [deleteButton setTintColor:[UIColor redColor]];
    view.leftCalloutAccessoryView = deleteButton;

    // Add a detail disclosure button to the right side of the callout bubble
    view.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

@end
