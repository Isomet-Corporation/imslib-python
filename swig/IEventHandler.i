/*%include <typemaps.i>

%typemap(ctype)  void* "void *"
%typemap(imtype) void* "System.IntPtr"
%typemap(cstype) void* "System.IntPtr"
%typemap(csin)   void* "$csinput"
%typemap(in)     void* %{ $1 = $input; %}
%typemap(out)    void* %{ $result = $1; %}
%typemap(csout, excode=SWIGEXCODE)  void* { 
    System.IntPtr cPtr = $imcall;$excode
    return cPtr;
    }
%typemap(csvarout, excode=SWIGEXCODE2) void* %{ 
    get {
        System.IntPtr cPtr = $imcall;$excode 
        return cPtr; 
   } 
%} 
%typemap(directorin) void* " $input = $1;"
%typemap(directorout) void* %{
  $result = ($1_ltype)$input; 
  %}
*/
namespace iMS {

%feature("director") IEventHandler;
class IEventHandler
{
 public:
  IEventHandler();
  virtual ~IEventHandler();
  //		bool operator == (const IEventHandler e);
  virtual void EventAction(void* sender, const int message);
  virtual void EventAction(void* sender, const int message, const int param);
  virtual void EventAction(void* sender, const int message, const int param, const int param2);
  virtual void EventAction(void* sender, const int message, const double param);
  virtual void EventAction(void* sender, const int message, const int param, const std::vector<uint8_t> data);
};
 
}
