%include <std_shared_ptr.i>

%attribute(iMS::ImagePoint, unsigned int, SyncD, GetSyncD, SetSyncD);
%attribute_custom(iMS::ImagePoint, float, SyncA1, GetSyncA1, SetSyncA1, self_->GetSyncA(0), self_->SetSyncA(0, val_));	
%attribute_custom(iMS::ImagePoint, float, SyncA2, GetSyncA2, SetSyncA2, self_->GetSyncA(1), self_->SetSyncA(1, val_));
%attribute_custom(iMS::ImagePoint, MHz, FreqCh1, GetFreqCh1, SetFreqCh1, &self_->GetFAP(RFChannel(1)).freq, {\
    FAP temp = self_->GetFAP(RFChannel(1));\
    temp.freq = *val_;\
    self_->SetFAP(RFChannel(1), temp);\
  });
%attribute_custom(iMS::ImagePoint, Percent, AmplCh1, GetAmplCh1, SetAmplCh1, &self_->GetFAP(RFChannel(1)).ampl, {\
    FAP temp = self_->GetFAP(RFChannel(1));\
    temp.ampl = *val_;\
    self_->SetFAP(RFChannel(1), temp);\
  });
%attribute_custom(iMS::ImagePoint, Degrees, PhaseCh1, GetPhaseCh1, SetPhaseCh1, &self_->GetFAP(RFChannel(1)).phase, {\
    FAP temp = self_->GetFAP(RFChannel(1));\
    temp.phase = *val_;\
    self_->SetFAP(RFChannel(1), temp);\
  });
%attribute_custom(iMS::ImagePoint, MHz, FreqCh2, GetFreqCh2, SetFreqCh2, &self_->GetFAP(RFChannel(2)).freq, {\
    FAP temp = self_->GetFAP(RFChannel(2));\
    temp.freq = *val_;\
    self_->SetFAP(RFChannel(2), temp);\
  });
%attribute_custom(iMS::ImagePoint, Percent, AmplCh2, GetAmplCh2, SetAmplCh2, &self_->GetFAP(RFChannel(2)).ampl, {\
    FAP temp = self_->GetFAP(RFChannel(2));\
    temp.ampl = *val_;\
    self_->SetFAP(RFChannel(2), temp);\
  });
%attribute_custom(iMS::ImagePoint, Degrees, PhaseCh2, GetPhaseCh2, SetPhaseCh2, &self_->GetFAP(RFChannel(2)).phase, {\
    FAP temp = self_->GetFAP(RFChannel(2));\
    temp.phase = *val_;\
    self_->SetFAP(RFChannel(2), temp);\
  });
%attribute_custom(iMS::ImagePoint, MHz, FreqCh3, GetFreqCh3, SetFreqCh3, &self_->GetFAP(RFChannel(3)).freq, {\
    FAP temp = self_->GetFAP(RFChannel(3));\
    temp.freq = *val_;\
    self_->SetFAP(RFChannel(3), temp);\
  });
%attribute_custom(iMS::ImagePoint, Percent, AmplCh3, GetAmplCh3, SetAmplCh3, &self_->GetFAP(RFChannel(3)).ampl, {\
    FAP temp = self_->GetFAP(RFChannel(3));\
    temp.ampl = *val_;\
    self_->SetFAP(RFChannel(3), temp);\
  });
%attribute_custom(iMS::ImagePoint, Degrees, PhaseCh3, GetPhaseCh3, SetPhaseCh3, &self_->GetFAP(RFChannel(3)).phase, {\
    FAP temp = self_->GetFAP(RFChannel(3));\
    temp.phase = *val_;\
    self_->SetFAP(RFChannel(3), temp);\
  });
%attribute_custom(iMS::ImagePoint, MHz, FreqCh4, GetFreqCh4, SetFreqCh4, &self_->GetFAP(RFChannel(4)).freq, {\
    FAP temp = self_->GetFAP(RFChannel(4));\
    temp.freq = *val_;\
    self_->SetFAP(RFChannel(4), temp);\
  });
%attribute_custom(iMS::ImagePoint, Percent, AmplCh4, GetAmplCh4, SetAmplCh4, &self_->GetFAP(RFChannel(4)).ampl, {\
    FAP temp = self_->GetFAP(RFChannel(4));\
    temp.ampl = *val_;\
    self_->SetFAP(RFChannel(4), temp);\
  });
%attribute_custom(iMS::ImagePoint, Degrees, PhaseCh4, GetPhaseCh4, SetPhaseCh4, &self_->GetFAP(RFChannel(4)).phase, {\
    FAP temp = self_->GetFAP(RFChannel(4));\
    temp.phase = *val_;\
    self_->SetFAP(RFChannel(4), temp);\
  });

namespace iMS {

