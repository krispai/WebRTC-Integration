#import <Foundation/Foundation.h>
#include <string>

class SampleAudioFilter final
{
    int m_sampleRateHz;
    int m_numChannels;
    bool m_enable;
public:
    SampleAudioFilter ();
    ~SampleAudioFilter();
    
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
