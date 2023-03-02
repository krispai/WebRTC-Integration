//
//  ProcessingModule.h
//  AudioProcessor
//
//  Created by Arthur Hayrapetyan on 26.01.23.
//  Copyright © 2023 Krisp Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <string>

class ProcessingModule final
{
    int m_sampleRateHz;
    int m_numChannels;

    static bool m_isEnableAudioFilter;
public:
    ProcessingModule ();
    ~ProcessingModule();
    
    void static enableNC(const bool isEnable);

    void createSession(const int rate);
    void init( );
    void reset( );
    void resetSampleRate(const int newRate);
    void destroy();
    void setName(const std::string& name);
    void initSession(const int sampleRateHz, const int numChannels);
    void frameProcess(const size_t channelNumber, const size_t num_bands, const size_t bufferSize, float * _Nonnull buffer);
    void modifyAudioStream(std::vector<float>& buffer, float gain);
};
