{ lib
, rustPlatform
, fetchFromGitHub
}:
rustPlatform.buildRustPackage rec {
  pname = "clashctl";
  version = "b09e1faf80f1a25fa855499d8b34d36491e5a081";

  src = fetchFromGitHub {
    # owner = "https://github.com/George-Miao/clashctl";
    owner = "George-Miao";
    repo = pname;
    rev = version;
    hash = "sha256-c7y64SsZEKdC8+umCY8+XBwxAHxn4YpqR48ASbHpkdM=";
  };

  cargoHash = "sha256-VEQ1amZxCTV4jefN20d8VV85/IaJivl0s8RVclV+jqg=";

  doCheck = false;

  meta = with lib; {
    description = "CLI for interacting with clash";
    homepage = "https://github.com/George-Miao/clashctl";
    license = licenses.mit;
    maintainers = with maintainers; [ xieby1 ];
  };
}
