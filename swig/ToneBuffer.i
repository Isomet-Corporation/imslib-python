%include <std_shared_ptr.i>

%attribute_custom(iMS::TBEntry, MHz, FreqCh1, GetFreqCh1, SetFreqCh1, &self_->GetFAP(RFChannel(1)).freq, {\
    FAP temp = self_->GetFAP(RFChannel(1));\
    temp.freq = *val_;\
    self_->SetFAP(RFChannel(1), temp);\
  });
%typemap(csvarin, excode=SWIGEXCODE2) MHz FreqCh1 %{
  set {
    $imcall;$excode 
    this.NotifyPropertyChanged("FreqCh1");
  }
%}
%attribute_custom(iMS::TBEntry, Percent, AmplCh1, GetAmplCh1, SetAmplCh1, &self_->GetFAP(RFChannel(1)).ampl, {\
    FAP temp = self_->GetFAP(RFChannel(1));\
    temp.ampl = *val_;\
    self_->SetFAP(RFChannel(1), temp);\
  });
%typemap(csvarin, excode=SWIGEXCODE2) Percent AmplCh1 %{
  set {
    $imcall;$excode 
    this.NotifyPropertyChanged("AmplCh1");
  }
%}
%attribute_custom(iMS::TBEntry, Degrees, PhaseCh1, GetPhaseCh1, SetPhaseCh1, &self_->GetFAP(RFChannel(1)).phase, {\
    FAP temp = self_->GetFAP(RFChannel(1));\
    temp.phase = *val_;\
    self_->SetFAP(RFChannel(1), temp);\
  });
%typemap(csvarin, excode=SWIGEXCODE2) Degrees PhaseCh1 %{
  set {
    $imcall;$excode 
    this.NotifyPropertyChanged("PhaseCh1");
  }
%}
%attribute_custom(iMS::TBEntry, MHz, FreqCh2, GetFreqCh2, SetFreqCh2, &self_->GetFAP(RFChannel(2)).freq, {\
    FAP temp = self_->GetFAP(RFChannel(2));\
    temp.freq = *val_;\
    self_->SetFAP(RFChannel(2), temp);\
  });
%typemap(csvarin, excode=SWIGEXCODE2) MHz FreqCh2 %{
  set {
    $imcall;$excode 
    this.NotifyPropertyChanged("FreqCh2");
  }
%}
%attribute_custom(iMS::TBEntry, Percent, AmplCh2, GetAmplCh2, SetAmplCh2, &self_->GetFAP(RFChannel(2)).ampl, {\
    FAP temp = self_->GetFAP(RFChannel(2));\
    temp.ampl = *val_;\
    self_->SetFAP(RFChannel(2), temp);\
  });
%typemap(csvarin, excode=SWIGEXCODE2) Percent AmplCh2 %{
  set {
    $imcall;$excode 
    this.NotifyPropertyChanged("AmplCh2");
  }
%}
%attribute_custom(iMS::TBEntry, Degrees, PhaseCh2, GetPhaseCh2, SetPhaseCh2, &self_->GetFAP(RFChannel(2)).phase, {\
    FAP temp = self_->GetFAP(RFChannel(2));\
    temp.phase = *val_;\
    self_->SetFAP(RFChannel(2), temp);\
  });
%typemap(csvarin, excode=SWIGEXCODE2) Degrees PhaseCh2 %{
  set {
    $imcall;$excode 
    this.NotifyPropertyChanged("PhaseCh2");
  }
%}
%attribute_custom(iMS::TBEntry, MHz, FreqCh3, GetFreqCh3, SetFreqCh3, &self_->GetFAP(RFChannel(3)).freq, {\
    FAP temp = self_->GetFAP(RFChannel(3));\
    temp.freq = *val_;\
    self_->SetFAP(RFChannel(3), temp);\
  });
%typemap(csvarin, excode=SWIGEXCODE2) MHz FreqCh3 %{
  set {
    $imcall;$excode 
    this.NotifyPropertyChanged("FreqCh3");
  }
%}
%attribute_custom(iMS::TBEntry, Percent, AmplCh3, GetAmplCh3, SetAmplCh3, &self_->GetFAP(RFChannel(3)).ampl, {\
    FAP temp = self_->GetFAP(RFChannel(3));\
    temp.ampl = *val_;\
    self_->SetFAP(RFChannel(3), temp);\
  });
