#import "EdgeDetectionPlugin.h"
#if __has_include(<edge_detection/edge_detection-Swift.h>)
#import <edge_detection/edge_detection-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "edge_detection-Swift.h"
#endif

@implementation EdgeDetectionPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftEdgeDetectionPlugin registerWithRegistrar:registrar];
}
@end
