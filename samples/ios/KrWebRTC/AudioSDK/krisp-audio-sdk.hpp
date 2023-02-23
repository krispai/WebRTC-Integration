///
/// Copyright Krisp, Inc
///

#ifndef KRISP_SPEECH_ENHANCEMENT_H_
#define KRISP_SPEECH_ENHANCEMENT_H_

#if defined _WIN32 || defined __CYGWIN__
    #ifdef KRISP_AUDIO_STATIC
        #define KRISP_AUDIO_API 
    #else
        #ifdef KRISP_AUDIO_EXPORTS
            #ifdef __GNUC__
                #define KRISP_AUDIO_API __attribute__ ((dllexport))
            #else
                #define KRISP_AUDIO_API __declspec(dllexport) // Note: actually gcc seems to also supports this syntax.
            #endif
        #else
            #ifdef __GNUC__
                #define KRISP_AUDIO_API __attribute__ ((dllimport))
            #else
                #define KRISP_AUDIO_API __declspec(dllimport) // Note: actually gcc seems to also supports this syntax.
            #endif
        #endif
    #endif
#else
    #if __GNUC__ >= 4
        #define KRISP_AUDIO_API __attribute__ ((visibility ("default")))
    #else
        #define KRISP_AUDIO_API
    #endif
#endif

typedef void*  KrispAudioSessionID;

typedef enum {
    KRISP_AUDIO_SAMPLING_RATE_8000HZ=8000,
    KRISP_AUDIO_SAMPLING_RATE_12000HZ=12000,
    KRISP_AUDIO_SAMPLING_RATE_16000HZ=16000,
    KRISP_AUDIO_SAMPLING_RATE_24000HZ=24000,
    KRISP_AUDIO_SAMPLING_RATE_32000HZ=32000,
    KRISP_AUDIO_SAMPLING_RATE_44100HZ=44100,
    KRISP_AUDIO_SAMPLING_RATE_48000HZ=48000,
    KRISP_AUDIO_SAMPLING_RATE_88200HZ=88200,
    KRISP_AUDIO_SAMPLING_RATE_96000HZ=96000
} KrispAudioSamplingRate;

typedef enum {
    KRISP_AUDIO_FRAME_DURATION_10MS=10,
    KRISP_AUDIO_FRAME_DURATION_15MS=15,
    KRISP_AUDIO_FRAME_DURATION_20MS=20,
    KRISP_AUDIO_FRAME_DURATION_30MS=30,
    KRISP_AUDIO_FRAME_DURATION_32MS=32,
    KRISP_AUDIO_FRAME_DURATION_40MS=40
} KrispAudioFrameDuration;

typedef struct krispAudioVersionInfo_t {
    unsigned short major;
    unsigned short minor;
    unsigned short patch;
    unsigned short build;
} KrispAudioVersionInfo;

/* Krisp Audio bandwidth values */
typedef enum {
    BAND_WIDTH_UNKNOWN   = 0,
    BAND_WIDTH_4000HZ    = 1,
    BAND_WIDTH_8000HZ    = 2,
    BAND_WIDTH_16000HZ   = 3,
} KrispAudioBandWidth;

/* Krisp Audio real bandwidth info struct used by krispAudioVadFrameInt16Ex() and
   krispAudioVadFrameFloatEx() APIs */
typedef struct KrispAudioBandWidthInfo_t {
    /* [out] Predicted real bandwidth, one of the @KrispAudioBandWidth values */
    KrispAudioBandWidth     realBandwidth;
    /* [in] Algorithm processing start point */
    int                     procStartDelayMs;
    /* [in] Algorithm processing duration counted from the procStartDelayMs */
    int                     procDurationMs;
    int                     reserved;
} KrispAudioBandWidthInfo;


#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

/*!
 * @brief This function initializes the global data needed for the SDK
 * @param[in] workingPath The path to the working directory. Can be nullptr to have the default behavior.
 * @param[in] numThreads The number of threads that the SDK is allowed to use. Mainly used for initializing the underlying mathematical libraries such as MKL or OpenBLAS.
 *              If <b> numThread </b> is 0 then default value will be used.
 * @retval 0  Success 
 * @retval -1 Error
*/
KRISP_AUDIO_API int krispAudioGlobalInit(const wchar_t* workingPath, int numThreads);


