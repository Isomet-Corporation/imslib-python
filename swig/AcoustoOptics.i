#include "iMSTypeDefs.h"
#include "Compensation.h"
#include <string>

%attribute(iMS::Crystal, iMS::Crystal::Material, Type, Type);
%attributestring(iMS::Crystal, std::string, Description, Description);
%attribute(iMS::Crystal, double, AcousticVelocity, AcousticVelocity);
namespace iMS
{
  class Crystal
  {
  public:
    enum class Material : std::uint16_t
    {
      PbMoO4,
	TeO2,
	TeO2S,
	aQuartz,
	fSilica,
	fSilicaS,
	Ge
	};

  Crystal(Crystal::Material material = Crystal::Material::TeO2);
  Crystal(const Crystal &);
  //  const Crystal &operator =(const Crystal &);

  Crystal::Material Type();
  //  const Material& Type() const;
  const std::string& Description() const;

  const double AcousticVelocity() const;
  double RefractiveIndex(iMS::distance<std::micro> wavelength);

  Degrees BraggAngle(iMS::distance<std::micro> wavelength, MHz frequency);
  };
}

%attributestring(iMS::AODevice, std::string, Model, Model);
%attribute2(iMS::AODevice, iMS::Crystal, Material, Material);
%attribute2(iMS::AODevice, iMS::MHz, CentreFrequency, CentreFrequency);
%attribute2(iMS::AODevice, iMS::MHz, SweepBW, SweepBW);
%attribute2(iMS::AODevice, iMS::distance<std::micro>, OperatingWavelength, OperatingWavelength);
%attribute(iMS::AODevice, double, GeomConstant, GeomConstant);
//%attribute2(iMS::AODevice, iMS::Degrees, ExternalBragg, ExternalBragg);

namespace iMS {
  class AODevice
  {
  public:
    AODevice(Crystal& xtal, double GeomConstant = 4.0, MHz Centre = 100.0, MHz Bandwidth = 60.0);
    AODevice(const std::string& Model);
    AODevice(const AODevice &);
    //    const AODevice &operator =(const AODevice &);
		
    const std::string& Model() const;
    const Crystal& Material() const;
    const MHz& CentreFrequency() const;
    const MHz& SweepBW() const;
    const iMS::distance<std::micro>& OperatingWavelength() const;
    const double& GeomConstant() const;

    Degrees ExternalBragg();
    iMS::CompensationFunction GetCompensationFunction();

    Degrees ExternalBragg(iMS::distance<std::micro> wavelength);
    iMS::CompensationFunction GetCompensationFunction(iMS::distance<std::micro> wavelength);
  };
}

%ignore iMS::AODeviceList::AODeviceList;
%ignore iMS::AODeviceList::~AODeviceList;
%rename(GetList) iMS::AODeviceList::getList;

namespace iMS {
  
  struct AODeviceList
  {
  private:
    AODeviceList();
    AODeviceList(const AODeviceList&) = delete;
    AODeviceList& operator=(const AODeviceList&) = delete;
    ~AODeviceList();
  public:
    static const ListBase<std::string>& getList();
  };
}
