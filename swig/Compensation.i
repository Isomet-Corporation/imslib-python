namespace iMS
{
  enum class CompensationEvents {
    RX_DDS_POWER,
    DOWNLOAD_FINISHED,
    DOWNLOAD_ERROR,
    VERIFY_SUCCESS,
    VERIFY_FAIL
  };
  
  enum class CompensationFeature {
    AMPLITUDE,
    PHASE,
    SYNC_DIG,
    SYNC_ANLG
  };

  enum class CompensationModifier {
    REPLACE,
    MULTIPLY
  };
}

%attribute_custom(iMS::CompensationPoint, iMS::Percent&, Amplitude, GetAmplitude, SetAmplitude, self_->Amplitude(), self_->Amplitude(val_));
%attribute_custom(iMS::CompensationPoint, iMS::Degrees&, Phase, GetPhase, SetPhase, self_->Phase(), self_->Phase(val_));
%attribute_custom(iMS::CompensationPoint, uint32_t, SyncDig, GetSyncDig, SetSyncDig, self_->SyncDig(), self_->SyncDig(val_));
%attribute_custom(iMS::CompensationPoint, double, SyncAnlg, GetSyncAnlg, SetSyncAnlg, self_->SyncAnlg(), self_->SyncAnlg(val_));

namespace iMS
{
  class CompensationPoint
  {
  public:
    CompensationPoint(Percent ampl = Percent(0.0), Degrees phase = Degrees(0.0), unsigned int sync_dig = 0, double sync_anlg = 0.0);
    CompensationPoint(Degrees phase, unsigned int sync_dig = 0, double sync_anlg = 0.0);
    CompensationPoint(unsigned int sync_dig, double sync_anlg = 0.0);
    CompensationPoint(double sync_anlg);
  };
  
}

%attribute_custom(iMS::CompensationPointSpecification, iMS::MHz&, Freq, GetFreq, SetFreq, self_->Freq(), self_->Freq(val_));
%attribute_custom(iMS::CompensationPointSpecification, iMS::CompensationPoint&, Spec, GetSpec, SetSpec, self_->Spec(), self_->Spec(val_));

namespace iMS
{
  class CompensationPointSpecification
  {
  public:
    CompensationPointSpecification(CompensationPoint pt = CompensationPoint(), MHz f = 50.0);
    CompensationPointSpecification(const CompensationPointSpecification &);
  };
}

%attribute_custom(iMS::CompensationFunction, iMS::CompensationFunction::InterpolationStyle, AmplitudeInterpolationStyle,
		  GetStyle, SetStyle, self_->GetStyle(iMS::CompensationFeature::AMPLITUDE), self_->SetStyle(iMS::CompensationFeature::AMPLITUDE, val_));
%attribute_custom(iMS::CompensationFunction, iMS::CompensationFunction::InterpolationStyle, PhaseInterpolationStyle,
		  GetStyle, SetStyle, self_->GetStyle(iMS::CompensationFeature::PHASE), self_->SetStyle(iMS::CompensationFeature::PHASE, val_));
%attribute_custom(iMS::CompensationFunction, iMS::CompensationFunction::InterpolationStyle, SyncAnlgInterpolationStyle,
		  GetStyle, SetStyle, self_->GetStyle(iMS::CompensationFeature::SYNC_ANLG), self_->SetStyle(iMS::CompensationFeature::SYNC_ANLG, val_));
%attribute_custom(iMS::CompensationFunction, iMS::CompensationFunction::InterpolationStyle, SyncDigInterpolationStyle,
		  GetStyle, SetStyle, self_->GetStyle(iMS::CompensationFeature::SYNC_DIG), self_->SetStyle(iMS::CompensationFeature::SYNC_DIG, val_));
namespace iMS {
  class CompensationFunction : public ListBase < CompensationPointSpecification >
  {
  public:
    enum class InterpolationStyle {
      SPOT,
      STEP,
      LINEAR,
      LINEXTEND,
      BSPLINE
    };

