//
//  IRGeoHelper.m
//  IRGeoHelper
//
//  Created by Evadne Wu on 6/20/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "IRGeoHelper.h"

BOOL IRCoordinateRegionEqualToRegion (MKCoordinateRegion lhs, MKCoordinateRegion rhs) {

	return IRLocationCoordinateEqualToCoordinate(lhs.center, rhs.center) &&
		IRCoordinateSpanEqualToSpan(lhs.span, rhs.span);

}

BOOL IRLocationCoordinateEqualToCoordinate (CLLocationCoordinate2D lhs, CLLocationCoordinate2D rhs) {

	return (lhs.latitude == rhs.latitude) &&
		(lhs.longitude == rhs.longitude);

}

BOOL IRCoordinateSpanEqualToSpan (MKCoordinateSpan lhs, MKCoordinateSpan rhs) {

	return (lhs.latitudeDelta == rhs.latitudeDelta) &&
		(lhs.longitudeDelta == rhs.longitudeDelta);

}
