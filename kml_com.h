//
//  kml_com.h
//  KMLViewer
//
//  Created by Mojtaba Cazi on 2/27/18.
//

#ifndef kml_com_h
#define kml_com_h

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#define ELTYPE(typeName) (NSOrderedSame == [elementName caseInsensitiveCompare:@#typeName])

void strToCoords(NSString *str, CLLocationCoordinate2D **coordsOut, NSUInteger *coordsLenOut);

#endif /* kml_com_h */