%typemap(csvarin, excode=SWIGEXCODE2) Percent AmplCh3 %{
  set {
    $imcall;$excode 
    this.NotifyPropertyChanged("AmplCh3");
  }
%}
%attribute_custom(iMS::TBEntry, Degrees, PhaseCh3, GetPhaseCh3, SetPhaseCh3, &self_->GetFAP(RFChannel(3)).phase, {\
    FAP temp = self_->GetFAP(RFChannel(3));\
    temp.phase = *val_;\
    self_->SetFAP(RFChannel(3), temp);\
  });
%typemap(csvarin, excode=SWIGEXCODE2) Degrees PhaseCh3 %{
  set {
    $imcall;$excode 
    this.NotifyPropertyChanged("PhaseCh3");
  }
%}
%attribute_custom(iMS::TBEntry, MHz, FreqCh4, GetFreqCh4, SetFreqCh4, &self_->GetFAP(RFChannel(4)).freq, {\
    FAP temp = self_->GetFAP(RFChannel(4));\
    temp.freq = *val_;\
    self_->SetFAP(RFChannel(4), temp);\
  });
%typemap(csvarin, excode=SWIGEXCODE2) MHz FreqCh4 %{
  set {
    $imcall;$excode 
    this.NotifyPropertyChanged("FreqCh4");
  }
%}
%attribute_custom(iMS::TBEntry, Percent, AmplCh4, GetAmplCh4, SetAmplCh4, &self_->GetFAP(RFChannel(4)).ampl, {\
    FAP temp = self_->GetFAP(RFChannel(4));\
    temp.ampl = *val_;\
    self_->SetFAP(RFChannel(4), temp);\
  });
%typemap(csvarin, excode=SWIGEXCODE2) Percent AmplCh4 %{
  set {
    $imcall;$excode 
    this.NotifyPropertyChanged("AmplCh4");
  }
%}
%attribute_custom(iMS::TBEntry, Degrees, PhaseCh4, GetPhaseCh4, SetPhaseCh4, &self_->GetFAP(RFChannel(4)).phase, {\
    FAP temp = self_->GetFAP(RFChannel(4));\
    temp.phase = *val_;\
    self_->SetFAP(RFChannel(4), temp);\
  });
%typemap(csvarin, excode=SWIGEXCODE2) Degrees PhaseCh4 %{
  set {
    $imcall;$excode 
    this.NotifyPropertyChanged("PhaseCh4");
  }
%}
namespace iMS {
  //typedef ImagePoint TBEntry;

  enum class ToneBufferEvents
  {
    DOWNLOAD_FINISHED,
    DOWNLOAD_ERROR
  };
  
  %rename(__eq__) TBEntry::operator==;
  %typemap(csinterfaces) TBEntry "System.IDisposable, System.ComponentModel.INotifyPropertyChanged";
  class TBEntry
  {
    %typemap(cscode) TBEntry %{
      public event System.ComponentModel.PropertyChangedEventHandler PropertyChanged;

      public void NotifyPropertyChanged(string propName)
      {
	if(this.PropertyChanged != null)
	  this.PropertyChanged(this, new System.ComponentModel.PropertyChangedEventArgs(propName));
      }
    %}
  public:
    TBEntry();
    TBEntry(FAP fap);
    TBEntry(FAP ch1, FAP ch2, FAP ch3, FAP ch4);
    //    TBEntry(FAP fap, float synca, unsigned int syncd);
    //    TBEntry(FAP ch1, FAP ch2, FAP ch3, FAP ch4, float synca_1, float synca_2, unsigned int syncd);
    
    bool operator==(TBEntry const& rhs) const;
    const FAP& GetFAP(const RFChannel) const;
    void SetFAP(const RFChannel, const FAP&);
    //FAP& SetFAP(const RFChannel);
    void SetAll(const FAP&);
    /*const float& GetSyncA(int index);
    void SetSyncA(int index, float value);
    const unsigned int& GetSyncD() const;
    void SetSyncD(unsigned int);*/
  };

}

