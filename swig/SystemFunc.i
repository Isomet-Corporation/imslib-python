namespace iMS
{
  enum class SystemFuncEvents
  {
    PIXEL_CHECKSUM_ERROR_COUNT,
      MASTER_CLOCK_REF_FREQ,
      MASTER_CLOCK_REF_MODE,
      MASTER_CLOCK_REF_STATUS,
      SYNTH_TEMPERATURE_1,
      SYNTH_TEMPERATURE_2,
  };
}

namespace iMS
{

  // Forward declarations
  struct StartupConfiguration;
	struct ClockGenConfiguration;

  class SystemFunc
  {
  public:
    SystemFunc(std::shared_ptr<IMSSystem> ims);
    enum class UpdateClockSource
    {
      INTERNAL,
	EXTERNAL
	};
    enum class TemperatureSensor
    {
      TEMP_SENSOR_1,
	TEMP_SENSOR_2
	};
    enum class PLLLockReference
    {
      INTERNAL,
	EXTERNAL_FIXED,
	EXTERNAL_AUTO,
	EXTERNAL_FAILOVER
	};
    enum class PLLLockStatus
    {
      EXTERNAL_NOSIGNAL = 0,
	INTERNAL_UNLOCKED = 4,
	INTERNAL_LOCKED = 5,
	EXTERNAL_VALID_UNLOCKED = 8,
	EXTERNAL_LOCKED = 9
	};
    enum class NHFLocalReset
    {
      NO_ACTION = 0,
	RESET_ON_COMMS_UNHEALTHY = 1
	};
    
    bool ClearNHF();
    bool SendHeartbeat();
    void StartHeartbeat(int intervalMs);
    void StopHeartbeat();
    bool ConfigureNHF(bool Enabled, int milliSeconds, NHFLocalReset reset);
    bool EnableAmplifier(bool en);
    bool EnableExternal(bool enable);
    bool EnableRFChannels(bool chan1_2, bool chan3_4);
    bool GetChecksumErrorCount(bool Reset = true);
    bool SetDDSUpdateClockSource(UpdateClockSource src = UpdateClockSource::INTERNAL);
    bool StoreStartupConfig(const StartupConfiguration& cfg);
    bool ReadSystemTemperature(TemperatureSensor sensor);
    bool SetClockReferenceMode(PLLLockReference mode, kHz ExternalFixedFreq = kHz(1000.0));
    bool GetClockReferenceStatus();
    bool GetClockReferenceFrequency();
    bool GetClockReferenceMode();
    bool ConfigureClockGenerator(const ClockGenConfiguration& cfg);
    const ClockGenConfiguration& GetClockGenConfiguration() const;
    bool DisableClockGenerator();
    void SystemFuncEventSubscribe(const int message, IEventHandler* handler);
    void SystemFuncEventUnsubscribe(const int message, const IEventHandler* handler);
  };

}

namespace iMS 
{

  struct StartupConfiguration
  {
    Percent RFAmplitudeWiper1;
    Percent RFAmplitudeWiper2;
    Percent DDSPower;
    SignalPath::AmplitudeControl AmplitudeControlSource;
    bool RFGate;
    bool RFBias12;
    bool RFBias34;
    bool ExtEquipmentEnable;
    SignalPath::Compensation LTBUseAmplitudeCompensation;
    SignalPath::Compensation LTBUsePhaseCompensation;
    SignalPath::ToneBufferControl LTBControlSource;
    uint8_t LocalToneIndex;
    Degrees PhaseTuneCh1;
    Degrees PhaseTuneCh2;
    Degrees PhaseTuneCh3;
    Degrees PhaseTuneCh4;
    bool ChannelReversal;
    SignalPath::Compensation ImageUseAmplitudeCompensation;
    SignalPath::Compensation ImageUsePhaseCompensation;
    SystemFunc::UpdateClockSource upd_clk;
    bool XYCompEnable;
    Auxiliary::LED_SOURCE LEDGreen;
    Auxiliary::LED_SOURCE LEDYellow;
    Auxiliary::LED_SOURCE LEDRed;
    uint8_t GPOutput;
    SystemFunc::NHFLocalReset ResetOnUnhealthy;
    bool CommsHealthyCheckEnabled;
    unsigned int CommsHealthyCheckTimerMilliseconds;
    SignalPath::SYNC_SRC SyncDigitalSource ;
    SignalPath::SYNC_SRC SyncAnalogASource ;
    SignalPath::SYNC_SRC SyncAnalogBSource ;
    SystemFunc::PLLLockReference PLLMode;
    kHz ExtClockFrequency;
    bool PhaseAccClear;
  };
  
  struct ClockGenConfiguration
	{
		Frequency  ClockFreq;
		Degrees    OscPhase;
		Percent    DutyCycle;
		bool       AlwaysOn;
		bool       GenerateTrigger;
		Polarity   ClockPolarity;
		Polarity   TrigPolarity;
	};
}
