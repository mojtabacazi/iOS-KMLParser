# iOS-KMLParser
KMLParser for Apple MapKit.

Based on [Apple's KMLViewer](https://developer.apple.com/library/content/samplecode/KMLViewer/Introduction/Intro.html#//apple_ref/doc/uid/DTS40010046-Intro-DontLinkElementID_2) sample code with partial support for Multigeometry.

Sample Usage:

```obj-c
@interface KMLViewerViewController ()

@property (nonatomic, weak) IBOutlet MKMapView *map;
@property (nonatomic, strong) KMLParser *kmlParser;

@end

@implementation KMLViewerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Locate the path to the route.kml file in the application's bundle
    // and parse it with the KMLParser.
    NSString *path = [[NSBundle mainBundle] pathForResource:@"doc" ofType:@"kml"];
    NSURL *url = [NSURL fileURLWithPath:path];
    self.kmlParser = [[KMLParser alloc] initWithURL:url];
    [self.kmlParser parseKML];
    
    // Add all of the MKOverlay objects parsed from the KML file to the map.
    NSArray *overlays = [self.kmlParser overlays];
    NSLog(@"lat %f", [(id<MKOverlay>)overlays[0] coordinate].latitude);
    NSLog(@"lon %f", [(id<MKOverlay>)overlays[0] coordinate].longitude);
    [self.map addOverlays:overlays];
    
    // Add all of the MKAnnotation objects parsed from the KML file to the map.
    NSArray *annotations = [self.kmlParser points];
    [self.map addAnnotations:annotations];
    
    // Walk the list of overlays and annotations and create a MKMapRect that
    // bounds all of them and store it into flyTo.
    MKMapRect flyTo = MKMapRectNull;
    for (id <MKOverlay> overlay in overlays) {
        if (MKMapRectIsNull(flyTo)) {
            flyTo = [overlay boundingMapRect];
        } else {
            flyTo = MKMapRectUnion(flyTo, [overlay boundingMapRect]);
        }
    }
    
    for (id <MKAnnotation> annotation in annotations) {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
        if (MKMapRectIsNull(flyTo)) {
            flyTo = pointRect;
        } else {
            flyTo = MKMapRectUnion(flyTo, pointRect);
        }
    }
    
    // Position the map so that all overlays and annotations are visible on screen.
    self.map.visibleMapRect = flyTo;
}

#pragma mark MKMapViewDelegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    return [self.kmlParser rendererForOverlay:overlay];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    return [self.kmlParser viewForAnnotation:annotation];
}
```
