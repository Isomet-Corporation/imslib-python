%{
    // For operator<<
    #include <sstream>
%}

%attribute_custom(iMS::Frequency, double, value, GetValue, SetValue, (*self_), (*self_)=val_);
%attribute_custom(iMS::kHz, double, value, GetValue, SetValue, (*self_), (*self_)=val_);
%attribute_custom(iMS::MHz, double, value, GetValue, SetValue, (*self_), (*self_)=val_);
%attribute_custom(iMS::Percent, double, value, GetValue, SetValue, (*self_), (*self_)=val_);
%attribute_custom(iMS::Degrees, double, value, GetValue, SetValue, (*self_), (*self_)=val_);
%attribute_custom(iMS::RFChannel, int, value, GetValue, SetValue, (*self_), (*self_)=(val_ = (val_ == RFChannel::all) ? val_ : (val_ < RFChannel::min) ? RFChannel::min : (val_ > RFChannel::max) ? RFChannel::max : val_));

namespace iMS {

  %ignore Frequency::operator=;
  %ignore Frequency::operator double;

  class Frequency 
  {
  public:
    Frequency(double arg = 1.0);
    Frequency& operator = (double arg);
    operator double() const;
    %extend {
        // Explicit constructor to allow kHz(frequency) in Python
        Frequency(const iMS::kHz& f) {
            double freq_in_Hz = f * 1000.0;
            return new iMS::Frequency(freq_in_Hz);
        }
        Frequency(const iMS::MHz& f) {
            double freq_in_Hz = f * 1000000.0;
            return new iMS::Frequency(freq_in_Hz);
        }
        void assign(const Frequency& f) {
            *self = f;  // call existing kHz::operator=(double)
        }
        iMS::Frequency &__add__(const iMS::Frequency& f) {
            *self = *self + f; 
            return *self;
        }
        iMS::Frequency &__iadd__(const iMS::Frequency& f) {
            *self = *self + f; 
            return *self;
        }
        iMS::Frequency &__sub__(const iMS::Frequency& f) {
            *self = *self - f; 
            return *self;
        }
        iMS::Frequency &__isub__(const iMS::Frequency& f) {
            *self = *self - f; 
            return *self;
        }
    }
  };

  %ignore kHz::operator=;
  %ignore kHz::operator double;

  class kHz : public Frequency 
  {
  public:
    kHz(double arg = 1.0) : Frequency(arg * 1000.0) {};
    kHz& operator = (double arg);
    operator double() const;
    %extend {
        // Explicit constructor to allow kHz(frequency) in Python
        kHz(const Frequency& f) {
            double freq_in_kHz = f / 1000.0;
            return new iMS::kHz(freq_in_kHz);
        }
        kHz(const MHz& f) {
            double freq_in_kHz = f * 1000.0;
            return new iMS::kHz(freq_in_kHz);
        }
        void assign(const Frequency& f) {
            *self = f;  // call existing kHz::operator=(double)
        }
        iMS::kHz &__add__(const iMS::kHz& f) {
            *self = *self + f; 
            return *self;
        }
        iMS::kHz &__add__(const iMS::Frequency& f) {
            *self = *self + f / 1000.0; 
            return *self;
        }
        iMS::kHz &__iadd__(const iMS::kHz& f) {
            *self = *self + f; 
            return *self;
        }
        iMS::kHz &__iadd__(const iMS::Frequency& f) {
            *self = *self + f / 1000.0; 
            return *self;
        }
        iMS::kHz &__sub__(const iMS::kHz& f) {
            *self = *self - f; 
            return *self;
        }
        iMS::kHz &__sub__(const iMS::Frequency& f) {
            *self = *self - f / 1000.0; 
            return *self;
        }
        iMS::kHz &__isub__(const iMS::kHz& f) {
            *self = *self - f; 
            return *self;
        }
        iMS::kHz &__isub__(const iMS::Frequency& f) {
            *self = *self - f / 1000.0; 
            return *self;
        }
    }
  };

  %ignore MHz::operator=;
  %ignore MHz::operator double;

