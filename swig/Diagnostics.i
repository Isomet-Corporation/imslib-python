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

    // Use this to interpret the output of GetDiagnosticsData()
    %pythoncode %{
    from enum import Enum

    class MEASUREMENT(Enum):
        FORWARD_POWER_CH1 = _imslib.Diagnostics_MEASURE_FORWARD_POWER_CH1
        FORWARD_POWER_CH2 = _imslib.Diagnostics_MEASURE_FORWARD_POWER_CH2
        FORWARD_POWER_CH3 = _imslib.Diagnostics_MEASURE_FORWARD_POWER_CH3
        FORWARD_POWER_CH4 = _imslib.Diagnostics_MEASURE_FORWARD_POWER_CH4
        REFLECTED_POWER_CH1 = _imslib.Diagnostics_MEASURE_REFLECTED_POWER_CH1
        REFLECTED_POWER_CH2 = _imslib.Diagnostics_MEASURE_REFLECTED_POWER_CH2
        REFLECTED_POWER_CH3 = _imslib.Diagnostics_MEASURE_REFLECTED_POWER_CH3
        REFLECTED_POWER_CH4 = _imslib.Diagnostics_MEASURE_REFLECTED_POWER_CH4
        DC_CURRENT_CH1 = _imslib.Diagnostics_MEASURE_DC_CURRENT_CH1
        DC_CURRENT_CH2 = _imslib.Diagnostics_MEASURE_DC_CURRENT_CH2
        DC_CURRENT_CH3 = _imslib.Diagnostics_MEASURE_DC_CURRENT_CH3
        DC_CURRENT_CH4 = _imslib.Diagnostics_MEASURE_DC_CURRENT_CH4
    %}
    
  class Diagnostics
  {
  public:
    Diagnostics(std::shared_ptr<IMSSystem> ims);
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
    std::map<std::string, Percent> GetDiagnosticsDataStr() const;
  };

}

