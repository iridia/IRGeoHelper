//
//  IRMapView.m
//  IRGeoHelper
//
//  Created by Evadne Wu on 6/20/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "IRMapView.h"
#import "IRGeoInterceptor.h"
#import "IRGeoHelper.h"


static NSString * const kRegionWillChangeNotificationName = @"IRMapViewWillChangeRegionNotification";
static NSString * const kRegionDidChangeNotificationName = @"IRMapViewDidChangeRegionNotification";


@interface IRMapView () <MKMapViewDelegate>

+ (IRMapView *) referenceMapView;	//	for measurement only

- (void) commonInit;

@property (nonatomic, readonly, strong) IRGeoInterceptor *interceptor;
@property (nonatomic, readwrite, assign) BOOL changingRegion;

- (BOOL) canIgnoreChangeToRegion:(MKCoordinateRegion)toRegion;
- (BOOL) canIgnoreChangeToCenter:(CLLocationCoordinate2D)toCoordinate;
- (BOOL) canIgnoreChangeToMapRect:(MKMapRect)toMapRect;

- (void) performOnRegionChangeStabilized:(void(^)(void))block;
- (void) handleCallbackBlock:(void(^)(void))block callingSiteWantsAnimation:(BOOL)animated;
- (void) enqueueRegionChangeCallback:(void(^)(void))block;

@property (nonatomic, readonly, strong) NSMutableDictionary *listeners;

- (id) waitForNotification:(NSString *)name object:(id)object timeout:(NSTimeInterval)timeout validator:(BOOL(^)(NSNotification *note))validator handler:(void(^)(NSNotification *note))block;	//	Pass 0 to wait forever, otherwise notification listener can be uprooted on timeout; returns observer which can be weakly referenced for premature removal; reference NSNotificationCenter Class Reference — under ARC, the notification center retains this object

@end


@implementation IRMapView
@synthesize interceptor = _interceptor;
@synthesize changingRegion = _changingRegion;
@synthesize listeners = _listeners;

+ (IRMapView *) referenceMapView {

	static dispatch_once_t onceToken;
	static IRMapView *mapView;
	
	dispatch_once(&onceToken, ^{
		mapView = [[self alloc] initWithFrame:CGRectZero];
	});
	
	return mapView;

}

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
	[self listeners];

}

- (IRGeoInterceptor *) interceptor {

	if (!_interceptor) {
	
		_interceptor = [IRGeoInterceptor new];
		_interceptor.middleMan = self;
	
		[super setDelegate:(id<MKMapViewDelegate>)_interceptor];
	
	}
	
	return _interceptor;

}

- (NSMutableDictionary *) listeners {

	if (!_listeners) {
	
		_listeners = [NSMutableDictionary dictionary];
	
	}
	
	return _listeners;

}

- (id<MKMapViewDelegate>) delegate {
	
	return _interceptor.receiver;

}

- (void) setDelegate:(id<MKMapViewDelegate>)delegate {

	if (_interceptor.receiver != delegate)
		[super setDelegate:nil];

	_interceptor.receiver = delegate;
	
	if ([super delegate] != _interceptor)
		[super setDelegate:(id<MKMapViewDelegate>)_interceptor];
	
}

- (void) mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {

	self.changingRegion = YES;
	
	NSNotificationCenter * const nc = [NSNotificationCenter defaultCenter];
	id <MKMapViewDelegate> const target = _interceptor.receiver;
	
	[nc postNotificationName:kRegionWillChangeNotificationName object:self];
	
	if ([target respondsToSelector:@selector(mapView:regionWillChangeAnimated:)])
		[target mapView:mapView regionWillChangeAnimated:animated];

}

- (void) mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {

	self.changingRegion = NO;

	NSNotificationCenter * const nc = [NSNotificationCenter defaultCenter];
	id <MKMapViewDelegate> const target = _interceptor.receiver;
	
	[nc postNotificationName:kRegionDidChangeNotificationName object:self];
	
	if ([target respondsToSelector:@selector(mapView:regionDidChangeAnimated:)])
		[target mapView:mapView regionDidChangeAnimated:animated];

}

- (void) setRegion:(MKCoordinateRegion)toRegion animated:(BOOL)animated completion:(void(^)(void))block {

	if ([self canIgnoreChangeToRegion:toRegion]) {
	
		if (block)
			block();
	
	} else {
	
		[self performOnRegionChangeStabilized:^{

			[self setRegion:toRegion animated:animated];
			[self handleCallbackBlock:block callingSiteWantsAnimation:animated];
					
		}];
	
	}

}