  class MHz : public Frequency 
  {
  public:
    MHz(double arg = 1.0) : Frequency(arg * 1000000.0) {};
    MHz& operator = (double arg);
    operator double() const;
    %extend {
        // Explicit constructor to allow kHz(frequency) in Python
        MHz(const Frequency& f) {
            double freq_in_MHz = f / 1000000.0;
            return new iMS::MHz(freq_in_MHz);
        }
        // Explicit constructor to allow kHz(frequency) in Python
        MHz(const kHz& f) {
            double freq_in_MHz = f / 1000.0;
            return new iMS::MHz(freq_in_MHz);
        }
        void assign(const Frequency& f) {
            *self = f;  // call existing kHz::operator=(double)
        }
        iMS::MHz &__add__(const iMS::MHz& f) {
            *self = *self + f; 
            return *self;
        }
        iMS::MHz &__add__(const iMS::kHz& f) {
            *self = *self + f / 1000.0; 
            return *self;
        }
        iMS::MHz &__add__(const iMS::Frequency& f) {
            *self = *self + f / 1000000.0; 
            return *self;
        }
        iMS::MHz &__iadd__(const iMS::MHz& f) {
            *self = *self + f; 
            return *self;
        }
        iMS::MHz &__iadd__(const iMS::kHz& f) {
            *self = *self + f / 1000.0; 
            return *self;
        }
        iMS::MHz &__iadd__(const iMS::Frequency& f) {
            *self = *self + f / 1000000.0; 
            return *self;
        }
        iMS::MHz &__sub__(const iMS::MHz& f) {
            *self = *self - f; 
            return *self;
        }
        iMS::MHz &__sub__(const iMS::kHz& f) {
            *self = *self - f / 1000.0; 
            return *self;
        }
        iMS::MHz &__sub__(const iMS::Frequency& f) {
            *self = *self - f / 1000000.0; 
            return *self;
        }
        iMS::MHz &__isub__(const iMS::MHz& f) {
            *self = *self - f; 
            return *self;
        }
        iMS::MHz &__isub__(const iMS::kHz& f) {
            *self = *self - f / 1000.0; 
            return *self;
        }
        iMS::MHz &__isub__(const iMS::Frequency& f) {
            *self = *self - f / 1000000.0; 
            return *self;
        }
    }
  };

  %ignore Percent::operator=;
  %ignore Percent::operator double;
  class Percent
  {
  public:
    Percent();
    Percent(double arg);
    Percent& operator = (double arg);
    operator double() const;
  };

  %ignore Degrees::operator=;
  %ignore Degrees::operator double;
  class Degrees
  {
  public:
    Degrees(double arg);
    Degrees& operator = (double arg);
    operator double() const;
  };

  struct FAP
  {
    MHz freq;
    Percent ampl;
    Degrees phase;

    FAP();
    FAP(double f, double a, double p);
    FAP(MHz f, Percent a, Degrees p);

    bool operator==(const FAP &other) const;
    bool operator!=(const FAP &other) const;
  };

      %extend FAP {
        std::string __str__() {
            std::ostringstream oss;
            oss << $self->freq << "MHz / " << $self->ampl << "% / " << $self->phase << "deg";
            return oss.str();
        }
        // Copy constructor
        FAP(FAP& other) {
            FAP* newFAP = new FAP();
            newFAP->freq = other.freq;
            newFAP->ampl = other.ampl;
            newFAP->phase = other.phase;
            return newFAP;
        }
    }

//  %rename(__set__) RFChannel::operator=;
//  %rename(__val__) RFChannel::operator int;
%ignore RFChannel::operator=;
%ignore RFChannel::operator int;

   %rename(incr) RFChannel::operator++();
   %ignore RFChannel::operator++(int);
   %rename(decr) RFChannel::operator--();
   %ignore RFChannel::operator--(int);

  class RFChannel {
  public:
    RFChannel();
//    RFChannel(int arg);
    RFChannel& operator = (int arg);
    RFChannel& operator++();
    RFChannel operator++(int);
    RFChannel& operator--();
    RFChannel operator--(int);
    operator int() const;
    bool IsAll() const;
    static const int min;
    static const int max;
    static const int all;
  };

  %extend RFChannel {
    RFChannel(int val) {
        if (val != RFChannel::all) {
            val = (val < RFChannel::min) ? RFChannel::min : (val > RFChannel::max) ? RFChannel::max : val;
        }
        RFChannel* obj = new RFChannel(val);
        return obj;
    }

    int __int__() {
        return (int)*$self;
    }

    int __index__() {
        return (int)*$self;
    }

    // Optional: define __str__ for debugging
    std::string __str__() {
        std::ostringstream oss;
        oss << "RFChannel(" << (int)*$self << ")";
        return oss.str();
    }
    %pythoncode %{
        def __iter__(self):
            return iter(range(RFChannel.min, RFChannel.max + 1))
    %}
    RFChannel __add__(int delta) {
        int val = *$self + delta;
        val = (val < RFChannel::min) ? RFChannel::min : (val > RFChannel::max) ? RFChannel::max : val;
        return RFChannel(val);
    }

    RFChannel __sub__(int delta) {
        int val = *$self - delta;
        val = (val < RFChannel::min) ? RFChannel::min : (val > RFChannel::max) ? RFChannel::max : val;
        return RFChannel(val);
    }
    
    RFChannel __iadd__(int delta) {
        int val = *$self + delta;
        val = (val < RFChannel::min) ? RFChannel::min : (val > RFChannel::max) ? RFChannel::max : val;
        return RFChannel(val);
    }

    RFChannel __isub__(int delta) {
        int val = *$self - delta;
        val = (val < RFChannel::min) ? RFChannel::min : (val > RFChannel::max) ? RFChannel::max : val;
        return RFChannel(val);
    }

    RFChannel next() {
        return ++(*$self);
    }

    RFChannel prev() {
        return --(*$self);
    }

    void reset() {
        *$self = RFChannel::min;
    }

    bool __eq__(const RFChannel& other) {
        return int(*$self) == int(other);
    }

    bool __lt__(const RFChannel& other) {
        return int(*$self) < int(other);
    }
  }

