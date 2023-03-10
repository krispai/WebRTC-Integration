//
//  AudioProcessor.mm
//  AudioProcessor
//
//  Created by Arthur Hayrapetyan on 26.01.23.
//  Copyright © 2023 Krisp Technologies. All rights reserved.
//

#import "AudioProcessor.h"
#import <WebRTC/RTCProcessingController.h>
#import <WebRTC/RTCAudioProcessing.h>
#import "ProcessingModule.h"

@interface AudioProcessor() <RTCAudioProcessorDelegate>

@end

@implementation AudioProcessor

std::unique_ptr<ProcessingModule> _processingModule;
RTCProcessingController* _processingController;

- (instancetype)init {
    
    self = [super init];
    if (self != nil) {
        [self initProcessor];
    }
    return self;
}

- (void)initProcessor {

    _processingModule = std::make_unique<ProcessingModule>();
    _processingController = [[RTCProcessingController alloc] initWithDelegate: self];
}

+ (void)enableAudioFilter:(BOOL)enable
{
    _processingModule->enableNC(enable);
}

- (void)initializeProcessor {
    _processingModule->init();
}

- (void)initializeSession:(size_t)sampleRate numChannels:(size_t)numChannels
{
    _processingModule->initSession(sampleRate, (int)numChannels);
}

- (void)name {
    _processingModule->setName("AudioCitProcessor");
}

- (void)frameProcess:(size_t)channelNumber numBands:(size_t)numBands bufferSize:(size_t)bufferSize buffer:(float * _Nonnull)buffer {
    _processingModule->frameProcess(channelNumber, numBands, bufferSize, buffer);
}

- (void)destroyed {
    _processingModule->destroy();
}

- (void)reset {
    _processingModule->reset();
}

- (RTCAudioProcessing*)getProcessingModule {
    return [_processingController getProcessor];
}

@end
