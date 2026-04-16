{
  buildNpmPackage,
  fetchFromGitHub,
}:
buildNpmPackage (finalAttrs: {
  pname = "pi-acp";
  version = "latest";

  src = fetchFromGitHub {
    owner = "svkozak";
    repo = "pi-acp";
    rev = "c30957b38608d37b85be2a7d793606c9f37e8c83";
    hash = "sha256-MdEXjHvn8eCy2mPstgTwXUZh99whr8hCA4CTFis1h3g=";
  };

  npmDepsHash = "sha256-GuHvjqSD4M87cGBtFFSF37FWF79+6pLlai0A99Ii/hM=";
})

