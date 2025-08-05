%{
#include <sstream>
%}

namespace iMS {

    class DownloadEvents {
        enum Events {
            DOWNLOAD_FINISHED,
            DOWNLOAD_ERROR,
            VERIFY_SUCCESS,
            VERIFY_FAIL,
            DOWNLOAD_FAIL_MEMORY_FULL,
            DOWNLOAD_FAIL_TRANSFER_ABORT
        };
    };

  using ImageDownloadEvents = DownloadEvents;
  using SequenceDownloadEvents = DownloadEvents;
}

namespace iMS {

  class ImageDownload 
  {
  public:
    ImageDownload(IMSSystem& ims, const Image& img);
    bool StartDownload();
    bool StartVerify();
    int GetVerifyError();
    void ImageDownloadEventSubscribe(const int message, IEventHandler* handler);
    void ImageDownloadEventUnsubscribe(const int message, const IEventHandler* handler);
  };

}

namespace iMS {

    class ImagePlayerEvents {
        static enum ImagePlayerEvents {
            POINT_PROGRESS,
            IMAGE_STARTED,
            IMAGE_FINISHED
        };
    };

}

//%include "ims_std_chrono.i"

    %inline %{
    namespace iMS {
    struct ImagePlayerConfiguration
    {
      ImagePlayer::PointClock int_ext{ ImagePlayer::PointClock::INTERNAL };
      ImagePlayer::ImageTrigger trig{ ImagePlayer::ImageTrigger::CONTINUOUS };
      ImageRepeats rpts{ ImageRepeats::NONE };
      int n_rpts{ 0 };
      Polarity clk_pol{ Polarity::NORMAL };
      Polarity trig_pol{ Polarity::NORMAL };
      
      using post_delay = std::chrono::duration < std::uint16_t, std::ratio<1, 10000> > ;
      post_delay delay{ 0 };
      
      ImagePlayerConfiguration() {};
      ImagePlayerConfiguration(ImagePlayer::PointClock c) : int_ext(c) {};
      ImagePlayerConfiguration(ImagePlayer::PointClock c, ImagePlayer::ImageTrigger t) : int_ext(c), trig(t) {};
      ImagePlayerConfiguration(ImagePlayer::PointClock c, const std::chrono::duration<int>& d) : int_ext(c), trig(ImagePlayer::ImageTrigger::POST_DELAY), delay(std::chrono::duration_cast<post_delay>(d)) {};
      ImagePlayerConfiguration(ImagePlayer::PointClock c, const std::chrono::duration<int>& d, ImageRepeats r, int n_rpts) : int_ext(c), trig(ImagePlayer::ImageTrigger::POST_DELAY), rpts(r), n_rpts(n_rpts), delay(std::chrono::duration_cast<post_delay>(d)) {};
      ImagePlayerConfiguration(ImageRepeats r) : rpts(r) {};
      ImagePlayerConfiguration(ImageRepeats r, int n_rpts) : rpts(r), n_rpts(n_rpts) {};
    };
    }
    %}

        // Create a typemap to translate the real nested struct to the dummy exposed one
    %typemap(out) iMS::ImagePlayer::PlayConfiguration {
        auto* cfgPtr = new iMS::ImagePlayerConfiguration();
        cfgPtr->int_ext = $1.int_ext;
        cfgPtr->trig = $1.trig;
        cfgPtr->rpts = $1.rpts;
        cfgPtr->n_rpts = $1.n_rpts;
        cfgPtr->clk_pol = $1.clk_pol;
        cfgPtr->trig_pol = $1.trig_pol;
        cfgPtr->delay = $1.del;
        $result = SWIG_NewPointerObj(cfgPtr, SWIGTYPE_p_iMS__ImagePlayerConfiguration, SWIG_POINTER_OWN);
    }    

    %typemap(in) const iMS::ImagePlayer::PlayConfiguration& {
        iMS::ImagePlayerConfiguration* pycfg = nullptr;
        void* ptr = nullptr;
        int res = SWIG_ConvertPtr($input, &ptr, SWIGTYPE_p_iMS__ImagePlayerConfiguration, 0);
        if (!SWIG_IsOK(res)) {
            SWIG_exception_fail(SWIG_ArgError(res), "Expected a ImagePlayerConfiguration");
        }
        pycfg = reinterpret_cast<iMS::ImagePlayerConfiguration*>(ptr);

        $1 = new iMS::ImagePlayer::PlayConfiguration();
        $1->int_ext = pycfg->int_ext;
        $1->trig = pycfg->trig;
        $1->rpts = pycfg->rpts;
        $1->n_rpts = pycfg->n_rpts;
        $1->clk_pol = pycfg->clk_pol;
        $1->trig_pol = pycfg->trig_pol;
        $1->del = pycfg->delay;
    }      

