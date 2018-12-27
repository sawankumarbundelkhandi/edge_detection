#import "EdgeDetectionPlugin.h"
#import <edge_detection/edge_detection-Swift.h>

@implementation EdgeDetectionPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftEdgeDetectionPlugin registerWithRegistrar:registrar];
}
@end