%template(TBArray) std::array<iMS::TBEntry, 256>;
%attributeref(iMS::ToneBuffer, std::string, Name, Name);
%attribute2(iMS::ToneBuffer, %arg(const std::array<uint8_t, 16>), GetUUID, UUID);

namespace iMS {

  %rename(__eq__) ToneBuffer::operator==;
  %ignore ToneBuffer::operator=;
  %typemap(csinterfaces) ToneBuffer "System.IDisposable, System.Collections.IEnumerable";
  class ToneBuffer {
    %typemap(cscode) ToneBuffer %{
      public $csclassname(System.Collections.ICollection c) : this() {
	if (c == null)
	  throw new System.ArgumentNullException("c");
	int i = 0;
	foreach (TBEntry element in c)
	  {
	    this.setitem(i, element);
	  }
      }
      
      public bool IsFixedSize {
	get {
	  return true;
	}
      }
      
      public bool IsReadOnly {
	get {
	  return false;
	}
      }
      
      public TBEntry this[int index]  {
	get {
	  return getitem(index);
	}
	set {
	  setitem(index, value);
	}
      }
      
      public int Count {
	get {
	  return (int)Size();
	}
      }
      
      public bool IsSynchronized {
	get {
	  return false;
	}
      }
      
      public void CopyTo(TBEntry[] array)
      {
	CopyTo(0, array, 0, this.Count);
      }
      
      public void CopyTo(TBEntry[] array, int arrayIndex)
      {
	CopyTo(0, array, arrayIndex, this.Count);
      }
      
      public void CopyTo(int index, TBEntry[] array, int arrayIndex, int count)
      {
	if (array == null)
	  throw new System.ArgumentNullException("array");
	if (index < 0)
	  throw new System.ArgumentOutOfRangeException("index", "Value is less than zero");
	if (arrayIndex < 0)
	  throw new System.ArgumentOutOfRangeException("arrayIndex", "Value is less than zero");
	if (count < 0)
	  throw new System.ArgumentOutOfRangeException("count", "Value is less than zero");
	if (array.Rank > 1)
	  throw new System.ArgumentException("Multi dimensional array.", "array");
	if (index+count > this.Count || arrayIndex+count > array.Length)
	  throw new System.ArgumentException("Number of elements to copy is too large.");
	for (int i=0; i<count; i++)
	  array.SetValue(getitemcopy(index+i), arrayIndex+i);
      }
      
      System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator() {
	return new $csclassnameEnumerator(this);
      }
      
      public $csclassnameEnumerator GetEnumerator() {
	return new $csclassnameEnumerator(this);
      }
      
      // Type-safe enumerator
      /// Note that the IEnumerator documentation requires an InvalidOperationException to be thrown
      /// whenever the collection is modified. This has been done for changes in the size of the
      /// collection but not when one of the elements of the collection is modified as it is a bit
      /// tricky to detect unmanaged code that modifies the collection under our feet.
      public sealed class $csclassnameEnumerator : System.Collections.IEnumerator
	, System.Collections.Generic.IEnumerator<TBEntry>
	{
	  private $csclassname collectionRef;
	  private int currentIndex;
	  private object currentObject;
	  private int currentSize;
	  
	  public $csclassnameEnumerator($csclassname collection) {
	    collectionRef = collection;
	    currentIndex = -1;
	    currentObject = null;
	    currentSize = collectionRef.Count;
	  }
	  
	  // Type-safe iterator Current
	  public TBEntry Current {
	    get {
	      if (currentIndex == -1)
		throw new System.InvalidOperationException("Enumeration not started.");
	      if (currentIndex > currentSize - 1)
		throw new System.InvalidOperationException("Enumeration finished.");
	      if (currentObject == null)
		throw new System.InvalidOperationException("Collection modified.");
	      return (TBEntry)currentObject;
	    }
	  }
	  
	  private System.Collections.IEnumerator GetEnumerator()
	  {
	    return (System.Collections.IEnumerator)this;
	  }
	  
	  // Type-unsafe IEnumerator.Current
	  object System.Collections.IEnumerator.Current {
	    get {
	      return Current;
	    }
	  }
	  
	  public bool MoveNext() {
	    int size = collectionRef.Count;
	    bool moveOkay = (currentIndex+1 < size) && (size == currentSize);
	    if (moveOkay) {
	      currentIndex++;
	      currentObject = collectionRef[currentIndex];
	    } else {
	      currentObject = null;
	    }
	    return moveOkay;
	  }
	  
	  public void Reset() {
	    currentIndex = -1;
	    currentObject = null;
	    if (collectionRef.Count != currentSize) {
	      throw new System.InvalidOperationException("Collection modified.");
	    }
	  }
	  
	  public void Dispose() {
	    currentIndex = -1;
	    currentObject = null;
	  }
	}
      %}
    
