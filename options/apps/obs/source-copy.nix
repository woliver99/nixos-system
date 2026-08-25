{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  obs-studio,
  qtbase,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "obs-source-copy";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "exeldro";
    repo = "obs-source-copy";
    rev = finalAttrs.version;
    hash = "sha256-ECgBaY8dpzmJcljs23byE0ZmypF4+hEQafWVHDGdmLs=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    obs-studio
    qtbase
  ];

  dontWrapQtApps = true;

  postPatch = ''
    sed 's/Qt_VERSION/Qt6_VERSION/g' -i CMakeLists.txt
  '';

  cmakeFlags = [
    "-DBUILD_OUT_OF_TREE=ON"
  ];

  meta = {
    description = "Plugin for OBS Studio to copy sources";
    homepage = "https://github.com/exeldro/obs-source-copy";
    maintainers = with lib.maintainers; [ flexiondotorg ];
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
  };
})
