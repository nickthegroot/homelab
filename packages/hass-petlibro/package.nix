{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
}:

buildHomeAssistantComponent rec {
  owner = "jjjonesjr33";
  domain = "petlibro";
  version = "1.2.32";

  src = fetchFromGitHub {
    inherit owner;
    repo = "petlibro";
    tag = "v${version}";
    hash = "sha256-TOkh1uJgpDX2SQjeKZISU/t2e5tOW2wDUaDc+AESxRg=";
  };

  meta = {
    description = "PETLIBRO integration for Home Assistant";
    homepage = "https://github.com/jjjonesjr33/petlibro";
    changelog = "https://github.com/jjjonesjr33/petlibro/releases/tag/v${version}";
    license = lib.licenses.gpl3Only;
  };
}
