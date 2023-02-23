//
//  KrispAudioProcessor.mm
//  KrispAudioProcessor
//
//  Created by Arthur Hayrapetyan on 26.01.23.
//  Copyright © 2023 Krisp Technologies. All rights reserved.
//

#import "KrispAudioProcessor.h"
#import <WebRTC/RTCProcessingController.h>
#import <WebRTC/RTCAudioProcessing.h>
#import "KrispProcessingModule.h"

@interface KrispAudioProcessor() <RTCAudioProcessorDelegate>

@end

@implementation KrispAudioProcessor

std::unique_ptr<KrispProcessingModule> _processingModule;
RTCProcessingController* _processingController;

- (instancetype)initWithParams:(NSString*)weightFile size:(unsigned int)size {
    
    self = [super init];
    if (self != nil) {
        [self initProcessor: weightFile size: size];
    }
    return self;
}

- (void)initProcessor:(NSString*)weightFile size:(unsigned int)size {

    _processingModule = std::make_unique<KrispProcessingModule>([weightFile UTF8String], size);
    _processingController = [[RTCProcessingController alloc] initWithDelegate: self];
}

- (void)initializeProcessor {
    _processingModule->init();
}

- (void)initializeSession:(size_t)sampleRate numChannels:(size_t)numChannels
{
    _processingModule->initSession(sampleRate, numChannels);
}

- (void)name {
    _processingModule->setName("KrispCitProcessor");
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
