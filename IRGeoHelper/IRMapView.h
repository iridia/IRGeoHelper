//
//  IRMapView.h
//  IRGeoHelper
//
//  Created by Evadne Wu on 6/20/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface IRMapView : MKMapView

- (void) setRegion:(MKCoordinateRegion)region animated:(BOOL)animated completion:(void(^)(void))block;

- (void) setCenterCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated completion:(void(^)(void))block;

- (void) setVisibleMapRect:(MKMapRect)mapRect edgePadding:(UIEdgeInsets)insets animated:(BOOL)animated completion:(void(^)(void))block;

@end
