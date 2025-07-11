//%attribute_custom(iMS::Frequency, double, Value, GetValue, SetValue, (*self_), (*self_)=val_);
//%attribute_custom(iMS::kHz, double, Value, GetValue, SetValue, (*self_), (*self_)=val_);
//%attribute_custom(iMS::MHz, double, Value, GetValue, SetValue, (*self_), (*self_)=val_);
//%attribute_custom(iMS::Percent, double, Value, GetValue, SetValue, (*self_), (*self_)=val_);
//%attribute_custom(iMS::Degrees, double, Value, GetValue, SetValue, (*self_), (*self_)=val_);

namespace iMS {

  //  %rename(__set__) Frequency::operator=;
  //  %rename(__val__) Frequency::operator double;
  %ignore Frequency::operator=;
  %ignore Frequency::operator double;
  %typemap(csinterfaces) Frequency "System.IDisposable, System.ComponentModel.INotifyPropertyChanged";

  class Frequency 
  {
    %typemap(cscode) Frequency %{
      public event System.ComponentModel.PropertyChangedEventHandler PropertyChanged;

      public void NotifyPropertyChanged(string propName)
      {
	if(this.PropertyChanged != null)
	  this.PropertyChanged(this, new System.ComponentModel.PropertyChangedEventArgs(propName));
      }

      public override string ToString()
      {
	return this.Value.ToString();
      }

      public virtual double Value
      {
	get {
	  return getvalue();
	}
	set {
	  setvalue(value);
	  this.NotifyPropertyChanged("Value");
	}
      }

    %}
  public:
    %extend {
      double getvalue() {
	return *self;
      }
      void setvalue(double val) {
	*self = val;
      }
    }
    Frequency(double arg);
    Frequency& operator = (double arg);
    operator double() const;
  };

  //  %rename(__set__) kHz::operator=;
  //  %rename(__val__) kHz::operator double;
  class kHz : public Frequency 
  {
    %typemap(cscode) kHz %{
      public override double Value
      {
	get {
	  return getvalue();
	}
	set {
	  setvalue(value);
	  this.NotifyPropertyChanged("Value");
	}
      }

    %}
  public:
    %extend {
      double getvalue() {
	return *self;
      }
      void setvalue(double val) {
	*self = val;
      }
    }
    kHz(double arg) : Frequency(arg * 1000.0) {};
    kHz& operator = (double arg);
    operator double() const;
  };

  //  %rename(__set__) MHz::operator=;
  //  %rename(__val__) MHz::operator double;
  class MHz : public Frequency 
  {
    %typemap(cscode) MHz %{
      public override double Value
      {
	get {
	  return getvalue();
	}
	set {
	  setvalue(value);
	  this.NotifyPropertyChanged("Value");
	}
      }

    %}
  public:
    %extend {
      double getvalue() {
	return *self;
      }
      void setvalue(double val) {
	*self = val;
      }
    }
    MHz(double arg) : Frequency(arg * 1000000.0) {};
    MHz& operator = (double arg);
    operator double() const;
  };

  //  %rename(__set__) Percent::operator=;
  //  %rename(__val__) Percent::operator double;
  %ignore Percent::operator=;
  %ignore Percent::operator double;
  class Percent
  {
    %typemap(cscode) Percent %{
      public event System.ComponentModel.PropertyChangedEventHandler PropertyChanged;

      public void NotifyPropertyChanged(string propName)
      {
	if(this.PropertyChanged != null)
	  this.PropertyChanged(this, new System.ComponentModel.PropertyChangedEventArgs(propName));
      }

      public override string ToString()
      {
	return this.Value.ToString();
      }
    %}
  public:
    Percent();
    Percent(double arg);
    Percent& operator = (double arg);
    operator double() const;
  };

  //  %rename(__set__) Degrees::operator=;
  //  %rename(__val__) Degrees::operator double;
  %ignore Degrees::operator=;
  %ignore Degrees::operator double;
  class Degrees
  {
    %typemap(cscode) Degrees %{
      public event System.ComponentModel.PropertyChangedEventHandler PropertyChanged;

      public void NotifyPropertyChanged(string propName)
      {
	if(this.PropertyChanged != null)
	  this.PropertyChanged(this, new System.ComponentModel.PropertyChangedEventArgs(propName));
      }

      public override string ToString()
      {
	return this.Value.ToString();
      }
    %}
  public:
    Degrees(double arg);
    Degrees& operator = (double arg);
    operator double() const;
  };

  %rename(__eq__) FAP::operator==;
  %rename(__ne__) FAP::operator!=;
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

  %rename(__set__) RFChannel::operator=;
  %rename(__val__) RFChannel::operator int;
  %rename(PlusPlusPrefix) RFChannel::operator++();
  %rename(PlusPlusPostfix) RFChannel::operator++(int);
  %rename(MinusMinusPrefix) RFChannel::operator--();
  %rename(MinusMinusPostfix) RFChannel::operator--(int);

  class RFChannel {
  public:
    RFChannel();
    RFChannel(int arg);
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

//%attributeref(iMS::SweepTone, iMS::FAP&, start, start);
//%attributeref(iMS::SweepTone, iMS::FAP&, end, end);
//%attributeref(iMS::SweepTone, %arg(std::chrono::duration<double, std::ratio<1> >&), up_ramp, up_ramp);
//%attributeref(iMS::SweepTone, %arg(std::chrono::duration<double, std::ratio<1> >&), down_ramp, down_ramp);
//%attributeref(iMS::SweepTone, int, n_steps, n_steps);
//%attributeref(iMS::SweepTone, iMS::ENHANCED_TONE_MODE, mode, mode);
//%attributeref(iMS::SweepTone, iMS::DAC_CURRENT_REFERENCE, scaling, scaling);

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

//%attribute_custom(iMS::distance, double, Value, GetValue, SetValue, (*self_), (*self_)=val_);

namespace iMS {

  %ignore distance::operator=;
  %ignore distance::operator double;

  template <typename Ratio>
    class distance {
    %typemap(cscode) distance %{
      public event System.ComponentModel.PropertyChangedEventHandler PropertyChanged;

      public void NotifyPropertyChanged(string propName)
      {
	if(this.PropertyChanged != null)
	  this.PropertyChanged(this, new System.ComponentModel.PropertyChangedEventArgs(propName));
      }

      public override string ToString()
      {
	return this.Value.ToString();
      }

      public virtual double Value
      {
	get {
	  return getvalue();
	}
	set {
	  setvalue(value);
	  this.NotifyPropertyChanged("Value");
	}
      }

    %}
  public:
    %extend {
      double getvalue() {
	return *self;
      }
      void setvalue(double val) {
	*self = val;
      }
    }

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

	// Capture the US spellings!
//%template(Meter) iMS::distance<std::ratio<1>>;
//%template(Nanometer) iMS::distance<std::nano>;
//%template(Micrometer) iMS::distance<std::micro>;
//%template(Millimeter) iMS::distance<std::milli>;
//%template(Centimeter) iMS::distance<std::centi>;
//%template(Decimeter) iMS::distance<std::deci>;
//%alias(Meter) Metre;
//%alias(Nanometer) Nanometre;
//%alias(Micrometer) Micrometre;
//%alias(Millimeter) Millimetre;
//%alias(Centimeter) Centimetre;
//%alias(Decimeter) Decimetre;

 enum class Polarity {
  NORMAL,
	INVERSE
	};