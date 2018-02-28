/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 KMLElement and subclasses declared here implement a class hierarchy for storing a KML document structure.  The actual KML file is parsed with a SAX parser and only the relevant document structure is retained in the object graph produced by the parser.  Data parsed is also transformed into appropriate UIKit and MapKit classes as necessary.
 
      Abstract KMLElement type.  Handles storing an element identifier (id="...") as well as a buffer for accumulating character data parsed from the xml. In general, subclasses should have beginElement and endElement classes for keeping track of parsing state.  The parser will call beginElement when an interesting element is encountered, then all character data found in the element will be stored into accum, and then when endElement is called accum will be parsed according to the conventions for that particular element type in order to save the data from the element.  Finally, clearString will be called to reset the character data accumulator.
 */

#import "KMLParser.h"
#import "KMLPolygon.h"
#import "KMLPoint.h"
#import "kml_com.h"

@implementation KMLParser
// After parsing has completed, this method loops over all placemarks that have
// been parsed and looks up their corresponding KMLStyle objects according to
// the placemark's styleUrl property and the global KMLStyle object's identifier.
- (void)assignStyles {
    for (KMLPlacemark *placemark in _placemarks) {
        if (!placemark.style && placemark.styleUrl) {
            NSString *styleUrl = placemark.styleUrl;
            NSRange range = [styleUrl rangeOfString:@"#"];
            if (range.length == 1 && range.location == 0) {
                NSString *styleID = [styleUrl substringFromIndex:1];
                KMLStyle *style = _styles[styleID];
                placemark.style = style;
            }
        }
    }
}

- (instancetype)initWithURL:(NSURL *)url {
    if (self = [super init]) {
        _styles = [[NSMutableDictionary alloc] init];
        _placemarks = [[NSMutableArray alloc] init];
        _xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:url];
        
        [_xmlParser setDelegate:self];
    }
    return self;
}


- (void)parseKML {
    [_xmlParser parse];
    [self assignStyles];
}

// Return the list of KMLPlacemarks from the object graph that contain overlays
// (as opposed to simply point annotations).
- (NSArray *)overlays {
    NSMutableArray *overlays = [[NSMutableArray alloc] init];
    for (KMLPlacemark *placemark in _placemarks) {
        NSArray *overlay = [placemark overlays];
        if (overlay.count)
            [overlays addObjectsFromArray:overlay];
    }
    return overlays;
}

// Return the list of KMLPlacemarks from the object graph that are simply
// MKPointAnnotations and are not MKOverlays.
- (NSArray *)points {
    NSMutableArray *points = [[NSMutableArray alloc] init];
    for (KMLPlacemark *placemark in _placemarks) {
        NSArray *point = [placemark points];
        if (point.count)
            [points addObjectsFromArray:point];
    }
    return points;
}

- (MKAnnotationView *)viewForAnnotation:(id <MKAnnotation>)point {
    // Find the KMLPlacemark object that owns this point and get
    // the view from it.
    for (KMLPlacemark *placemark in _placemarks) {
        for (id placemarkPoint in placemark.points) {
            if (placemarkPoint == point) {
                return [placemark annotationViewForPoint:point];
            }
        }
    }
    return nil;
}

- (MKOverlayRenderer *)rendererForOverlay:(id <MKOverlay>)overlay {
    // Find the KMLPlacemark object that owns this overlay and get
    // the view from it.
    for (KMLPlacemark *placemark in _placemarks) {
        for (id placemarkOverlay in placemark.overlays) {
            if (placemarkOverlay == overlay) {
                return [placemark overlayPathRendererForOverlay:overlay];
            }
        }            
    }
    return nil;
}

