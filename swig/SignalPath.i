namespace iMS
{
  enum class SignalPathEvents
  {
      RX_DDS_POWER,
      ENC_VEL_CH_X,
      ENC_VEL_CH_Y
  };
}

namespace iMS
{

  /// Forward Declaration
  struct VelocityConfiguration;

  class SignalPath
  {
  public:
    enum class AmplitudeControl
    {
        OFF,
        EXTERNAL,
        WIPER_1,
        WIPER_2,
        INDEPENDENT
	};
    
    enum class ToneBufferControl
    {
        HOST,
        EXTERNAL,
        EXTERNAL_EXTENDED,
        OFF
	};
    
    enum class Compensation
    {
        ACTIVE,
        BYPASS
	};
    
    enum class SYNC_SRC
    {
        FREQUENCY_CH1,
        FREQUENCY_CH2,
        FREQUENCY_CH3,
        FREQUENCY_CH4,
        AMPLITUDE_CH1,
        AMPLITUDE_CH2,
        AMPLITUDE_CH3,
        AMPLITUDE_CH4,
        AMPLITUDE_PRE_COMP_CH1,
        AMPLITUDE_PRE_COMP_CH2,
        AMPLITUDE_PRE_COMP_CH3,
        AMPLITUDE_PRE_COMP_CH4,
        PHASE_CH1,
        PHASE_CH2,
        PHASE_CH3,
        PHASE_CH4,
        LOOKUP_FIELD_CH1,
        LOOKUP_FIELD_CH2,
        LOOKUP_FIELD_CH3,
        LOOKUP_FIELD_CH4,
        IMAGE_ANLG_A,
        IMAGE_ANLG_B,
        IMAGE_DIG
	};
    
    enum class SYNC_SINK
    {
        ANLG_A,
        ANLG_B,
        DIG
	};

    enum class SYNC_DIG_MODE
    {
        PULSE,
        LEVEL
    };

    enum class ENCODER_MODE
    {
        QUADRATURE,
        COUNT_DIRECTION
	};

    enum class VELOCITY_MODE
    {
        FAST,
        SLOW
	};

    enum class ENCODER_CHANNEL
    {
        CH_X,
        CH_Y
	};

    SignalPath(IMSSystem& ims);

    bool UpdateDDSPowerLevel(const Percent& power);
    bool UpdateRFAmplitude(const AmplitudeControl src, const Percent& ampl, const RFChannel& chan = RFChannel::all);
    bool SwitchRFAmplitudeControlSource(const AmplitudeControl src, const RFChannel& chan = RFChannel::all);
    bool UpdatePhaseTuning(const RFChannel& channel, const Degrees& phase);
    bool SetChannelReversal(bool reversal);
    bool EnableImagePathCompensation(SignalPath::Compensation amplComp, SignalPath::Compensation phaseComp);
    bool EnableXYPhaseCompensation(bool XYCompEnable);
    bool SetXYChannelDelay(std::chrono::duration<uint64_t, std::ratio<1,1000000000>> delay);
    bool SetChannelDelay(std::chrono::duration<uint64_t, std::ratio<1,1000000000>> first,
					 	     std::chrono::duration<uint64_t, std::ratio<1,1000000000>> second);
    bool SetCalibrationTone(const FAP& fap);
    bool ClearTone();
    bool SetCalibrationChannelLock(const RFChannel& chan);
    bool ClearCalibrationChannelLock(const RFChannel& chan = RFChannel::all);
    bool GetCalibrationChannelLockState(const RFChannel& chan);
    bool PhaseResync();
    bool AutoPhaseResync(bool enable = true);
    bool SetEnhancedToneMode(const SweepTone& tone_ch1, const SweepTone& tone_ch2, const SweepTone& tone_ch3, const SweepTone& tone_ch4);
    bool SetEnhancedToneChannel(const RFChannel& chan, const SweepTone& tone);
    bool ClearEnhancedToneMode();
    bool ClearEnhancedToneChannel(const RFChannel& chan);

    bool AssignSynchronousOutput(const SYNC_SINK& sink, const SYNC_SRC& src) const;
    bool ConfigureSyncDigitalOutput(std::chrono::duration<uint64_t, std::ratio<1,1000000000>> delay, std::chrono::duration<uint64_t, std::ratio<1,1000000000>> pulse_length);
    bool SyncDigitalOutputInvert(bool invert);
    bool SyncDigitalOutputMode(SYNC_DIG_MODE mode, int index);
    
    bool UpdateLocalToneBuffer(const ToneBufferControl& tbc, const unsigned int index, 
			       const Compensation AmplitudeComp = Compensation::ACTIVE,
			       const Compensation PhaseComp = Compensation::ACTIVE);
    bool UpdateLocalToneBuffer(const ToneBufferControl& tbc);
    bool UpdateLocalToneBuffer(const Compensation AmplitudeComp, const Compensation PhaseComp);
    bool UpdateLocalToneBuffer(const unsigned int index);
    bool UpdateEncoder(const VelocityConfiguration& velcomp);
    bool DisableEncoder();
    bool ReportEncoderVelocity(ENCODER_CHANNEL chan);

    bool AddFrequencyOffset(MHz& offset, RFChannel chan = RFChannel::all);
    bool SubtractFrequencyOffset(MHz& offset, RFChannel chan = RFChannel::all);

    void SignalPathEventSubscribe(const int message, IEventHandler* handler);
    void SignalPathEventUnsubscribe(const int message, const IEventHandler* handler);
  };
  
}

namespace iMS
{
  struct  VelocityConfiguration
  {
    SignalPath::ENCODER_MODE EncoderMode { SignalPath::ENCODER_MODE::QUADRATURE };
    SignalPath::VELOCITY_MODE VelocityMode { SignalPath::VELOCITY_MODE::FAST };
    uint16_t TrackingLoopProportionCoeff { 4000 };
    uint16_t TrackingLoopIntegrationCoeff { 10000 };
    std::array<int16_t, 2> VelocityGain;
    
    void SetVelGain(const IMSSystem& ims, SignalPath::ENCODER_CHANNEL chan, kHz EncoderFreq, MHz DesiredFreqDeviation, bool Reverse = false);
    
    VelocityConfiguration() : VelocityGain({ { 500, 500 } }) {}
  };

}
