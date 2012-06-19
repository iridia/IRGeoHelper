//
//  IRMapView.m
//  IRGeoHelper
//
//  Created by Evadne Wu on 6/20/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "IRMapView.h"
#import "IRGeoInterceptor.h"

@interface IRMapView () <MKMapViewDelegate>

- (void) commonInit;

@property (nonatomic, readonly, strong) IRGeoInterceptor *interceptor;

@end


@implementation IRMapView
@synthesize interceptor = _interceptor;

- (id) initWithFrame:(CGRect)frame {

	self = [super initWithFrame:frame];
	if (!self)
		return nil;
	
	[self commonInit];
	
	return self;

}

- (id) initWithCoder:(NSCoder *)aDecoder {

	self = [super initWithCoder:aDecoder];
	if (!self)
		return nil;
	
	[self commonInit];
	
	return self;

}

- (void) awakeFromNib {

	[super awakeFromNib];
	
	[self commonInit];

}

- (void) commonInit {
	
	[self interceptor];

}

- (IRGeoInterceptor *) interceptor {

	if (!_interceptor) {
	
		_interceptor = [IRGeoInterceptor new];
		_interceptor.middleMan = self;
	
		[super setDelegate:(id<MKMapViewDelegate>)_interceptor];
	
	}
	
	return _interceptor;

}

- (id<MKMapViewDelegate>) delegate {
	
	return _interceptor.receiver;

}

- (void) setDelegate:(id<MKMapViewDelegate>)delegate {

	_interceptor.receiver = delegate;
	
}

- (void) mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {

	//	?

	[(id<MKMapViewDelegate>)_interceptor.receiver mapView:mapView regionWillChangeAnimated:animated];

}

- (void) setRegion:(MKCoordinateRegion)region animated:(BOOL)animated completion:(void(^)(void))block {

	//	?

}

- (void) setCenterCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated completion:(void(^)(void))block {

	//	?

}

- (void) setVisibleMapRect:(MKMapRect)mapRect edgePadding:(UIEdgeInsets)insets animated:(BOOL)animate completion:(void(^)(void))block {

	//	?

}

@end