#pragma mark NSXMLParserDelegate
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
                                        namespaceURI:(NSString *)namespaceURI
                                       qualifiedName:(NSString *)qName
                                          attributes:(NSDictionary *)attributeDict {
    NSString *ident = attributeDict[@"id"];
    
    KMLStyle *style = [_placemark style] ? [_placemark style] : _style;
    
    // Style and sub-elements
    if (ELTYPE(Style)) {
        if (_placemark) {
            [_placemark beginStyleWithIdentifier:ident];
        } else if (ident != nil) {
            _style = [[KMLStyle alloc] initWithIdentifier:ident];
        }
    } else if (ELTYPE(PolyStyle)) {
        [style beginPolyStyle];
    } else if (ELTYPE(LineStyle)) {
        [style beginLineStyle];
    } else if (ELTYPE(color)) {
        [style beginColor];
    } else if (ELTYPE(width)) {
        [style beginWidth];
    } else if (ELTYPE(fill)) {
        [style beginFill];
    } else if (ELTYPE(outline)) {
        [style beginOutline];
    }
    // Placemark and sub-elements
    else if (ELTYPE(Placemark)) {
        _placemark = [[KMLPlacemark alloc] initWithIdentifier:ident];
    } else if (ELTYPE(Name)) {
        [_placemark beginName];
    } else if (ELTYPE(Description)) {
        [_placemark beginDescription];
    } else if (ELTYPE(styleUrl)) {
        [_placemark beginStyleUrl];
    } else if (ELTYPE(Polygon) || ELTYPE(Point) || ELTYPE(LineString)) {
        [_placemark beginGeometryOfType:elementName withIdentifier:ident];
    }
    // Geometry sub-elements
    else if (ELTYPE(coordinates)) {
        [_placemark.geometry.lastObject beginCoordinates];
    } 
    // Polygon sub-elements
    else if (ELTYPE(outerBoundaryIs)) {
        [(KMLPolygon *)_placemark.geometry.lastObject beginOuterBoundary];
    } else if (ELTYPE(innerBoundaryIs)) {
        [(KMLPolygon *)_placemark.geometry.lastObject beginInnerBoundary];
    } else if (ELTYPE(LinearRing)) {
        [(KMLPolygon *)_placemark.geometry.lastObject beginLinearRing];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
                                      namespaceURI:(NSString *)namespaceURI
                                     qualifiedName:(NSString *)qName {
    KMLStyle *style = [_placemark style] ? [_placemark style] : _style;
    
    // Style and sub-elements
    if (ELTYPE(Style)) {
        if (_placemark) {
            [_placemark endStyle];
        } else if (_style) {
            _styles[_style.identifier] = _style;
            _style = nil;
        }
    } else if (ELTYPE(PolyStyle)) {
        [style endPolyStyle];
    } else if (ELTYPE(LineStyle)) {
        [style endLineStyle];
    } else if (ELTYPE(color)) {
        [style endColor];
    } else if (ELTYPE(width)) {
        [style endWidth];
    } else if (ELTYPE(fill)) {
        [style endFill];
    } else if (ELTYPE(outline)) {
        [style endOutline];
    }
    // Placemark and sub-elements
    else if (ELTYPE(Placemark)) {
        if (_placemark) {
            [_placemarks addObject:_placemark];
            _placemark = nil;
        }
    } else if (ELTYPE(Name)) {
        [_placemark endName];
    } else if (ELTYPE(Description)) {
        [_placemark endDescription];
    } else if (ELTYPE(styleUrl)) {
        [_placemark endStyleUrl];
    } else if (ELTYPE(Polygon) || ELTYPE(Point) || ELTYPE(LineString)) {
        [_placemark endGeometry];
    }
    // Geometry sub-elements
    else if (ELTYPE(coordinates)) {
        [_placemark.geometry.lastObject endCoordinates];
    } 
    // Polygon sub-elements
    else if (ELTYPE(outerBoundaryIs)) {
        [(KMLPolygon *)_placemark.geometry.lastObject endOuterBoundary];
    } else if (ELTYPE(innerBoundaryIs)) {
        [(KMLPolygon *)_placemark.geometry.lastObject endInnerBoundary];
    } else if (ELTYPE(LinearRing)) {
        [(KMLPolygon *)_placemark.geometry.lastObject endLinearRing];
    }
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    KMLElement *element = _placemark ? (KMLElement *)_placemark : (KMLElement *)_style;
    [element addString:string];
}

@end


