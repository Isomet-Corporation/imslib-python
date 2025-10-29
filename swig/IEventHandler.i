namespace iMS {

%feature("director") IEventHandler;
class IEventHandler
{
protected:
    IEventHandler();
 public:
  virtual ~IEventHandler();
  //		bool operator == (const IEventHandler e);
  virtual void EventAction(void* sender, const int message) {}
  virtual void EventAction(void* sender, const int message, const int param) {}
  virtual void EventAction(void* sender, const int message, const int param, const int param2) {}
  virtual void EventAction(void* sender, const int message, const double param) {}
  virtual void EventAction(void* sender, const int message, const int param, const std::vector<uint8_t> data) {}
};
 
}
