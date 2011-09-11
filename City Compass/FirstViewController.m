//
//  FirstViewController.m
//  City Compass
//
//  Created by Fahd on 9/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FirstViewController.h"
#import <CoreLocation/CLHeading.h>

#import "math.h"

#define toRad(X) (X*M_PI/180.0)
#define toDeg(X) (X*180.0/M_PI)

@implementation FirstViewController
@synthesize compassView;

@synthesize locationManager, currentHeading;

- (void)customInitialize {
    
    cityHeading = 0.0;
    currentHeading = 0.0;
    
    labelDestination.textRadius = 120.0;
    labelDestination.text = @" ";
    labelDestination.textColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
    
    cityArrowView.alpha = 0.0;
    cityTextView.alpha = 0.0;

}

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle {
    if (self = [super initWithNibName:nibName bundle:nibBundle]) {
        [self customInitialize];
        return self;
    }
    
    return nil;
}

- (void)updateHeadingDisplays {
    // Animate Compass
    [UIView     animateWithDuration:0.3
                              delay:0.0 
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             CGAffineTransform headingRotation;
                             headingRotation = CGAffineTransformRotate(CGAffineTransformIdentity, (CGFloat)-toRad(currentHeading));
                             compassView.transform = headingRotation;
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    // Animate Pointer
    [UIView     animateWithDuration:0.6
                              delay:0.0 
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             CGAffineTransform headingRotation;
                             headingRotation = CGAffineTransformRotate(CGAffineTransformIdentity, (CGFloat)toRad(cityHeading)-toRad(currentHeading));
                             cityArrowView.transform = headingRotation;
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    
    // Animate Text
    [UIView     animateWithDuration:1.2
                              delay:0.0 
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             CGAffineTransform headingRotation;
                             headingRotation = CGAffineTransformRotate(CGAffineTransformIdentity, (CGFloat)toRad(cityHeading)-toRad(currentHeading));
                             cityTextView.transform = headingRotation;
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    
}


// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"latitude %+.6f, longitude %+.6f\n",
          newLocation.coordinate.latitude,
          newLocation.coordinate.longitude);
    currentLocation = newLocation.coordinate;
    [self updateHeadingDisplays];
    // else skip the event and process the next one.
}

- (void)startLocationHeadingEvents {
    if (!self.locationManager) {
        CLLocationManager* theManager = [[[CLLocationManager alloc] init] autorelease];
        
        // Retain the object in a property.
        self.locationManager = theManager;
        locationManager.delegate = self;
    }
    
    // Start location services to get the true heading.
    locationManager.distanceFilter = 1;
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    [locationManager startUpdatingLocation];
    
    // Start heading updates.
    if ([CLLocationManager headingAvailable]) {
        locationManager.headingFilter = 5;
        [locationManager startUpdatingHeading];
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    if (newHeading.headingAccuracy < 0)
        return;
    
    // Use the true heading if it is valid.
    CLLocationDirection  theHeading = ((newHeading.trueHeading > 0) ?
                                       newHeading.trueHeading : newHeading.magneticHeading);
    
    self.currentHeading = theHeading;
    [self updateHeadingDisplays];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self startLocationHeadingEvents];  
    
    [self updateHeadingDisplays];
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.locationManager) {
        [locationManager stopUpdatingHeading];
        [locationManager stopUpdatingLocation];
    }
    [super viewWillDisappear:animated];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self customInitialize];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload
{
    [self setCompassView:nil];
    [searchBarOutlet release];
    searchBarOutlet = nil;
    [cityArrowView release];
    cityArrowView = nil;
    
    [labelDestination release];
    labelDestination = nil;
    [cityTextView release];
    cityTextView = nil;
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [compassView release];
    [searchBarOutlet release];
    [cityArrowView release];
    [labelDestination release];
    [cityTextView release];
    [locationManager release];
    [forwardGeocoder release];

    [super dealloc];
}

//Editing Text
//– searchBar:textDidChange:
//– searchBar:shouldChangeTextInRange:replacementText:

//– (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
//    return YES;
//}

//– searchBarTextDidBeginEditing:

//- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
//    return YES;
//}

//– searchBarTextDidEndEditing:

//Clicking Buttons
//– searchBarBookmarkButtonClicked:

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	
    NSLog(@"Searching for: %@", searchBar.text);
	
    if(!forwardGeocoder)
	{
		forwardGeocoder = [[BSForwardGeocoder alloc] initWithDelegate:self];
	}
    
	// Forward geocode!
	[forwardGeocoder findLocation:searchBar.text];
    
    [searchBar resignFirstResponder];
    
    //    NSLog(searchBar.text);
}


//– searchBarResultsListButtonClicked:


-(CLLocationDirection) directionFrom: (CLLocationCoordinate2D) startPt to:(CLLocationCoordinate2D) endPt {
    double lat1 = toRad(startPt.latitude);
    double lat2 = toRad(endPt.latitude);
    double lon1 = toRad(startPt.longitude);
    double lon2 = toRad(endPt.longitude);
    double dLon = (lon2-lon1);
    
    double y = sin(dLon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    double brng = toDeg(atan2(y, x));
    
    brng = (brng+360);
    brng = (brng>360)? (brng-360) : brng;
    
    return brng;
}

//Scope Button
//– searchBar:selectedScopeButtonIndexDidChange:

- (void)forwardGeocoderFoundLocation:(BSForwardGeocoder*)geocoder
{
	if(forwardGeocoder.status == G_GEO_SUCCESS)
	{
        BSKmlResult *place = [forwardGeocoder.results objectAtIndex:0];
        
        cityLocation = place.coordinate;
        cityHeading = [self directionFrom:currentLocation to:cityLocation];
        
        labelDestination.text = place.address;
        
        NSLog(@"City Heading: %f", cityHeading);
        
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction animations:^{
            cityArrowView.alpha = 1.0;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction animations:^{
                cityTextView.alpha = 1.0;
            } completion:^(BOOL finished) {}];
        }];
        
        [self updateHeadingDisplays];
        
        
	}
	else {
		NSString *message = @"";
		
		switch (forwardGeocoder.status) {
			case G_GEO_BAD_KEY:
				message = @"The API key is invalid.";
				break;
				
			case G_GEO_UNKNOWN_ADDRESS:
				message = [NSString stringWithFormat:@"Could not find %@", forwardGeocoder.searchQuery];
				break;
				
			case G_GEO_TOO_MANY_QUERIES:
				message = @"Too many queries has been made for this API key.";
				break;
				
			case G_GEO_SERVER_ERROR:
				message = @"Server error, please try again.";
				break;
				
			default:
				break;
		}
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information" 
														message:message
													   delegate:nil 
											  cancelButtonTitle:@"OK" 
											  otherButtonTitles: nil];
		[alert show];
		[alert release];
	}
}


@end
