# IRGeoHelper

MapKit callbacks made easy.  p.s. GOOD JOB MAPKIT TEAM, THE NEW MAP IS AWESOME!!

## Sample

Look at the [Sample App](https://github.com/iridia/IRGeoHelper-Sample).  It has a map view and three buttons.

## What’s Inside

There’s an `IRMapView`, again a drop-in replacement for `MKMapView`.  You can now do this (all code copied from the sample app):

	[self.mapView setRegion:region animated:YES completion:^{
	
		[[[UIAlertView alloc] initWithTitle:@"Changed Region" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
		
	}];

Not satisfied?  How about this:

	[self.mapView setCenterCoordinate:coordinate animated:YES completion:^{
	
		[[[UIAlertView alloc] initWithTitle:@"Changed Center Coordinate" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
		
	}];

Or this:

	[self.mapView setVisibleMapRect:MKMapRectWorld edgePadding:UIEdgeInsetsZero animated:YES completion:^{
	
		[[[UIAlertView alloc] initWithTitle:@"Changed Map Rect" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
		
	}];

Yes, you *can* nest them.  And, also yes, if you invoke these methods when the user is scrolling, IRMapView is polite enough to animate only after the user has finished scrolling.  If you would rather not do anything, you can observe the (currently private) `changingRegion` property on the map view, which is a BOOL.  It participates in KVO.

## Credits

*	[Evadne Wu](http://twitter.com/evadne) at [Iridia Productions](http://iridia.tw) / [Waveface Inc](http://waveface.com).  Initial Implementation / Current Maintainer
*	[Stan Chang Khin Boon](http://twitter.com/lxcid).  Contributor.
