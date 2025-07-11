namespace iMS
{
  class LibVersion
  {
  public:
    static int GetMajor();
    static int GetMinor();
    static int GetPatch();
    static std::string GetVersion();
    static bool IsAtLeast(int major, int minor, int patch);
    static bool HasFeature(const std::string &name);
  };
}
