#import <Foundation/Foundation.h>

@interface AudioProcessor : NSObject

- (instancetype)init;
- (void)attachKrispAudioFilter:(NSString*)weightFile size:(unsigned int)size;
- (void)attachSampleAudioFilter;
- (void)enableAudioFilter:(BOOL)enable;

@end
