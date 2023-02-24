//
//  KrispProcessingModule.h
//  KrispAudioProcessor
//
//  Created by Arthur Hayrapetyan on 26.01.23.
//  Copyright © 2023 Krisp Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "krisp-audio-sdk.hpp"
#include <string>

inline std::wstring convertMBString2WString(const std::string& str)
{
    std::wstring w(str.begin(), str.end());
    return w;
}

class KrispProcessingModule final
{
    KrispAudioSessionID _Nullable m_session;
    std::string m_processorName;
    int m_sampleRateHz;
    int m_numChannels;

    static bool m_isEnableNC;
public:
    KrispProcessingModule (const char* __nullable weight, unsigned int blobSize);
    ~KrispProcessingModule( );
    
    void static enableNC(const bool isEnable);

    void createSession(const int rate);
    void init( );
    void reset( );
    void resetSampleRate(const int newRate);
    void destroy();
    void setName(const std::string& name);
    void initSession(const int sampleRateHz, const int numChannels);
    void frameProcess(const size_t channelNumber, const size_t num_bands, const size_t bufferSize, float * _Nonnull buffer);
};
