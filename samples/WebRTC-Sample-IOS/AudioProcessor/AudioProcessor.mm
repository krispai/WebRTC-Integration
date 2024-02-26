#import "AudioProcessor.h"
#import <WebRTC/RTCProcessingController.h>
#import <WebRTC/RTCAudioProcessing.h>
#import "SampleAudioFilter.h"

@interface AudioProcessor() <RTCAudioProcessorDelegate>

@end

@implementation AudioProcessor

std::unique_ptr<SampleAudioFilter> _audioFilter;
RTCProcessingController* _processingController;

- (instancetype)init {
    
    self = [super init];
    if (self != nil) {
        [self initProcessor];
    }
    return self;
}

- (void)initProcessor {

    _audioFilter = std::make_unique<SampleAudioFilter>();
    _processingController = [[RTCProcessingController alloc] initWithDelegate: self];
}

+ (void)enableAudioFilter:(BOOL)enable
{
    _audioFilter->enable(enable);
}

- (void)initializeProcessor {
    _audioFilter->init();
}

- (void)initializeSession:(size_t)sampleRate numChannels:(size_t)numChannels
{
    _audioFilter->initSession((int)sampleRate, (int)numChannels);
}

- (void)name {
}

- (void)frameProcess:(size_t)channelNumber numBands:(size_t)numBands bufferSize:(size_t)bufferSize buffer:(float * _Nonnull)buffer {
    _audioFilter->frameProcess(channelNumber, numBands, bufferSize, buffer);
}

- (void)destroyed {
    _audioFilter->destroy();
}

- (void)reset {
    _audioFilter->reset();
}

- (RTCAudioProcessing*)getProcessingModule {
    return [_processingController getProcessor];
}

@end
