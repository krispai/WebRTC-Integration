#import "SampleAudioFilter.h"

#include <vector>
#include <cmath>


SampleAudioFilter::SampleAudioFilter() : m_sampleRateHz(48000), m_numChannels(1), m_enable(false)
{
   
}

SampleAudioFilter::~SampleAudioFilter()
{
    
}

void SampleAudioFilter::init( )
{
    NSLog(@"ProcessingModule: init");
}

void SampleAudioFilter::reset( ) {
    NSLog(@"ProcessingModule: reset");
}

void SampleAudioFilter::resetSampleRate(int newRate)
{
    createSession(newRate);
    m_sampleRateHz = newRate;
}

void SampleAudioFilter::enable(const bool isEnable)
{
    m_enable = isEnable;
}

void SampleAudioFilter::createSession(int rate) {
    NSLog(@"ProcessingModule: createSession");
}

void SampleAudioFilter::destroy() {
    NSLog(@"ProcessingModule: destroy");
}

void SampleAudioFilter::initSession(const int sampleRateHz, const int numChannels)
{
    m_sampleRateHz = sampleRateHz;
    m_numChannels = numChannels;
}

void SampleAudioFilter::frameProcess(const size_t channelNumber, const size_t num_bands, const size_t bufferSize, float * _Nonnull  buffer) {
    
    if (!m_enable) {
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

void SampleAudioFilter::modifyAudioStream(std::vector<float>& buffer, float gain) {
    const double PI = 3.14159265358979323846;
    for (int index = 0; index < buffer.size(); index++) {
        float t = (float)index / 48000.0;
        float data = sin(2.0 * PI * 200.0 * t);
        data *= pow(10, gain / 20);
        buffer[index] = data;
    }
}

