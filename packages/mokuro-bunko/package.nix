{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonApplication rec {
  pname = "mokuro-bunko";
  version = "0.1.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Gnathonic";
    repo = "mokuro-bunko";
    tag = "v${version}";
    hash = "sha256-NG6NRM7DeuQOdqWP/9rENjqWLCooek2hK4XxiK0loIA=";
  };

  build-system = with python3Packages; [ hatchling ];

  dependencies = with python3Packages; [
    wsgidav
    cheroot
    pyyaml
    bcrypt
    watchdog
    pillow
    click
    cryptography
  ];

  meta = {
    changelog = "https://github.com/Gnathonic/mokuro-bunko/releases/tag/v${version}";
    description = "Self-hosted manga library server with WebDAV, OCR, and multi-user support";
    homepage = "https://github.com/Gnathonic/mokuro-bunko";
    license = lib.licenses.gpl3Only;
    mainProgram = "mokuro-bunko";
    maintainers = with lib.maintainers; [ nickthegroot ];
  };
}
