namespace iMS {

  class ImageGroupList : public ListBase < ImageGroup >
  {
  };

  class CompensationFunctionList : public ListBase < CompensationFunction >
  {
  };

  class ToneBufferList : public ListBase < ToneBuffer >
  {
  };

}

%attribute2ref(iMS::ImageProject, iMS::ImageGroupList, ImageGroupContainer, ImageGroupContainer);
%attribute2ref(iMS::ImageProject, iMS::CompensationFunctionList, CompensationFunctionContainer, CompensationFunctionContainer);
%attribute2ref(iMS::ImageProject, iMS::ToneBufferList, ToneBufferContainer, ToneBufferContainer);
%attribute2ref(iMS::ImageProject, iMS::ImageGroup, FreeImageContainer, FreeImageContainer);

namespace iMS {
  class ImageProject
  {
  public:
    ImageProject();
    /// \brief Implicit Load From File Constructor
    ImageProject(const std::string& fileName);
    
    ImageGroupList& ImageGroupContainer();
    const ImageGroupList& ImageGroupContainer() const;
    
    CompensationFunctionList& CompensationFunctionContainer();
    const CompensationFunctionList& CompensationFunctionContainer() const;
    
    ToneBufferList& ToneBufferContainer();
    const ToneBufferList& ToneBufferContainer() const;

    ImageGroup& FreeImageContainer();
    const ImageGroup& FreeImageContainer() const;

    void Clear();
    bool Save(const std::string& fileName);
    bool Load(const std::string& fileName);
  };

}
