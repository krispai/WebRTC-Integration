//
//  ProcessingModule.m
//  AudioProcessor
//
//  Created by Arthur Hayrapetyan on 26.01.23.
//  Copyright © 2023 Krisp Technologies. All rights reserved.
//

#import "ProcessingModule.h"
#include <vector>
#include <cmath>

const double PI = 3.14159265358979323846;

bool ProcessingModule::m_isEnableAudioFilter = true;

ProcessingModule::ProcessingModule()
   : m_sampleRateHz(48000),
     m_numChannels(1)
{
   
}

ProcessingModule::~ProcessingModule()
{
    
}

void ProcessingModule::init( )
{
    NSLog(@"ProcessingModule: init");
}

void ProcessingModule::reset( ) {
    NSLog(@"ProcessingModule: reset");
}

void ProcessingModule::resetSampleRate(int newRate)
{
    createSession(newRate);
    m_sampleRateHz = newRate;
}

void ProcessingModule::enableNC(const bool isEnable)
{
    m_isEnableAudioFilter = isEnable;
}

void ProcessingModule::createSession(int rate) {
    NSLog(@"ProcessingModule: createSession");
}

void ProcessingModule::destroy() {
    NSLog(@"ProcessingModule: destroy");
}

void ProcessingModule::initSession(const int sampleRateHz, const int numChannels)
{
    m_sampleRateHz = sampleRateHz;
    m_numChannels = numChannels;
}

void ProcessingModule::setName(const std::string& name) {
    
}

void ProcessingModule::frameProcess(const size_t channelNumber, const size_t num_bands, const size_t bufferSize, float * _Nonnull  buffer) {
    
    if (!m_isEnableAudioFilter) {
        return;
    }

    int num_frames = (int)bufferSize;
    int rate = num_frames*100;

    if(rate != m_sampleRateHz) {
        resetSampleRate(rate);
    }

    std::vector<float> bufferIn;
    bufferIn.resize(num_frames);
    
    for (int index = 0; index < num_frames; ++index) {
        bufferIn[index] = buffer[index] / 32768.f;
    }

    modifyAudioStream(bufferIn, 2.0);
    
    for (int index = 0; index < num_frames; ++index) {
        buffer[index] = bufferIn[index] * 32768.f;
    }
}

void ProcessingModule::modifyAudioStream(std::vector<float>& buffer, float gain) {
    
    for (int index = 0; index < buffer.size(); index++) {
        float t = (float)index / 48000.0;
        float data = sin(2.0 * PI * 200.0 * t);
        data *= pow(10, gain / 20);
        buffer[index] = data;
    }
}

