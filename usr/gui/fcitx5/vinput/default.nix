{ pkgs, lib, npinsFun, ... }: let
  system = pkgs.stdenv.hostPlatform.system;
  model = import ./model.nix { inherit pkgs; };
  modelName = lib.removePrefix "model.sherpa-onnx." model.modelId;
  vinput = (pkgs.flake-compat {
    src = (npinsFun {input=./sources.json;}).fcitx5-vinput;
  }).defaultNix.packages.${system}.default;
in lib.mkIf (builtins.elem system [ "x86_64-linux" "aarch64-linux" ]) {
  home.packages = [ vinput ];
  cachix_packages = [ vinput ];
  i18n.inputMethod.fcitx5.addons = [ vinput ];

  xdg.dataFile."vinput/models/sherpa-onnx/${modelName}".source = model;
  yq-merge.".config/vinput/config.json" = {
    generator = builtins.toJSON;
    expr.asr = {
      active_provider = "sherpa-onnx";
      providers = [{ id = "sherpa-onnx"; type = "local"; model = model.modelId; }];
    };
    yqExtraArgs = "-p json -o json";
    preOnChange = ''
      if [[ ! -e .config/vinput/config.json ]]; then
        run ${pkgs.coreutils}/bin/install -Dm600 \
          ${vinput}/share/fcitx5-vinput/default-config.json .config/vinput/config.json
      fi
      # yq-merge matches arrays by index; move the local provider first without losing others.
      run ${pkgs.yq-go}/bin/yq -p json -o json -i '
        (.asr.providers // []) as $providers |
        .asr.providers = (
          ([$providers[] | select(.id == "sherpa-onnx")] +
            [{"id": "sherpa-onnx"}] | unique_by(.id)) +
          [$providers[] | select(.id != "sherpa-onnx")]
        )
      ' .config/vinput/config.json
    '';
  };

  systemd.user.services.vinput-daemon = {
    Unit = {
      Description = "Vinput Voice Input Daemon";
      After = [ "pipewire.service" ];
      X-Restart-Triggers = [ "${model}" ];
    };
    Service = {
      Type = "dbus";
      BusName = "org.fcitx.Vinput";
      ExecStart = "${vinput}/bin/vinput-daemon";
    };
    Install.WantedBy = [ "default.target" ];
  };
}
