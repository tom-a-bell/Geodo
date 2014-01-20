//
//  Placemark.m
//  ClearStyle
//
//  Created by Tom Bell on 14/01/2014.
//  Copyright (c) 2014 Tom Bell. All rights reserved.
//

#import "Placemark.h"

@implementation Placemark
NSString * const kPlacemarkAddressNameKey = @"Name";
NSString * const kPlacemarkAddressThoroughfareKey = @"Thoroughfare";
NSString * const kPlacemarkAddressSubThoroughfareKey = @"SubThoroughfare";
NSString * const kPlacemarkAddressLocalityKey = @"Locality";
NSString * const kPlacemarkAddressSubLocalityKey = @"SubLocality";
NSString * const kPlacemarkAddressAdministrativeAreaKey = @"AdministrativeArea";
NSString * const kPlacemarkAddressSubAdministrativeAreaKey = @"SubAdministrativeArea";
NSString * const kPlacemarkAddressPostalCodeKey = @"PostalCode";
NSString * const kPlacemarkAddressCountryKey = @"Country";
NSString * const kPlacemarkAddressCountryCodeKey = @"CountryCode";

- (NSString *)name
{
    return [self.addressDictionary objectForKey:kPlacemarkAddressNameKey];
}

- (NSString *)thoroughfare
{
    return [self.addressDictionary objectForKey:kPlacemarkAddressThoroughfareKey];
}

- (NSString *)subThoroughfare
{
    return [self.addressDictionary objectForKey:kPlacemarkAddressSubThoroughfareKey];
}

- (NSString *)locality
{
    return [self.addressDictionary objectForKey:kPlacemarkAddressLocalityKey];
}

- (NSString *)subLocality
{
    return [self.addressDictionary objectForKey:kPlacemarkAddressSubLocalityKey];
}

- (NSString *)administrativeArea
{
    return [self.addressDictionary objectForKey:kPlacemarkAddressAdministrativeAreaKey];
}

- (NSString *)subAdministrativeArea
{
    return [self.addressDictionary objectForKey:kPlacemarkAddressSubAdministrativeAreaKey];
}

- (NSString *)postalCode
{
    return [self.addressDictionary objectForKey:kPlacemarkAddressPostalCodeKey];
}

- (NSString *)country
{
    return [self.addressDictionary objectForKey:kPlacemarkAddressCountryKey];
}

- (NSString *)countryCode
{
    return [self.addressDictionary objectForKey:kPlacemarkAddressCountryCodeKey];
}
@end