  %copyctor ImagePoint;
  %rename(__eq__) ImagePoint::operator==;
  class ImagePoint
  {
  public:
    ImagePoint();
    ImagePoint(FAP fap);
    ImagePoint(FAP ch1, FAP ch2, FAP ch3, FAP ch4);
    ImagePoint(FAP fap, float synca, unsigned int syncd);
    ImagePoint(FAP ch1, FAP ch2, FAP ch3, FAP ch4, float synca_1, float synca_2, unsigned int syncd);
    
     %extend {
        friend std::ostream& operator<< (std::ostream& stream, const ImagePoint&);
        std::string __str__() {
            std::ostringstream oss;
            for (int i=1; i<=4; i++) {
                auto& fap = $self->GetFAP(RFChannel(i));
                oss << "Ch" << i << ": " << fap.freq << "MHz/" << fap.ampl << "%/" << fap.phase << "deg" << std::endl;
            }
            oss << "Sync: A1 = " << $self->GetSyncA(0) << " A2 = " << $self->GetSyncA(1) << " D = 0x" << std::hex << std::setfill('0') << std::setw(4) << $self->GetSyncD();
            return oss.str();
        }
    }

    bool operator==(ImagePoint const& rhs) const;
    const FAP& GetFAP(const RFChannel) const;
    void SetFAP(const RFChannel, const FAP&);
    //FAP& SetFAP(const RFChannel);
    void SetAll(const FAP&);
    const float& GetSyncA(int index);
    void SetSyncA(int index, float value);
    const unsigned int& GetSyncD() const;
    void SetSyncD(unsigned int);
  };
}

%attribute_custom(iMS::Image, iMS::Frequency&, ClockRate, GetClockRate, SetClockRate, self_->ClockRate(), self_->ClockRate(val_));
%attribute_custom(iMS::Image, int, ExtClockDivide, GetExtClockDivide, SetExtClockDivide, self_->ExtClockDivide(), self_->ExtClockDivide(val_));
%attributeref(iMS::Image, std::string, Description, Description);
namespace iMS {

  class Image : public DequeBase<ImagePoint> {

  public:

    Image(const std::string& name = "");
    Image(size_t nPts, const ImagePoint& pt, const std::string& name = "");
    Image(size_t nPts, const ImagePoint& pt, const Frequency& f, const std::string& name = "");
    Image(size_t nPts, const ImagePoint& pt, const int div, const std::string& name = "");
    Image(const Image &);

     %extend {
        friend std::ostream& operator<< (std::ostream& stream, const Image&);
        std::string __str__() {
            std::ostringstream oss;
            oss << $self->Name() << " => " << $self->size() << " points";
            return oss.str();
        }
    }

    //    void ClockRate(const Frequency& f);
    //    const Frequency ClockRate() const;
    //    void ExtClockDivide(const int div);
    //    const int ExtClockDivide() const;
  };
}
  
%attribute(iMS::ImageTableEntry, ImageIndex, Handle, Handle);
%attribute(iMS::ImageTableEntry, unsigned int, Address, Address);
%attribute(iMS::ImageTableEntry, int, NPts, NPts);
%attribute(iMS::ImageTableEntry, int, Size, Size);
%attribute(iMS::ImageTableEntry, unsigned int, Format, Format);
%attribute2(iMS::ImageTableEntry, %arg(const std::array<uint8_t, 16>), GetUUID, UUID);
%attribute(iMS::ImageTableEntry, std::string, Name, Name);
namespace iMS {

  typedef int ImageIndex;

  struct ImageTableEntry
  {
     %extend {
        std::string __str__() {
            std::ostringstream oss;
            oss << "id: " << $self->Handle();
            oss << " Addr: 0x" << std::hex << std::setfill('0') << std::setw(6) << $self->Address();
            oss << std::dec << " Points: " << $self->NPts();
            oss << " ByteLength: " << $self->Size();
            oss << " Format Code: 0x" << std::hex << std::setfill('0') << std::setw(2) << $self->Format() << " ";
            oss << $self->UUID();
            oss << " " << $self->Name();
            oss << std::endl;
            return oss.str();
        }        
    }
    ImageTableEntry();
    ImageTableEntry(ImageIndex handle, unsigned int address, int n_pts, int size, unsigned int fmt, std::array<uint8_t, 16> uuid, std::string name);
    ImageTableEntry(ImageIndex handle, const std::vector<uint8_t>&);
    ImageTableEntry(const ImageTableEntry &);
    const ImageIndex& Handle() const;
    const unsigned int& Address() const;
    const int& NPts() const;
    const int& Size() const;
    const unsigned int& Format() const;
    const std::array<unsigned char, 16>& UUID() const;
    bool Matches(const Image& img) const;
    const std::string& Name() const;
  };

}

namespace iMS {
    enum class ImageRepeats {
      NONE,
      PROGRAM,
      FOREVER
      };

  enum class SequenceTermAction : uint8_t
  {
    DISCARD = 0,
      RECYCLE = 1,
      STOP_DISCARD = 2,
      STOP_RECYCLE = 3,
      REPEAT = 4,
      REPEAT_FROM = 5,
      INSERT = 7,
      STOP_INSERT = 8
      };
}

