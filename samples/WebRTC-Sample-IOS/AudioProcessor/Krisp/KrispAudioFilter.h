#ifndef KrispAudioFilter_h
#define KrispAudioFilter_h


#include <string>

#include "AudioFilterInterface.h"
#include "KrispAudioSDK/krisp-audio-sdk.hpp"


inline std::wstring convertMBString2WString(const std::string& str)
{
    std::wstring w(str.begin(), str.end());
    return w;
}


class KrispAudioFilter final : public AudioFilterInterface
{
private:
    KrispAudioSessionID _Nullable m_session;
    std::string m_modelPath;
    int m_sampleRateHz;
    int m_numChannels;
    bool m_isEnableNC;
public:
    KrispAudioFilter(const char* __nullable weight, unsigned int blobSize);
    ~KrispAudioFilter();
    
    void enable(const bool isEnable);
    void createSession(const int rate);
    void init( );
    void reset( );
    void resetSampleRate(const int newRate);
    void destroy();
    void initSession(const int sampleRateHz, const int numChannels);
    void frameProcess(const size_t channelNumber, const size_t num_bands, const size_t bufferSize, float * _Nonnull buffer);
    void modifyAudioStream(std::vector<float>& buffer, float gain);
};


#endif