/*!
 * @brief This function frees all global resources allocated by SDK. The session's data will also be freed and can't be used in future.
 * @retval 0  Success 
 * @retval -1 Error
 */
KRISP_AUDIO_API int krispAudioGlobalDestroy();

KRISP_AUDIO_API int krispAudioGetVersion(KrispAudioVersionInfo& info);


/*!
 * @brief This function sets the Krisp model to be used. The model weights file provided must exist. Several models can be set. 
 * The model specified model is later tied to specific session during the session creation process.
 * @param[in] weightConfFilePath The Krisp model weight file associated with the model
 * @param[in] modelName	Model name alias that allows to later distinguish between different models that have been set by this function call 
 * @retval 0  Success 
 * @retval -1 Error
 */
KRISP_AUDIO_API int krispAudioSetModel(const wchar_t* weightConfFilePath, const char* modelName);

/*!
 * @brief This function sets the Krisp model's blob data to be used. Several models can be set.
 * The model specified model is later tied to specific session during the session creation process.
 * @param[in] weightBlob The Krisp model weight file data buffer
 * @param[in] blobSize Size of the weight file data buffer
 * @param[in] modelName	Model name alias that allows to later distinguish between different models that have been set by this function call
 * @retval 0  Success
 * @retval -1 Error
 */
KRISP_AUDIO_API int krispAudioSetModelBlob(const char* weightBlob, unsigned int blobSize, const char* modelName);

/*!
 * @brief This function creates Speach Enhance(Noise Canceler NC) session object
 * @param[in] inputSampleRate Sampling frequency of the input data
 * @param[in] outputSampleRate Sampling frequency of the output data
 * @param[in] frameDuration Frame duration
 * @param[in] modelName The session ties to this model, and cleans the future frames using it.
 *              If <b> modelName </b> is \em nullptr than the sdk auto-detecs the model based on input sampleRate
 * @attention Always provide modelName explicitely to avoid ambiguity
 *
 * @return created session handle
 */
KRISP_AUDIO_API KrispAudioSessionID krispAudioNcCreateSession(KrispAudioSamplingRate inputSampleRate,
                                KrispAudioSamplingRate outputSampleRate,
                                KrispAudioFrameDuration frameDuration,
                                const char* modelName);


/*!
 * @brief This function creates Voice Activity Detection session object ( VAD )
 * @param[in] inputSampleRate Sampling frequency of the input data.
 * @param[in] frameDuration Frame duration
 * @param[in] modelName The session ties to this model, and processes the future frames using it
 *              If <b> modelName </b> is \em nullptr than the sdk auto-detecs the model based on input sampleRate.
 * @attention Always provide modelName explicitely to avoid ambiguity
 *
 * @return created session handle
 */
KRISP_AUDIO_API KrispAudioSessionID krispAudioVadCreateSession( KrispAudioSamplingRate inputSampleRate,
                                    KrispAudioFrameDuration frameDuration,
                                    const char* modelName);


/*!
 * @brief This function creates NoiseDB session object
 * @param[in] inputSampleRate Sampling frequency of the input data.
 * @param[in] frameDuration Frame duration
 * @param[in] modelName The session ties to this model, and processes the future frames using it
 *            If <b> modelName </b> is \em nullptr than the sdk auto-detecs the model based on input sampleRate.
 * @attention Always provide modelName explicitely to avoid ambiguity
 *
 * @return created session handle
 */
KRISP_AUDIO_API KrispAudioSessionID krispAudioNoiseDbCreateSession(KrispAudioSamplingRate inputSampleRate,
                                    KrispAudioFrameDuration frameDuration,
                                    const char* modelName);

/*!
 * @brief This function releases all data tied to particular session, closes the given NC session
 * @param[in] pSession Handle to the NC session to be closed
 * @retval 0  Success
 * @retval -1 Error
 */
KRISP_AUDIO_API int krispAudioNcCloseSession(KrispAudioSessionID pSession );


/*!
 * @brief This function releases all data tied to particular session, closes the given VAD session
 * @param[in] pSession Handle to the VAD session to be closed
 * @retval 0  Success
 * @retval -1 Error
 */
KRISP_AUDIO_API int krispAudioVadCloseSession(KrispAudioSessionID pSession );

/*!
 * @brief This function clean all data conected to this session, close this session
 * @param[in] pSession The NoiseDB Session to which the frame belongs to
 * @retval 0  Success
 * @retval -1 Error
 */
