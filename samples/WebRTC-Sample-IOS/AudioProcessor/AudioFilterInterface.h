#ifndef AudioFilterInterface_h
#define AudioFilterInterface_h

#include <vector>


class AudioFilterInterface
{
public:
    virtual ~AudioFilterInterface() = default;
    
    virtual void enable(const bool isEnable) = 0;
    virtual void createSession(const int rate) = 0;
    virtual void init() = 0;
    virtual void reset() = 0;
    virtual void resetSampleRate(const int newRate) = 0;
    virtual void destroy() = 0;
    virtual void initSession(const int sampleRateHz, const int numChannels) = 0;
    virtual void frameProcess(const size_t channelNumber, const size_t num_bands, const size_t bufferSize, float * _Nonnull buffer) = 0;
    virtual void modifyAudioStream(std::vector<float>& buffer, float gain) = 0;
};

#endif