    CompensationFunction();
    CompensationFunction(const CompensationFunction &);

    //    void SetStyle(const CompensationFeature feat, const InterpolationStyle style);
    //    InterpolationStyle GetStyle(const CompensationFeature feat) const;

  };
}

%attributeval(iMS::CompensationTable, iMS::MHz, Upper, UpperFrequency)
%attributeval(iMS::CompensationTable, iMS::MHz, Lower, LowerFrequency)
namespace iMS {
  
  class CompensationTable : public DequeBase < CompensationPoint >
  {
  public:
    CompensationTable();
    CompensationTable(const IMSSystem& iMS);
    CompensationTable(int LUTDepth, const MHz& lower_freq, const MHz& upper_freq);
    CompensationTable(const IMSSystem& iMS, const CompensationPoint& pt);
    CompensationTable(int LUTDepth, const MHz& lower_freq, const MHz& upper_freq, const CompensationPoint& pt);
    CompensationTable(const IMSSystem& iMS, const std::string& fileName, const RFChannel& chan = RFChannel::all);
    CompensationTable(int LUTDepth, const MHz& lower_freq, const MHz& upper_freq, const std::string& fileNamee, const RFChannel& chan = RFChannel::all);
    CompensationTable(const IMSSystem& iMS, const int entry);
    CompensationTable(const IMSSystem& iMS, const CompensationTable& tbl);
    CompensationTable(int LUTDepth, const MHz& lower_freq, const MHz& upper_freq, const CompensationTable& tbl);

    CompensationTable(const CompensationTable &);
    %rename(assign) operator=;
    CompensationTable &operator =(const CompensationTable &);

    bool ApplyFunction(const CompensationFunction& func, const CompensationFeature feat, CompensationModifier modifier = CompensationModifier::REPLACE);
    //bool ApplyFunction(const CompensationFunction& func, CompensationModifier modifier = CompensationModifier::REPLACE);

    const std::size_t Size() const;
    const MHz FrequencyAt(const unsigned int index) const;
    const MHz LowerFrequency() const;
    const MHz UpperFrequency() const;
    const bool Save(const std::string& fileName) const;
  };
  
}

namespace iMS {
  class CompensationTableExporter
  {
  public:
    CompensationTableExporter(const IMSSystem& ims);
    CompensationTableExporter(const int channels);
    CompensationTableExporter();
    CompensationTableExporter(const CompensationTable& tbl);
    
    void ProvideGlobalTable(const CompensationTable& tbl);
    void ProvideChannelTable(const RFChannel& chan, const CompensationTable& tbl);

    bool ExportGlobalLUT(const std::string& fileName);
    bool ExportChannelLUT(const std::string& fileName);
  };
}

%attribute(iMS::CompensationTableImporter, int, Size, Size);
%attributeval(iMS::CompensationTableImporter, iMS::MHz, LowerFrequency, LowerFrequency);
%attributeval(iMS::CompensationTableImporter, iMS::MHz, UpperFrequency, UpperFrequency);

namespace iMS {
  class CompensationTableImporter
  {
  public:
    CompensationTableImporter(const std::string& fileName);

    bool IsValid() const;
    bool IsGlobal() const;
    int Channels() const;

    int Size() const;
    MHz LowerFrequency() const;
    MHz UpperFrequency() const;

    CompensationTable RetrieveGlobalLUT();
    CompensationTable RetrieveChannelLUT(RFChannel& chan);
  };
}

namespace iMS {

  class CompensationTableDownload
  {
  public:
    CompensationTableDownload(IMSSystem& ims, const CompensationTable& tbl);
    bool StartDownload();
    bool StartVerify();
    int GetVerifyError();
    void CompensationTableDownloadEventSubscribe(const int message, IEventHandler* handler);
    void CompensationTableDownloadEventUnsubscribe(const int message, const IEventHandler* handler);
    const FileSystemIndex Store(FileDefault def, const std::string& FileName) const;	
  };

}
