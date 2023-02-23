//
//  KrispProcessingModule.m
//  KrispAudioProcessor
//
//  Created by Arthur Hayrapetyan on 26.01.23.
//  Copyright © 2023 Krisp Technologies. All rights reserved.
//

#import "KrispProcessingModule.h"
#include <vector>

constexpr size_t kNsFrameSize = 160;
static bool krisp_ready_ = false;

static KrispAudioFrameDuration GetFrameDuration(size_t duration)
{
    switch (duration) {
        case 10:
            return KRISP_AUDIO_FRAME_DURATION_10MS;
        case 15:
            return KRISP_AUDIO_FRAME_DURATION_15MS;
        case 20:
            return KRISP_AUDIO_FRAME_DURATION_20MS;
        case 30:
            return KRISP_AUDIO_FRAME_DURATION_30MS;
        case 32:
            return KRISP_AUDIO_FRAME_DURATION_32MS;
        case 40:
            return KRISP_AUDIO_FRAME_DURATION_40MS;
        default:
            NSLog(@"Frame duration is not supported. Switching to default 10ms.");
            return KRISP_AUDIO_FRAME_DURATION_10MS;
    }
}

static KrispAudioSamplingRate GetSampleRate(size_t rate)
{
    switch (rate) {
        case 8000:
            return KRISP_AUDIO_SAMPLING_RATE_8000HZ;
        case 12000:
            return KRISP_AUDIO_SAMPLING_RATE_12000HZ;
        case 16000:
            return KRISP_AUDIO_SAMPLING_RATE_16000HZ;
        case 24000:
            return KRISP_AUDIO_SAMPLING_RATE_24000HZ;
        case 32000:
            return KRISP_AUDIO_SAMPLING_RATE_32000HZ;
        case 44100:
            return KRISP_AUDIO_SAMPLING_RATE_44100HZ;
        case 48000:
            return KRISP_AUDIO_SAMPLING_RATE_48000HZ;
        case 88200:
            return KRISP_AUDIO_SAMPLING_RATE_88200HZ;
        case 96000:
            return KRISP_AUDIO_SAMPLING_RATE_96000HZ;
        default:
            NSLog(@"The input sampling rate is not supported. Using default 48khz.");
            return KRISP_AUDIO_SAMPLING_RATE_48000HZ;
    }
}

KrispProcessingModule::KrispProcessingModule(const char* __nullable weight, unsigned int blobSize)
    : m_session(nullptr),
      m_ProcessorName(weight),
      m_SampleRatehz(48000),
      m_Numchannels(1),
      m_IsAppleNC(true)
{
}

KrispProcessingModule::~KrispProcessingModule()
{
    krispAudioNcCloseSession(m_session);
    krispAudioGlobalDestroy();
    krisp_ready_ = false;
}

void KrispProcessingModule::init( )
{
    if (krispAudioGlobalInit(nullptr, 0)) {
        NSLog(@"KrispProcessingModule: Failed to initialize Krisp globals");
        return;
    }

    if (krispAudioSetModel(convertMBString2WString(m_ProcessorName.c_str()).c_str(), "default") != 0) {
        NSLog(@"KrispProcessingModule: Krisp failed to set wt file, weight = %s", m_ProcessorName.c_str());
        return;
    }
    krisp_ready_ = true;
}

void KrispProcessingModule::reset( ) {
    krispAudioNcCloseSession(m_session);
}

void KrispProcessingModule::Reset(int new_rate)
{
    krispAudioNcCloseSession(m_session);
    createSession(new_rate);
    m_SampleRatehz = new_rate;
}

void KrispProcessingModule::EnableNC(const bool isEnable)
{
    m_IsAppleNC = isEnable;
}

void KrispProcessingModule::createSession(int rate) {
    auto krisp_rate = GetSampleRate(rate);
    auto krisp_duration = GetFrameDuration(10);
    m_session = krispAudioNcCreateSession(krisp_rate, krisp_rate,
          krisp_duration, "default");
}

void KrispProcessingModule::destroy() {
    krispAudioNcCloseSession(m_session);
    krispAudioGlobalDestroy();
    krisp_ready_ = false;
}

void KrispProcessingModule::initSession(int sample_rate_hz, int num_channels)
{
    if (m_session == nullptr) {
        createSession(sample_rate_hz);
        m_SampleRatehz = sample_rate_hz;
    } else {
        if (sample_rate_hz != m_SampleRatehz) {
            m_SampleRatehz = sample_rate_hz;
            Reset(m_SampleRatehz);
        }
    }
    m_Numchannels = num_channels;
}

void KrispProcessingModule::setName(const std::string& name) {
    
}

void KrispProcessingModule::frameProcess(const size_t channelNumber, const size_t num_bands, const size_t bufferSize, float * _Nonnull  buffer) {

    if (!m_IsAppleNC) {
        return;
    }
    
    if (m_session == nullptr) {
      NSLog(@"KrispProcessingModule: Session creation failed ");
      return;
    }

    int num_frames = (int)bufferSize;
    int rate = num_frames*100;

    if(rate != m_SampleRatehz) {
        Reset(rate);
    }

    std::vector<float> bufferIn;
    std::vector<float> bufferOut;
    bufferIn.resize(num_frames);
    bufferOut.resize(num_frames);

    for (int index = 0; index < num_frames; ++index) {
        bufferIn[index] = buffer[index] / 32768.f;
    }

    const auto retValue = krispAudioNcCleanAmbientNoiseFloat(m_session, bufferIn.data(), num_frames, bufferOut.data(),num_frames);

    if (retValue != 0) {
        NSLog(@"KrispProcessingModule: Krisp noise cleanup error");
        return;
    }

    for (int index = 0; index < num_frames; ++index) {
        buffer[index] = bufferOut[index] * 32768.f;
    }
}

