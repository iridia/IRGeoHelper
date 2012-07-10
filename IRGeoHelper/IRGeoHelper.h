//
//  IRGeoHelper.h
//  IRGeoHelper
//
//  Created by Evadne Wu on 6/20/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "IRMapView.h"

extern BOOL IRCoordinateRegionEqualToRegion (MKCoordinateRegion lhs, MKCoordinateRegion rhs);
extern BOOL IRLocationCoordinateEqualToCoordinate (CLLocationCoordinate2D lhs, CLLocationCoordinate2D rhs);
extern BOOL IRCoordinateSpanEqualToSpan (MKCoordinateSpan lhs, MKCoordinateSpan rhs);

extern NSString * IRStringFromMKMapRect (MKMapRect mapRect);
extern NSString * IRStringFromCLLocationCoordinate (CLLocationCoordinate2D coordinate);