  enum class ENHANCED_TONE_MODE
  {
    NO_SWEEP,
      FREQUENCY_DWELL,
      FREQUENCY_NO_DWELL,
      FREQUENCY_FAST_MOD,
      PHASE_DWELL,
      PHASE_NO_DWELL,
      PHASE_FAST_MOD
      };

  enum class DAC_CURRENT_REFERENCE
  {
    FULL_SCALE,
      HALF_SCALE,
      QUARTER_SCALE,
      EIGHTH_SCALE
      };
}

%attributeref(iMS::SweepTone, iMS::FAP&, start, start);
%attributeref(iMS::SweepTone, iMS::FAP&, end, end);
%attributeref(iMS::SweepTone, %arg(std::chrono::duration<double, std::ratio<1> >&), up_ramp, up_ramp);
%attributeref(iMS::SweepTone, %arg(std::chrono::duration<double, std::ratio<1> >&), down_ramp, down_ramp);
%attributeref(iMS::SweepTone, int, n_steps, n_steps);
%attributeref(iMS::SweepTone, iMS::ENHANCED_TONE_MODE, mode, mode);
%attributeref(iMS::SweepTone, iMS::DAC_CURRENT_REFERENCE, scaling, scaling);

namespace iMS {

  struct SweepTone 
  {
    FAP& start(); 
    FAP& end();
    std::chrono::duration<double, std::ratio<1> >& up_ramp();
    std::chrono::duration<double, std::ratio<1> >& down_ramp();
    int& n_steps();
    ENHANCED_TONE_MODE& mode();
    DAC_CURRENT_REFERENCE& scaling();

    SweepTone();
    SweepTone(FAP tone);
    SweepTone(FAP start, FAP end, std::chrono::duration<double> up, std::chrono::duration<double> down, int steps, ENHANCED_TONE_MODE mode, DAC_CURRENT_REFERENCE scaling);
    SweepTone(const SweepTone &);
    //    SweepTone &operator =(const SweepTone &);
  };

}

%attribute_custom(iMS::distance<std::ratio<1>>, double, value, GetValue, SetValue, (*self_), (*self_)=val_);
%attribute_custom(iMS::distance<std::nano>, double, value, GetValue, SetValue, (*self_), (*self_)=val_);
%attribute_custom(iMS::distance<std::micro>, double, value, GetValue, SetValue, (*self_), (*self_)=val_);
%attribute_custom(iMS::distance<std::milli>, double, value, GetValue, SetValue, (*self_), (*self_)=val_);
%attribute_custom(iMS::distance<std::centi>, double, value, GetValue, SetValue, (*self_), (*self_)=val_);
%attribute_custom(iMS::distance<std::deci>, double, value, GetValue, SetValue, (*self_), (*self_)=val_);

namespace iMS {

  %ignore distance::operator=;
  %ignore distance::operator double;

  template <typename Ratio>
    class distance {
  public:

    distance(double ticks = 1.0);
    template <typename Ratio2>
      distance(distance<Ratio2> other);

    distance& operator = (double arg);
    operator double() const;
  };
  
  template <typename Ratio1, typename Ratio2>
    bool operator==(distance<Ratio1> d1, distance<Ratio2> d2);
}

%template(Metre) iMS::distance<std::ratio<1>>;
%template(Nanometre) iMS::distance<std::nano>;
%template(Micrometre) iMS::distance<std::micro>;
%template(Millimetre) iMS::distance<std::milli>;
%template(Centimetre) iMS::distance<std::centi>;
%template(Decimetre) iMS::distance<std::deci>;

 enum class Polarity {
  NORMAL,
	INVERSE
	};