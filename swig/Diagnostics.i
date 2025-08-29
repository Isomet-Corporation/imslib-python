namespace iMS
{
  enum class DiagnosticsEvents
  {
    AOD_TEMP_UPDATE,
      RFA_TEMP_UPDATE,
      SYN_LOGGED_HOURS,
      AOD_LOGGED_HOURS,
      RFA_LOGGED_HOURS,
      DIAGNOSTICS_UPDATE_AVAILABLE,
      DIAG_READ_FAILED
      };
}

namespace iMS 
{
  class Diagnostics
  {
  public:
    Diagnostics(const IMSSystem& ims);
    enum class TARGET
    {
      SYNTH,
	AO_DEVICE,
	RF_AMPLIFIER
	};
    
    enum class MEASURE
    {
      FORWARD_POWER_CH1,
	FORWARD_POWER_CH2,
	FORWARD_POWER_CH3,
	FORWARD_POWER_CH4,
	REFLECTED_POWER_CH1,
	REFLECTED_POWER_CH2,
	REFLECTED_POWER_CH3,
	REFLECTED_POWER_CH4,
	DC_CURRENT_CH1,
	DC_CURRENT_CH2,
	DC_CURRENT_CH3,
	DC_CURRENT_CH4
	};
    
    void DiagnosticsEventSubscribe(const int message, IEventHandler* handler);
    void DiagnosticsEventUnsubscribe(const int message, const IEventHandler* handler);
    bool GetTemperature(const TARGET& tgt) const;
    bool GetLoggedHours(const TARGET& tgt) const;
    bool UpdateDiagnostics();
    const std::map<int, Percent>& GetDiagnosticsData() const;
  };

}

