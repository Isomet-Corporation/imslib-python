%module imslib

%{
// #include "AcoustoOptics.h"
#include "Containers.h"
// #include "ImageProject.h"
#include "LibVersion.h"
#include "ConnectionList.h"
// #include "IConnectionSettings.h"
#include "CS_ETH.h"
#include "CS_RS422.h"
// #include "IEventHandler.h"
#include "IMSSystem.h"
#include "IMSTypeDefs.h"
// #include "Auxiliary.h"
// #include "Image.h"
// #include "ImageOps.h"
// #include "FileSystem.h"
// #include "Compensation.h"
// #include "ToneBuffer.h"
// #include "SignalPath.h"
// #include "SystemFunc.h"
// #include "Diagnostics.h"

  using namespace iMS;
%}

%include "stdint.i"
%include <std_string.i>
%include <std_vector.i>
//%include <memory.i>
// %include "std_deque.i"
// %include "std_map.i"
// %include "windows.i"
// %include "attribute.i"
// %include "typemaps.i"

%template(ByteVector) std::vector<uint8_t>;

// %template(AnalogData) std::map<int, iMS::Percent>;

#define _STATIC_IMS

%include "Containers.i"
%include "LibVersion.i"
%include "IMSTypeDefs.i"
// %include "IEventHandler.i"
%include "IMSSystem.i"
%include "ConnectionList.i"
// %include "FileSystem.i"
// %include "AcoustoOptics.i"
// %include "Auxiliary.i"
// %include "Image.i"
// %include "ImageOps.i"
// %include "Compensation.i"
// %include "ToneBuffer.i"
// %include "ImageProject.i"
// %include "SignalPath.i"
// %include "SystemFunc.i"
// %include "Diagnostics.i"