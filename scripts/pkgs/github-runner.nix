{ pkgs ? import <nixpkgs> {}
}: let
  container = import ./mini-container.nix {inherit pkgs;};
  cmds = builtins.toFile "cmds" ''
    export RUNNER_ALLOW_RUNASROOT=1

    # clean on exit
    tokenCmd=$(echo "$@" | grep -o -- '--token[ ]*[^ ]*')
    trap "config.sh remove $tokenCmd" EXIT

    cd /root
    # start
    config="config.sh --disableupdate --unattended --name $HOSTNAME-$(date +%y%m%d%H%S) $@"
    echo $config
    eval $config

    run.sh
  '';
in pkgs.writeShellScriptBin "github-runner-nix" ''
  command -v podman &> /dev/null || echo "podman not found" || exit 1

  fullName=localhost/${container.imageName}:${container.imageTag}
  # check whether image has been loaded
  podman images $fullName | grep ${container.imageName} | grep ${container.imageTag} &> /dev/null
  # image has not been loaded, then load it
  if [[ $? != 0 ]]; then
    podman load -i ${container}
  fi

  # run container
  OPTS=(
    --rm
    --network=host
    --env-merge PATH='${pkgs.github-runner}/bin:${pkgs.nix}/bin:''${PATH}'
    -v /nix:/nix:ro
    -it
    "$fullName"
    /bin/sh ${cmds} $@
  )
  echo "podman run ''${OPTS[@]}"
  eval "podman run ''${OPTS[@]}"
''