namespace iMS {

  class ImagePlayer
  {
  public:
    enum class PointClock {
      INTERNAL,
	EXTERNAL
	};
    enum class ImageTrigger {
      POST_DELAY,
	EXTERNAL,
	HOST,
	CONTINUOUS
	};
    enum class StopStyle {
      GRACEFULLY,
	IMMEDIATELY
	};
    
    ImagePlayer(const IMSSystem& ims, const Image& img);
    ImagePlayer(const IMSSystem& ims, const Image& img, const ImagePlayer::PlayConfiguration& cfg);
    ImagePlayer(const IMSSystem& ims, const ImageTableEntry& ite, const kHz InternalClock);
    ImagePlayer(const IMSSystem& ims, const ImageTableEntry& ite, const int ExtClockDivide);
    ImagePlayer(const IMSSystem& ims, const ImageTableEntry& ite, const ImagePlayer::PlayConfiguration& cfg, const kHz InternalClock);
    ImagePlayer(const IMSSystem& ims, const ImageTableEntry& ite, const ImagePlayer::PlayConfiguration& cfg, const int ExtClockDivide);
    
    bool Play(ImageTrigger start_trig);
    inline bool Play();
    bool GetProgress();
    bool Stop(StopStyle stop);
    inline bool Stop();
    void SetPostDelay(const std::chrono::duration<double>& dly);
    
    void ImagePlayerEventSubscribe(const int message, IEventHandler* handler);
    void ImagePlayerEventUnsubscribe(const int message, const IEventHandler* handler);
  };
  
  %extend ImagePlayer {
    ImagePlayerConfiguration get_cfg() const {
        ImagePlayerConfiguration py;
        py.int_ext = self->cfg.int_ext;
        py.trig = self->cfg.trig;
        py.rpts = self->cfg.rpts;
        py.n_rpts = self->cfg.n_rpts;
        py.clk_pol = self->cfg.clk_pol;
        py.trig_pol = self->cfg.trig_pol;
        py.delay = self->cfg.del;
        return py;
    }

    void set_cfg(const ImagePlayerConfiguration& py) {
        self->cfg.int_ext = py.int_ext;
        self->cfg.trig = py.trig;
        self->cfg.rpts = py.rpts;
        self->cfg.n_rpts = py.n_rpts;
        self->cfg.clk_pol = py.clk_pol;
        self->cfg.trig_pol = py.trig_pol;
        self->cfg.del = py.delay;
    }    

    %pythoncode %{
        Config = property(get_cfg, set_cfg)
    %}    
  }
}
//%attribute(iMS::ImagePlayer, iMS::ImagePlayerConfiguration, Config, get_cfg, set_cfg);

namespace iMS {
  
  class ImageTableViewer
  {
  public:
    %extend {
        ImageTableEntry __getitem__(size_t i) const {
            if (i<0 || i >= $self->Entries()) {
                throw std::out_of_range("Index out of range");
            }
            return (*$self)[i];
        }
        size_t __len__() {
            return $self->Entries();
        }

        bool __bool__() {
            return ($self->Entries() != 0);
        }

        %pythoncode %{
            def __str__(self):
                result = ""
                for i in range(len(self)):
                    result += str(self[i])
                return result

            def __iter__(self):
                for i in range(len(self)):
                    yield self[i]
        %}
    }
    ImageTableViewer(IMSSystem& ims);
    
    const int Entries() const;
    //const ImageTableEntry operator[](const std::size_t idx) const;
    bool Erase(const std::size_t idx);
    bool Erase(ImageTableEntry ite);
    bool Clear();
  };
  
}

