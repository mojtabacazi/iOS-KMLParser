//
//  KMLGeometry.m
//  KMLViewer
//
//  Created by Mojtaba Cazi on 2/27/18.
//

#import "KMLGeometry.h"

@implementation KMLGeometry

- (BOOL)canAddString {
    return flags.inCoords;
}

- (void)beginCoordinates {
    flags.inCoords = YES;
}

- (void)endCoordinates {
    flags.inCoords = NO;
}

- (MKShape *)mapkitShape {
    return nil;
}

- (MKOverlayPathRenderer *)createOverlayPathRenderer:(MKShape *)shape {
    return nil;
}

@end
