//
//  KMLLineString.m
//  KMLViewer
//
//  Created by Mojtaba Cazi on 2/27/18.
//

#import "KMLLineString.h"
#import "kml_com.h"

@implementation KMLLineString

@synthesize points, length;

- (void)endCoordinates {
    flags.inCoords = NO;
    
    if (points) {
        free(points);
    }
    
    strToCoords(accum, &points, &length);
    
    [self clearString];
}

- (MKShape *)mapkitShape {
    // KMLLineString corresponds to MKPolyline
    return [MKPolyline polylineWithCoordinates:points count:length];
}

- (MKOverlayPathRenderer *)createOverlayPathRenderer:(MKShape *)shape {
    MKPolylineRenderer *polyLine = [[MKPolylineRenderer alloc] initWithPolyline:(MKPolyline *)shape];
    return polyLine;
}

@end
