
namespace iMS {
    enum class ToneBufferEvents
    {
        DOWNLOAD_FINISHED,
        DOWNLOAD_ERROR
    };

    using TBEntry = ImagePoint;

    // In Python, return an ImagePoint object when a TBEntry is created
    %pythoncode %{
    def TBEntry(*args, **kwargs):
        return ImagePoint(*args, **kwargs)     
    %}
}

%attributeref(iMS::ToneBuffer, std::string, Name, Name);
%attribute2(iMS::ToneBuffer, %arg(const std::array<uint8_t, 16>), GetUUID, UUID);

namespace iMS {

    %extend ToneBuffer {
        TBEntry &_getitem(size_t i) {
            if (i >= $self->Size())
                throw std::out_of_range("ToneBuffer index out of range");
            return (*$self)[i];
        }

        void __setitem__(size_t i, const TBEntry &val) {
            if (i >= $self->Size())
                throw std::out_of_range("ToneBuffer index out of range");
            (*$self)[i] = val;
        }

        size_t __len__() {
            return $self->Size();
        }

        %pythoncode %{
            def __iter__(self):
                for i in range(len(self)):
                    yield self[i]
            def __getitem__(self, idx):
                if isinstance(idx, slice):
                    return [self[i] for i in range(*idx.indices(len(self)))]
                else:
                    if idx < 0: idx += len(self)
                    if idx < 0 or idx >= len(self):
                        raise IndexError("ToneBuffer index out of range")
                    return self._getitem(idx)
        %}
    }

  %rename(__eq__) ToneBuffer::operator==;
  %ignore ToneBuffer::operator=;
  class ToneBuffer {
  public:
    ToneBuffer(const std::string& name = "");
    ToneBuffer(const TBEntry& tbe, const std::string& name = "");
    ToneBuffer(const int entry, const std::string& name = "");
    ToneBuffer(const ToneBuffer &);
    ToneBuffer &operator =(const ToneBuffer &);

    const std::array<std::uint8_t, 16> UUID() const;
    
    //const TBEntry& operator[](std::size_t idx) const;
    //TBEntry& operator[](std::size_t idx);
    bool operator==(ToneBuffer const& rhs) const;
    const std::size_t Size() const;
    const std::string& Name() const;
    std::string& Name();
  };

}

namespace iMS {

    %rename(StartDownloadAll) ToneBufferDownload::StartDownload();
    %rename(StartDownloadIndex) ToneBufferDownload::StartDownload(std::size_t index);
    %rename(StartDownloadRange) ToneBufferDownload::StartDownload(std::size_t index, std::size_t count);
    
    %extend ToneBufferDownload {
        %pythoncode %{
            def StartDownload(self, arg1=None, arg2=None):
                """
                Pythonic StartDownload overloads:
                - StartDownload()               → full buffer
                - StartDownload(index)          → single element
                - StartDownload(start, end)     → range
                - StartDownload(slice)          → slice range
                """

                if arg1 is None:
                    return _imslib.ToneBufferDownload_StartDownloadAll(self)

                elif isinstance(arg1, int) and arg2 is None:
                    return _imslib.ToneBufferDownload_StartDownloadIndex(self, arg1)

                elif isinstance(arg1, int) and isinstance(arg2, int):
                    return _imslib.ToneBufferDownload_StartDownloadRange(self, arg1, arg2)

                elif isinstance(arg1, slice):
                    start, stop, step = arg1.indices(256)
                    if step != 1:
                        raise ValueError("Step slicing not supported")
                    return _imslib.ToneBufferDownload_StartDownloadRange(self, start, (stop - start))

                else:
                    raise TypeError("Invalid arguments for StartDownload")
        %}
    }

  class ToneBufferDownload
  {
  public:
    ToneBufferDownload(std::shared_ptr<IMSSystem> ims, const ToneBuffer& tbl);
    bool StartDownload();
    bool StartDownload(std::size_t index, std::size_t count);
    bool StartDownload(std::size_t index);
    //    bool StartDownload(ToneBuffer::const_iterator first, ToneBuffer::const_iterator last);
    //    bool StartDownload(ToneBuffer::const_iterator single);
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
