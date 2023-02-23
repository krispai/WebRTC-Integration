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
    std::string m_ProcessorName;
    KrispAudioSessionID _Nullable m_session;
    
    int m_SampleRatehz;
    int m_Numchannels;
    bool m_IsAppleNC;
public:
    KrispProcessingModule (const char* __nullable weight, unsigned int blobSize);
    ~KrispProcessingModule( );

    void createSession(const int rate);
    void Reset(const int new_rate);
    void EnableNC(const bool isEnable);
    
    void init( );
    void reset( );
    void destroy();
    void setName(const std::string& name);
    void initSession(int sample_rate_hz, int num_channels);
    void frameProcess(const size_t channelNumber, const size_t num_bands, const size_t bufferSize, float * _Nonnull buffer);
};