%shared_ptr(iMS::SequenceEntry)

%attributeref(iMS::SequenceEntry, std::chrono::duration<double>&, SyncOutDelay, SyncOutDelay);
%attribute2(iMS::SequenceEntry, %arg(std::array<uint8_t, 16>), UUID, UUID);
%attribute(iMS::SequenceEntry, int, NumRpts, NumRpts);

namespace iMS {
  %ignore SequenceEntry::operator=;
  %rename(__eq__) SequenceEntry::operator==;
  struct SequenceEntry {
    SequenceEntry();
    SequenceEntry(const std::array<std::uint8_t, 16>& uuid, const int rpts = 0);
    //  virtual ~SequenceEntry() = 0;
    SequenceEntry(const SequenceEntry&);
    SequenceEntry& operator =(const SequenceEntry&);
    virtual bool operator==(SequenceEntry const& rhs) const = 0;

    std::chrono::duration<double>& SyncOutDelay();

    void SetFrequencyOffset(const MHz& offset, const RFChannel& chan = RFChannel::all);
    const MHz& GetFrequencyOffset(const RFChannel& chan) const;

    const std::array<uint8_t, 16>& UUID() const;
    const int& NumRpts() const;
  };
}

%shared_ptr(iMS::ImageSequenceEntry)

%attributeref(iMS::ImageSequenceEntry, std::chrono::duration<double>&, PostImgDelay, PostImgDelay);
%attribute(iMS::ImageSequenceEntry, int, ExtDiv, ExtDiv);
%attribute(iMS::ImageSequenceEntry, Frequency&, IntOsc, IntOsc);
%attribute(iMS::ImageSequenceEntry, const ImageRepeats&, RptType, RptType);

namespace iMS {
  %ignore ImageSequenceEntry::operator=;
  %rename(__eq__) ImageSequenceEntry::operator==;
  struct ImageSequenceEntry : iMS::SequenceEntry
  {
    ImageSequenceEntry();
    ImageSequenceEntry(const Image& img, const ImageRepeats& Rpt = ImageRepeats::NONE, const int rpts = 0);
    ImageSequenceEntry(const ImageTableEntry& ite, const kHz& InternalClock, const ImageRepeats& Rpt = ImageRepeats::NONE, const int rpts = 0);
    ImageSequenceEntry(const ImageTableEntry& ite, const int ExtClockDivide, const ImageRepeats& Rpt = ImageRepeats::NONE, const int rpts = 0);
    ImageSequenceEntry(const ImageSequenceEntry &);
    ImageSequenceEntry(const SequenceEntry &);
    ImageSequenceEntry &operator =(const ImageSequenceEntry &);
    bool operator==(SequenceEntry const& rhs) const;
    
    std::chrono::duration<double>& PostImgDelay();
    const int& ExtDiv() const;
    const Frequency& IntOsc() const;
    const ImageRepeats& RptType() const;
  };

}

%attribute(iMS::ImageSequence, SequenceTermAction, TermAction, TermAction);
%attribute(iMS::ImageSequence, int, TermValue, TermValue);
namespace iMS {
  class ImageSequence : public ListBase < std::shared_ptr < SequenceEntry > >
  {
  public:
    ImageSequence();
    ImageSequence(SequenceTermAction action, int val = 0);
    ImageSequence(SequenceTermAction action, const ImageSequence* insert_before);
    ImageSequence(const ImageSequence &);


    void OnTermination(SequenceTermAction act, int val = 0);
    void OnTermination(SequenceTermAction act, const ImageSequence* term_seq);
    const SequenceTermAction& TermAction() const;
    const int& TermValue() const;
    const ImageSequence* ImageSequence::TermInsertBefore() const;
  };
}


%extend std::shared_ptr < SequenceEntry >{
    friend std::ostream& operator<< (std::ostream& stream, const std::shared_ptr < SequenceEntry >&);
}

%attributeref(iMS::ImageGroup, std::string, Author, Author);
%attributeref(iMS::ImageGroup, std::string, Company, Company);
%attributeref(iMS::ImageGroup, std::string, Revision, Revision);
%attributeref(iMS::ImageGroup, std::string, Description, Description);
%attributestring(iMS::ImageGroup, std::string, CreatedTimeFormat, CreatedTimeFormat);
%attribute2ref(iMS::ImageGroup, iMS::ImageSequence, Sequence, Sequence);
namespace iMS {
  class  ImageGroup : public DequeBase< Image > {
  public:
    ImageGroup(const std::string& name = "");
    ImageGroup(size_t n, const std::string& name = "");
    ImageGroup(const ImageGroup &);

     %extend {
        friend std::ostream& operator<< (std::ostream& stream, const ImageGroup&);
        std::string __str__() {
            std::ostringstream oss;
            oss << $self->Name() << " => " << $self->Size() << " images";
            return oss.str();
        }
    }
    //    void Clear();
    int Size() const;
  };
}
