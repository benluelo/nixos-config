{ appimageTools, ... }:
let
	version = "v1.1.30";
in
appimageTools.wrapType1 {
  name = "gdlauncher";
  src = builtins.fetchurl {
    url = "https://github.com/gorilla-devs/GDLauncher/releases/download/${version}/GDLauncher-linux-setup.AppImage";
    sha256 = "sha256-4cXT3exhoMAK6gW3Cpx1L7cm9Xm0FK912gGcRyLYPwM=";
  };
}
