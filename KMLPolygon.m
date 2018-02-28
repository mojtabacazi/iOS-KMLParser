//
//  KMLPolygon.m
//  KMLViewer
//
//  Created by Mojtaba Cazi on 2/27/18.
//

#import "KMLPolygon.h"
#import "kml_com.h"

@implementation KMLPolygon

- (BOOL)canAddString {
    return polyFlags.inLinearRing && flags.inCoords;
}

- (void)beginOuterBoundary {
    polyFlags.inOuterBoundary = YES;
}

- (void)endOuterBoundary {
    polyFlags.inOuterBoundary = NO;
    outerRing = [accum copy];
    [self clearString];
}

- (void)beginInnerBoundary {
    polyFlags.inInnerBoundary = YES;
}

- (void)endInnerBoundary {
    polyFlags.inInnerBoundary = NO;
    NSString *ring = [accum copy];
    if (!innerRings) {
        innerRings = [[NSMutableArray alloc] init];
    }
    [innerRings addObject:ring];
    [self clearString];
}

- (void)beginLinearRing {
    polyFlags.inLinearRing = YES;
}

- (void)endLinearRing {
    polyFlags.inLinearRing = NO;
}

- (MKShape *)mapkitShape {
    // KMLPolygon corresponds to MKPolygon
    
    // The inner and outer rings of the polygon are stored as kml coordinate
    // list strings until we're asked for mapkitShape.  Only once we're here
    // do we lazily transform them into CLLocationCoordinate2D arrays.
    
    // First build up a list of MKPolygon cutouts for the interior rings.
    NSMutableArray *innerPolys = nil;
    if (innerRings) {
        innerPolys = [[NSMutableArray alloc] initWithCapacity:[innerPolys count]];
        for (NSString *coordStr in innerRings) {
            CLLocationCoordinate2D *coords = NULL;
            NSUInteger coordsLen = 0;
            strToCoords(coordStr, &coords, &coordsLen);
            [innerPolys addObject:[MKPolygon polygonWithCoordinates:coords count:coordsLen]];
            free(coords);
        }
    }
    // Now parse the outer ring.
    CLLocationCoordinate2D *coords = NULL;
    NSUInteger coordsLen = 0;
    strToCoords(outerRing, &coords, &coordsLen);
    
    // Build a polygon using both the outer coordinates and the list (if applicable)
    // of interior polygons parsed.
    MKPolygon *poly = [MKPolygon polygonWithCoordinates:coords count:coordsLen interiorPolygons:innerPolys];
    free(coords);
    return poly;
}

- (MKOverlayPathRenderer *)createOverlayPathRenderer:(MKShape *)shape {
    MKPolygonRenderer *polyPath = [[MKPolygonRenderer alloc] initWithPolygon:(MKPolygon *)shape];
    return polyPath;
}

@end
