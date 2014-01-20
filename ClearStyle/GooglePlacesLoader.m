//
//  PlacesLoader.m
//  ClearStyle
//
//  Created by Tom Bell on 05/12/2013.
//  Copyright (c) 2013 Jean-Pierre Distler. All rights reserved.
//

#import "GooglePlacesLoader.h"
#import <CoreLocation/CoreLocation.h>
#import <Foundation/NSJSONSerialization.h>

NSString * const apiURL = @"https://maps.googleapis.com/maps/api/place/";
NSString * const apiKey = @"AIzaSyBinHWZt-jbcN3od2juNC1qj2m2oElyBJM";

@interface GooglePlacesLoader () <NSURLConnectionDelegate>

@property (strong, nonatomic) SuccessHandler successHandler;
@property (strong, nonatomic) ErrorHandler errorHandler;
@property (strong, nonatomic) NSMutableData *responseData;

@end

@implementation GooglePlacesLoader

+ (GooglePlacesLoader *)sharedInstance
{
    // Declare a static variable for the instance.
    static GooglePlacesLoader *instance = nil;
    static dispatch_once_t onceToken;

    // Use the dispatch_once macro to allocate the PlacesLoader instance using GCD.
    // The token makes sure that the dispatch_once macro is executed only once.
    dispatch_once(&onceToken, ^{
        instance = [[GooglePlacesLoader alloc] init];
    });

    return instance;
}

- (void)loadPOIsForKeywords:(NSString *)keywords location:(CLLocation *)location radius:(NSInteger)radius
             successHandler:(SuccessHandler)handler errorHandler:(ErrorHandler)errorHandler
{
    // Make sure there is no old response data from a first connection by setting _responseData to nil.
    _responseData = nil;
    [self setSuccessHandler:handler];
    [self setErrorHandler:errorHandler];

    // Get the location latitude and longitude.
    CLLocationDegrees latitude = location.coordinate.latitude;
    CLLocationDegrees longitude = location.coordinate.longitude;

    // Form the Google Places API call string, requesting the response in JSON format, setting sensor=true
    // (required for mobile devices) and including the user-supplied keywords and the app-specific API key.
    NSMutableString *uri = [NSMutableString stringWithString:apiURL];
    [uri appendFormat:@"nearbysearch/json?location=%f,%f&radius=%ld&sensor=true&keyword=%@&key=%@",
     latitude, longitude, (long)radius, keywords, apiKey];

    // Create an NSURLRequest with no caching and a timeout of 20 seconds.
    NSMutableURLRequest *request = [NSMutableURLRequest
                    requestWithURL:[NSURL URLWithString:[uri stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                    cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20.0f];

    // Configure the request.
    [request setHTTPShouldHandleCookies:YES];
    [request setHTTPMethod:@"GET"];

    // Create an NSURLConnection with this request and the PlacesLoader instance as its delegate.
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];

    // Show the network activity indicator and log the request to the console.
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSLog(@"Starting connection: %@ for request: %@", connection, request);
}

#pragma mark - NSURLConnectionDelegate Methods

// Add or append the received data to the _responseData object.
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (!_responseData)
    {
        _responseData = [NSMutableData dataWithData:data];
    }
    else
    {
        [_responseData appendData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Hide the network activity indicator.
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    // Start parsing the JSON response to the request.
    // TO-DO: Handle errors when parsing the JSON data.
    id object = [NSJSONSerialization JSONObjectWithData:_responseData options:NSJSONReadingAllowFragments error:nil];

    if (_successHandler)
    {
        _successHandler(object);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // Hide the network activity indicator.
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    // Pass the connection error object to the error handler.
    if (_errorHandler)
    {
        _errorHandler(error);
    }
}

@end