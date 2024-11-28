#MC # Github Runner
#MC
#MC This is a specially designed github runner:
#MC
#MC 1. To improve the security, more specifially, to avoid leaking information of the host environment,
#MC   * the runner is confined to a container,
#MC   * the rootless container is used, without sudo privilege.
#MC 2. To reduce the build time, the /nix/store is shared across containers and host environment, so that
#MC   * the results can be cached in host /nix/store,
#MC   * there is no repeated build among different containers.
{ pkgs ? import <nixpkgs> {}
, extraConfigOpts ? []
, extraPodmanOpts ? []
, extraPkgsInPATH ? []
}: let
  container = import ./mini-container.nix {inherit pkgs;};
  cmds = builtins.toFile "cmds" ''
    export RUNNER_ALLOW_RUNASROOT=1

    # clean on exit
    tokenCmd=$(echo "$@" | grep -o -- '--token[ ]*[^ ]*')
    trap "config.sh remove $tokenCmd" EXIT

    cd /root
    # start
    config="config.sh --disableupdate --unattended --name $HOSTNAME-$(date +%y%m%d%H%M%S) ${builtins.concatStringsSep " " extraConfigOpts} $@"
    echo $config
    eval $config

    run.sh
  '';
  pkgsInPATH = [
    pkgs.github-runner
    pkgs.nix
  ] ++ extraPkgsInPATH;
in pkgs.writeShellScriptBin "github-runner-nix" ''
  fullName=localhost/${container.imageName}:${container.imageTag}
  # check whether image has been loaded
  ${pkgs.podman}/bin/podman images $fullName | grep ${container.imageName} | grep ${container.imageTag} &> /dev/null
  # image has not been loaded, then load it
  if [[ $? != 0 ]]; then
    ${pkgs.podman}/bin/podman load -i ${container}
  fi

  # run container
  OPTS=(
    --rm
    --network=host
    --env-merge PATH='${pkgs.lib.concatMapStrings (pkg: pkg+"/bin:") pkgsInPATH}\''${PATH}'
    -v /nix:/nix:ro
    -it
    ${builtins.concatStringsSep " " extraPodmanOpts}
    "$fullName"
    /bin/sh ${cmds} $@
  )
  echo "${pkgs.podman}/bin/podman run ''${OPTS[@]}"
  eval "${pkgs.podman}/bin/podman run ''${OPTS[@]}"
''
