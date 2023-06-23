// Autogenerated from Pigeon (v10.0.1), do not edit directly.
// See also: https://pub.dev/packages/pigeon

#import "pigeon.h"
#import <Flutter/Flutter.h>

#if !__has_feature(objc_arc)
#error File requires ARC to be enabled.
#endif

static NSArray *wrapResult(id result, FlutterError *error) {
  if (error) {
    return @[
      error.code ?: [NSNull null], error.message ?: [NSNull null], error.details ?: [NSNull null]
    ];
  }
  return @[ result ?: [NSNull null] ];
}
static id GetNullableObjectAtIndex(NSArray *array, NSInteger key) {
  id result = array[key];
  return (result == [NSNull null]) ? nil : result;
}

NSObject<FlutterMessageCodec> *ProcessSpecApiGetCodec(void) {
  static FlutterStandardMessageCodec *sSharedObject = nil;
  sSharedObject = [FlutterStandardMessageCodec sharedInstance];
  return sSharedObject;
}

void ProcessSpecApiSetup(id<FlutterBinaryMessenger> binaryMessenger, NSObject<ProcessSpecApi> *api) {
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:@"dev.flutter.pigeon.ProcessSpecApi.getUISchema"
        binaryMessenger:binaryMessenger
        codec:ProcessSpecApiGetCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(getUISchemaWithCompletion:)], @"ProcessSpecApi api (%@) doesn't respond to @selector(getUISchemaWithCompletion:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        [api getUISchemaWithCompletion:^(NSString *_Nullable output, FlutterError *_Nullable error) {
          callback(wrapResult(output, error));
        }];
      }];
    } else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:@"dev.flutter.pigeon.ProcessSpecApi.getStringValueGlobalParam"
        binaryMessenger:binaryMessenger
        codec:ProcessSpecApiGetCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(getStringValueGlobalParamKey:completion:)], @"ProcessSpecApi api (%@) doesn't respond to @selector(getStringValueGlobalParamKey:completion:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        NSArray *args = message;
        NSString *arg_key = GetNullableObjectAtIndex(args, 0);
        [api getStringValueGlobalParamKey:arg_key completion:^(NSString *_Nullable output, FlutterError *_Nullable error) {
          callback(wrapResult(output, error));
        }];
      }];
    } else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:@"dev.flutter.pigeon.ProcessSpecApi.getNewProcessSpec"
        binaryMessenger:binaryMessenger
        codec:ProcessSpecApiGetCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(getNewProcessSpecWithCompletion:)], @"ProcessSpecApi api (%@) doesn't respond to @selector(getNewProcessSpecWithCompletion:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        [api getNewProcessSpecWithCompletion:^(NSArray<NSString *> *_Nullable output, FlutterError *_Nullable error) {
          callback(wrapResult(output, error));
        }];
      }];
    } else {
      [channel setMessageHandler:nil];
    }
  }
}
