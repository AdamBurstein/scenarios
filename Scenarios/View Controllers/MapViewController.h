//
//  MapViewController.h
//  Scenarios
//
//  Created by Adam Burstein on 5/2/18.
//  Copyright © 2018 Adam Burstein. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSString *locationName;
@property (nonatomic, strong) NSDictionary *sublocation;

@end