KRISP_AUDIO_API int krispAudioNoiseDbCloseSession(KrispAudioSessionID pSession);

/*!
 * @brief This function resets all data conected to this session
 * @param[in] pSession The NoiseDB Session to which the frame belongs to
 * @retval 0  Success
 * @retval -1 Error
 */
KRISP_AUDIO_API int krispAudioNoiseDbResetSession(KrispAudioSessionID pSessionId);

/*!
 * @brief This function cleans the ambient noise for the given single frame. Works with shorts (int16) with value in range <b>[-2^15+1, 2^15]</b>
 * @param[in] pSession The NC Session to which the frame belongs to
 * @param[in] pFrameIn Pointer to input frame. It's a continous buffer with overall size of <b> frameDuration * inputSampleRate / 1000</b> 
 * @param[in] frameInSize This is buffer size which must be <b> frameDuration * inputSampleRate / 1000 </b>
 * @param[in,out] pFrameOut Processed frames. The caller should allocate a buffer of at least <b> frameDuration * outputSampleRate / 1000 </b> size long
 * @param[in] frameOutSize  : this is output buffer size which must be <b> frameDuration * outputSampleRate / 100 </b>
 * @retval 0  Success
 * @retval -1 Error
 */
KRISP_AUDIO_API int krispAudioNcCleanAmbientNoiseInt16(KrispAudioSessionID pSession,
                                const short* pFrameIn, unsigned int frameInSize,
                                short* pFrameOut, unsigned int frameOutSize);

/*!
 * @brief This function cleans the ambient noise for the given single frame. Works with floats with values normalized in range <b>[-1,1]</b>
 * @param[in] pSession The NC Session to which the frame belongs to
 * @param[in] pFrameIn Pointer to input frame. It's a continous buffer with overall size of <b> frameDuration * inputSampleRate / 1000</b> 
 * @param[in] frameInSize This is buffer size which must be <b> frameDuration * inputSampleRate / 1000 </b>
 * @param[in,out] pFrameOut Processed frames. The caller should allocate a buffer of at least <b> frameDuration * outputSampleRate / 1000 </b> size long
 * @param[in] frameOutSize  This is output buffer size which must be <b> frameDuration * outputSampleRate / 100 </b>
 * @retval 0  Success
 * @retval -1 Error
 */
KRISP_AUDIO_API int krispAudioNcCleanAmbientNoiseFloat(KrispAudioSessionID pSession,
                                const float* pFrameIn, unsigned int frameInSize,
                                float* pFrameOut, unsigned int frameOutSize);

/*!
 * @brief This function processed the given frame and returns the VAD detection value. Works with shorts (int16) with value in range <b>[-2^15+1, 2^15]</b>
 * @param[in] pSession The VAD Session to which the frame belongs to
 * @param[in] pFrameIn Pointer to input frame. It's a continous buffer with overall size of <b> frameDuration * inputSampleRate / 1000 </b>
 * @param[in] frameInSize This is buffer size which must be <b> frameDuration * inputSampleRate / 1000 </b>
 * @return Value in range [0,1]. The scale is adjusted such that 0.5 corresponds to the best F1 score on our test dataset (based on TIMIT core test dataset speech examples). 
 *      The Threshold needs to be adjusted to fit exact use case.
 */
KRISP_AUDIO_API float krispAudioVadFrameInt16(KrispAudioSessionID pSession,
                                const short* pFrameIn, unsigned int frameInSize);

/*!
 * @brief This function processed the given frame and returns the VAD detection value. Works with shorts (int16) with value in range <b>[-2^15+1, 2^15]</b>
 * @param[in]     pSession The VAD Session to which the frame belongs to
 * @param[in]     pFrameIn Pointer to input frame. It's a continous buffer with overall size of <b> frameDuration * inputSampleRate / 1000 </b>
 * @param[in]     frameInSize This is buffer size which must be <b> frameDuration * inputSampleRate / 1000 </b>
 * @param[in,out] bandwidthInfo Returns BAND_WIDTH_UNKNOWN if still not predicted, otherwise the real bandwidth: one of the KrispAudioBandWidth values
 * @return Value in range [0,1]. The scale is adjusted such that 0.5 corresponds to the best F1 score on our test dataset (based on TIMIT core test dataset speech examples).
 *      The Threshold needs to be adjusted to fit exact use case.
 */
