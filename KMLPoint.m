//
//  KMLPoint.m
//  KMLViewer
//
//  Created by Mojtaba Cazi on 2/27/18.
//

#import "KMLPoint.h"
#import "kml_com.h"

@implementation KMLPoint

@synthesize point;

- (void)endCoordinates {
    flags.inCoords = NO;
    
    CLLocationCoordinate2D *points = NULL;
    NSUInteger len = 0;
    
    strToCoords(accum, &points, &len);
    if (len == 1) {
        point = points[0];
    }
    free(points);
    
    [self clearString];
}

- (MKShape *)mapkitShape {
    // KMLPoint corresponds to MKPointAnnotation
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = point;
    return annotation;
}

// KMLPoint does not override MKOverlayPathRenderer: because there is no such
// thing as an overlay view for a point.  They use MKAnnotationViews which
// are vended by the KMLPlacemark class.

@end