  public:
    %extend {
      TBEntry getitemcopy(int index) throw (std::out_of_range) {
        if (index>=0 && index<(int)$self->Size())
          return (*$self)[(std::size_t)index];
        else
          throw std::out_of_range("index");
      }
      const TBEntry& getitem(int index) throw (std::out_of_range) {
        if (index>=0 && index<(int)$self->Size())
          return (*$self)[(std::size_t)index];
        else
          throw std::out_of_range("index");
      }
      void setitem(int index, const TBEntry& val) throw (std::out_of_range) {
        if (index>=0 && index<(int)$self->Size())
          *((*$self).begin() + index) = val;
        else
          throw std::out_of_range("index");
      }
    }    
    
    //    typedef TBArray::iterator iterator;
    //    typedef TBArray::const_iterator const_iterator;
    ToneBuffer();
    ToneBuffer(const TBEntry& tbe);
    ToneBuffer(const int entry);
    ToneBuffer(const ToneBuffer &);
    ToneBuffer &operator =(const ToneBuffer &);
    //    iterator begin();
    //    iterator end();
    //		const_iterator begin() const;
    //		const_iterator end() const;
    //    const_iterator cbegin() const;
    //    const_iterator cend() const;
    const std::array<std::uint8_t, 16> UUID() const;
    
    //const TBEntry& operator[](std::size_t idx) const;
    //TBEntry& operator[](std::size_t idx);
    bool operator==(ToneBuffer const& rhs) const;
    const std::size_t Size() const;
  };

}

namespace iMS {

  class ToneBufferDownload
  {
  public:
    ToneBufferDownload(IMSSystem& ims, const ToneBuffer& tbl);
    bool StartDownload();
    //    bool StartDownload(ToneBuffer::const_iterator first, ToneBuffer::const_iterator last);
    //    bool StartDownload(ToneBuffer::const_iterator single);
    bool StartVerify();
    int GetVerifyError();
    void ToneBufferDownloadEventSubscribe(const int message, IEventHandler* handler);
    void ToneBufferDownloadEventUnsubscribe(const int message, const IEventHandler* handler);
    const FileSystemIndex Store(const std::string& FileName, FileDefault def = FileDefault::NON_DEFAULT) const;	
  };

}

%shared_ptr(iMS::ToneSequenceEntry)

namespace iMS {

  %ignore ToneSequenceEntry::operator=;
  %rename(__eq__) ToneSequenceEntry::operator==;
  struct ToneSequenceEntry : iMS::SequenceEntry
  {
    ToneSequenceEntry();
    ToneSequenceEntry(const ToneBuffer& tb, iMS::SignalPath::ToneBufferControl tbc = iMS::SignalPath::ToneBufferControl::HOST, const unsigned int initial_index = 0);
    /// \brief Copy Constructor
    ToneSequenceEntry(const ToneSequenceEntry&);
    /// \brief Assignment Constructor
    ToneSequenceEntry& operator =(const ToneSequenceEntry&);
    ToneSequenceEntry(const SequenceEntry& entry);
    //    ~ToneSequenceEntry();

    bool operator==(SequenceEntry const& rhs) const;
    
    iMS::SignalPath::ToneBufferControl ControlSource() const;
    int InitialIndex() const;
  };
}
