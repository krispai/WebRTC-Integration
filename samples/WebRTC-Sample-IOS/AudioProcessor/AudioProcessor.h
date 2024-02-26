#import <Foundation/Foundation.h>

@interface AudioProcessor : NSObject

- (instancetype)init;
+ (void)enableAudioFilter:(BOOL)enable;

@end
