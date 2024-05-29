#MC # Nix Docker for Multiple ISAs
# TODO: support multiple ISAs (currently only riscv64)
# currently: this riscv64 nix docker can `nix-env -iA nixpkgs.hello`,
# which is completely built from source including toolchains (stdenv) in riscv64.
let
  pkgs = import <nixpkgs> {};
  # pkgsCross = import <nixpkgs> {};
  pkgsCross = pkgs.pkgsCross.riscv64;
  docker-nixpkgs-src = pkgs.fetchFromGitHub {
    owner = "nix-community";
    repo = "docker-nixpkgs";
    rev = "bfac57f18680c9b2927b9c85a17e5b4cd89c27f2";
    hash = "sha256-fn9wmhwIFCuTziPZZ0HlJxqNEnOyjdaiHGrvD2niXOU=";
  };
  docker-image = import "${docker-nixpkgs-src}/images/nix" {
    inherit (pkgs) dockerTools cacert;
    inherit (pkgsCross)
      bashInteractive
      coreutils
      curl
      gnutar
      gzip
      iana-etc
      nix
      openssh
      xz
    ;
    gitReallyMinimal = pkgsCross.gitMinimal;
    extraContents = [
      # (pkgs.writeTextFile {
      #   name = "nix.conf";
      #   text = ''
      #     filter-syscalls = false
      #   '';
      #   destination = "/etc/nix/nix.conf";
      # })
      ./imageFiles
    ];
  };
in pkgs.writeShellScriptBin "nix-docker-riscv64" ''
  command -v podman &> /dev/null || echo "podman not found TODO: install" || exit 1

  # TODO: add tag support to docker-nixpkgs
  outName="$(basename ${docker-image})"
  outHash=$(echo "$outName" | cut -d - -f 1)
  nixName=${pkgsCross.nix.name}
  imageName=localhost/$nixName:$outHash

  # check whether image has been loaded
  podman images $imageName | grep $nixName | grep $outHash &> /dev/null
  # image has not been loaded, then load it
  if [[ $? != 0 ]]; then
    podman load -i ${docker-image}
  fi


  # TODO
  BINFMTS=""
  for binfmt in /run/binfmt/*; do
      BINFMTS+=" -v $(realpath $binfmt):$binfmt"
  done

  containerName=$nixName-$outHash
  # run container
  podman run -it \
    --name=$containerName \
    -v $(realpath /run/binfmt/riscv64-linux):/run/binfmt/riscv64-linux \
    --network=host \
    $imageName
  podman commit $containerName $imageName
  podman rm $containerName
''