// namespace iMS {

//   class SequenceDownload
//   {
//   public:
//     SequenceDownload(IMSSystem& ims, const ImageSequence& seq);
    
//     bool Download(bool asynchronous = false);
//     inline bool StartDownload();
//     void SequenceDownloadEventSubscribe(const int message, IEventHandler* handler);
//     void SequenceDownloadEventUnsubscribe(const int message, const IEventHandler* handler);
//   };

// }

// namespace iMS {

//   static enum SequenceEvents {
//     SEQUENCE_START,
//     SEQUENCE_FINISHED,
//     SEQUENCE_ERROR,
//     SEQUENCE_TONE,
//     SEQUENCE_POSITION,
//     Count
//   };

// }

//     %inline %{
//     namespace iMS {
//     %rename(delay) ImagePlayerConfiguration::del;
//     struct SequenceConfiguration
//     {
//       PointClock int_ext{PointClock::INTERNAL };
//       ImageTrigger trig{ ImageTrigger::CONTINUOUS };
//       Polarity clk_pol{ Polarity::NORMAL };
//       Polarity trig_pol{ Polarity::NORMAL };
      
//       SequenceConfiguration();
//       SequenceConfiguration(PointClock c);
//       SequenceConfiguration(PointClock c, ImageTrigger t);
//     };
//     }
//     %}

//         // Create a typemap to translate the real nested struct to the dummy exposed one
//     %typemap(in) iMS::SequenceManager::SeqConfiguration {
//         auto* cfgPtr = new iMS::SequenceConfiguration();
//         cfgPtr->int_ext = $1.int_ext;
//         cfgPtr->trig = $1.trig;
//         cfgPtr->clk_pol = $1.clk_pol;
//         cfgPtr->trig_pol = $1.trig_pol;
//         $result = SWIG_NewPointerObj(cfgPtr, SWIGTYPE_p_iMS__SequenceConfiguration, SWIG_POINTER_OWN);
//     } 

// namespace iMS {

//   class SequenceManager
//   {
//   public:
//     SequenceManager(const IMSSystem&);
//     enum class PointClock {
//       INTERNAL,
// 	EXTERNAL
// 	};
//     enum class ImageTrigger {
//       POST_DELAY,
// 	EXTERNAL,
// 	HOST,
// 	CONTINUOUS
// 	};
//     //    using Repeats = ImageRepeats;


//     //struct SeqConfiguration cfg;
    
//     bool StartSequenceQueue(const SeqConfiguration& cfg = SeqConfiguration(), ImageTrigger start_trig = ImageTrigger::CONTINUOUS);
//     void SendHostTrigger();

//     bool Stop(ImagePlayer::StopStyle style = ImagePlayer::StopStyle::GRACEFULLY);
//     bool StopAtEndOfSequence();
//     bool Pause(ImagePlayer::StopStyle style = ImagePlayer::StopStyle::GRACEFULLY);
//     bool Resume();

//     uint16_t QueueCount();
//     bool GetSequenceUUID(int index, std::array<uint8_t, 16>& uuid);
//     bool QueueClear();
//     bool RemoveSequence(const ImageSequence& seq);
//     bool RemoveSequence(const std::array<uint8_t, 16>& uuid);
//     bool UpdateTermination(ImageSequence& seq, SequenceTermAction action, int val = 0);
//     bool UpdateTermination(const std::array<uint8_t, 16>& uuid, SequenceTermAction action, int val = 0);
//     bool UpdateTermination(ImageSequence& seq, SequenceTermAction action, const ImageSequence* term_seq);
//     //    bool UpdateTermination(const std::array<std::uint8_t, 16>& uuid, SequenceTermAction term, const std::array<std::uint8_t, 16>& term_uuid);

//     bool MoveSequence(const ImageSequence& dest, const ImageSequence& src);
//     bool MoveSequenceToEnd(const ImageSequence& src);

//     bool GetCurrentPosition();
    
//     void SequenceEventSubscribe(const int message, IEventHandler* handler);
//     void SequenceEventUnsubscribe(const int message, const IEventHandler* handler);
    
//   };

// }
