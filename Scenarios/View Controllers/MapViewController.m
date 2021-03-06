//
//  MapViewController.m
//  Scenarios
//
//  Created by Adam Burstein on 5/2/18.
//  Copyright © 2018 Adam Burstein. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()

#define METERS_PER_MILE 1609.344

@end

CLLocationDegrees lat;
CLLocationDegrees lng;
NSString *annotationTitle;
NSString *annotationSubtitle;

@implementation MapViewController

@synthesize locationName;
@synthesize sublocation;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.mapView.delegate = self;
    
    [self.navigationItem setTitleView:[self getTitleView]];
    [self setBaseMap];
}

- (UIView *) getTitleView
{
    UIView *titleView = [[UIView alloc] initWithFrame:self.navigationController.navigationBar.bounds];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 20)];
    UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 22, 300, 20)];
    titleLabel.text = locationName;
    subtitleLabel.text = [sublocation valueForKey:@"name"];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:17.0f]];
    [subtitleLabel setFont:[UIFont systemFontOfSize:17.0f]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [subtitleLabel setTextColor:[UIColor whiteColor]];
    [subtitleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [subtitleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleView addSubview:titleLabel];
    [titleView addSubview:subtitleLabel];
    
    return titleView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)setBaseMap
{
    CLLocationCoordinate2D zoomLocation = CLLocationCoordinate2DMake(0,0);
    
    zoomLocation.latitude = [[sublocation valueForKey:@"latitude"] doubleValue];
    zoomLocation.longitude = [[sublocation valueForKey:@"longitude"] doubleValue];
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5 * METERS_PER_MILE, 0.5 * METERS_PER_MILE);
    
    [self.mapView setRegion: viewRegion];
    

    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = zoomLocation;
    annotation.title = locationName;
    annotation.subtitle = [sublocation valueForKey:@"name"];
    
    [self.mapView addAnnotation:annotation];
    
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;

    MKAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"loc"];
    annotationView.canShowCallout = YES;
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [annotationView prepareForDisplay];
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(nonnull MKAnnotationView *)view
{
    [mapView deselectAnnotation:view.annotation animated:NO];
    NSString *googleUrlString = [NSString stringWithFormat:@"https://maps.google.com/?q=%f,%f&zoom=14&views=traffic", view.annotation.coordinate.latitude, view.annotation.coordinate.longitude];
    NSString *appleUrlString = [NSString stringWithFormat:@"http://maps.apple.com/?q=%f,%f", view.annotation.coordinate.latitude, view.annotation.coordinate.longitude];

    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:appleUrlString]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appleUrlString] options:@{} completionHandler:nil];
    }
    else
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:googleUrlString] options:@{} completionHandler:nil];
    }
}

@end