- (void) setCenterCoordinate:(CLLocationCoordinate2D)toCoordinate animated:(BOOL)animated completion:(void(^)(void))block {

	if ([self canIgnoreChangeToCenter:toCoordinate]) {
	
		if (block)
			block();
		
	} else {
	
		[self performOnRegionChangeStabilized:^{

			[self setCenterCoordinate:toCoordinate animated:animated];
			[self handleCallbackBlock:block callingSiteWantsAnimation:animated];
		
		}];
	
	}
	
}

- (void) setVisibleMapRect:(MKMapRect)mapRect edgePadding:(UIEdgeInsets)insets animated:(BOOL)animated completion:(void(^)(void))block {

	if ([self canIgnoreChangeToMapRect:mapRect]) {
	
		if (block)
			block();
		
	} else {

		[self performOnRegionChangeStabilized:^{
			
			[self setVisibleMapRect:mapRect edgePadding:insets animated:animated];
			[self handleCallbackBlock:block callingSiteWantsAnimation:animated];
			
		}];
	
	}
	
}

- (BOOL) canIgnoreChangeToRegion:(MKCoordinateRegion)toRegion {

	//	TBD: not really

	return (IRCoordinateRegionEqualToRegion(self.region, toRegion));

}

- (BOOL) canIgnoreChangeToCenter:(CLLocationCoordinate2D)toCoordinate {

	//	TBD: not really

	return (IRLocationCoordinateEqualToCoordinate(self.centerCoordinate, toCoordinate));
	
}

- (BOOL) canIgnoreChangeToMapRect:(MKMapRect)toMapRect {

	return NO;

}

- (void) handleCallbackBlock:(void (^)(void))block callingSiteWantsAnimation:(BOOL)animated {

	if (!block)
		return;

	if (!self.userInteractionEnabled) {
		
		//	workaround against bad / identical assignment killing interactivity
		//	TBD: file radar
		
		self.userInteractionEnabled = YES;
		
	}
	
	if (animated && block)
		[self enqueueRegionChangeCallback:block];
	else if (block)
		block();

}

- (void) performOnRegionChangeStabilized:(void(^)(void))block {

	if (self.changingRegion) {
	
		[self enqueueRegionChangeCallback:block];
	
	} else {
	
		block();
	
	}

}

- (void) enqueueRegionChangeCallback:(void(^)(void))block {

	NSCParameterAssert(block);
	
	__weak IRMapView *wSelf = self;
	
	[self waitForNotification:kRegionDidChangeNotificationName object:self timeout:1.0f validator:^BOOL(NSNotification *note) {
	
		//	for posterity
		
		return YES;
		
	} handler:^(NSNotification *note) {
	
		//	On iOS 6.0 (10A5316k) Simulator
		//	this needs to be re-set if timeout is hit
		//	and we have not done anything
		
		wSelf.userInteractionEnabled = YES;
	
		block();
		
	}];
	
}

- (id) waitForNotification:(NSString *)name object:(id)object timeout:(NSTimeInterval)timeout validator:(BOOL(^)(NSNotification *note))validator handler:(void(^)(NSNotification *note))block {

	__weak NSNotificationCenter * const wNC = [NSNotificationCenter defaultCenter];
	__weak IRMapView *wSelf = self;
	
	//	Use an UUID for NOT capturing the listener object in the block
	//	so as to avoid the listener not being cleaned up properly
	//	if notification never fires due to accident or premature removal
	
	CFUUIDRef uuid = CFUUIDCreate(NULL);
	NSString *listenerID = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
	CFRelease(uuid);
	
	id listener = [wNC addObserverForName:name object:object queue:nil usingBlock:^(NSNotification *note) {
	
		if (!wSelf)
			return;
		
		if (validator)
			if (!validator(note))
				return;
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
			block(note);
		
		});
		
		id queriedListener = [[wSelf listeners] objectForKey:listenerID];
		NSCParameterAssert(queriedListener);
		
		[wNC removeObserver:queriedListener];
		[wSelf.listeners removeObjectForKey:listenerID];
		
	}];
	
	[self.listeners setObject:listener forKey:listenerID];
	
	if (timeout) {
	
		__weak id wListener = listener;
	
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, timeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
		
			if (!wListener)
				return;
			
			block(nil);
			
			[[NSNotificationCenter defaultCenter] removeObserver:wListener];
			[wSelf.listeners removeObjectForKey:listenerID];
			
		});

	}
	
	return listener;
	
}

@end