KRISP_AUDIO_API float krispAudioVadFrameInt16Ex(KrispAudioSessionID pSession,
    const short* pFrameIn, unsigned int frameInSize, KrispAudioBandWidthInfo* bandwidthInfo);

/*!
 * @brief This function processed the given frame and returns the VAD detection value. Works with float values normalized in range <b> [-1,1] </b>
 * @param[in] pSession The VAD Session to which the frame belongs to
 * @param[in] pFrameIn Pointer to input frame. It's a continous buffer with overall size of <b> frameDuration * inputSampleRate / 1000 </b>
 * @param[in] frameInSize This is buffer size which must be <b> frameDuration * inputSampleRate / 1000 </b>
 * @return Value in range [0,1]. The scale is adjusted such that 0.5 corresponds to the best F1 score on our test dataset (based on TIMIT core test dataset speech examples). 
 *      The Threshold needs to be adjusted to fit exact use case.
 */
KRISP_AUDIO_API float krispAudioVadFrameFloat(KrispAudioSessionID pSession,
                                const float* pFrameIn, unsigned int frameInSize);

/*!
 * @brief This function processes the given frame and return noise db detection value. Works with shorts (int16) with value in range <b>[-2^15+1, 2^15]</b>
 * @details It is recommended to use this algorithm continuously for more than 1 second. Use the last frame value as overall noiseDB estimation of the given audio fragment. 
 *		Suggested threshold is 50 of noiseDB value. If last estimated NoiseDB is greater than 50 then the given fragment contains noise with enough energy.
 * @param[in] pSession The NoiseDB Session to which the frame belongs to
 * @param[in] pFrameIn Pointer to input frame. It's a continous buffer with overall size of <b> frameDuration * inputSampleRate / 1000 </b>
 * @param[in] frameInSize This is buffer size which must be <b> frameDuration * inputSampleRate / 1000 </b>
 * @return Value normally in range [-100, 100]. 
 */

/*!
 * @brief This function processed the given frame and returns the VAD detection value. Works with float values normalized in range <b> [-1,1] </b>
 * @param[in]     pSession The VAD Session to which the frame belongs to
 * @param[in]     pFrameIn Pointer to input frame. It's a continous buffer with overall size of <b> frameDuration * inputSampleRate / 1000 </b>
 * @param[in]     frameInSize This is buffer size which must be <b> frameDuration * inputSampleRate / 1000 </b>
 * @param[in,out] bandwidthInfo Returns BAND_WIDTH_UNKNOWN if still not predicted, otherwise the real bandwidth: one of the KrispAudioBandWidth values
 * @return Value in range [0,1]. The scale is adjusted such that 0.5 corresponds to the best F1 score on our test dataset (based on TIMIT core test dataset speech examples).
 *      The Threshold needs to be adjusted to fit exact use case.
 */
KRISP_AUDIO_API float krispAudioVadFrameFloatEx(KrispAudioSessionID pSession,
    const float* pFrameIn, unsigned int frameInSize, KrispAudioBandWidthInfo* bandwidthInfo);

KRISP_AUDIO_API float krispAudioNoiseDbFrameInt16(KrispAudioSessionID pSession,
                                const short* pFrameIn, unsigned int frameInSize);

/*!
 * @brief This function processes the given frame and return noise db detection value. Works with float values normalized in range <b> [-1,1] </b>
 * @details It is recommended to use this algorithm continuously for more than 1 second. Use the last frame value as overall noiseDB estimation of the given audio fragment. 
 *		Suggested threshold is 50 of noiseDB value. If last estimated NoiseDB is greater than 50 then the given fragment contains noise with enough energy.
 * @param[in] pSession The NoiseDB Session to which the frame belongs to
 * @param[in] pFrameIn Pointer to input frame. It's a continous buffer with overall size of <b> frameDuration * inputSampleRate / 1000 </b>
 * @param[in] frameInSize This is buffer size which must be <b> frameDuration * inputSampleRate / 1000 </b>
 * @return Value normally in range [-100, 100]. 
 */
KRISP_AUDIO_API float krispAudioNoiseDbFrameFloat(KrispAudioSessionID pSession,
                                const float* pFrameIn, unsigned int frameInSize);

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif //// KRISP_SPEECH_ENHANCEMENT_H_
