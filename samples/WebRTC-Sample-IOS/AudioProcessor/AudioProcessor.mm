#import "AudioProcessor.h"
#import <WebRTC/RTCProcessingController.h>
#import <WebRTC/RTCAudioProcessing.h>
#import "SampleAudioFilter.h"
#import "Krisp/KrispAudioFilter.h"

@interface AudioProcessor() <RTCAudioProcessorDelegate> {
    std::unique_ptr<SampleAudioFilter> _audioFilter;
    RTCProcessingController* _processingController;
}
@end

@implementation AudioProcessor

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        _processingController = [[RTCProcessingController alloc] initWithDelegate: self];
    }
    return self;
}

- (void)attachSampleAudioFilter {
    _audioFilter = std::make_unique<SampleAudioFilter>();
}

- (void)attachKrispAudioFilter:(NSString *)weightFile size:(unsigned int)size {
    //const char * weightFileCString = [weightFile UTF8String];
    //_audioFilter = std::make_unique<KrispAudioFilter>(weightFileCString, size);
}

- (void)enableAudioFilter:(BOOL)enable
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
