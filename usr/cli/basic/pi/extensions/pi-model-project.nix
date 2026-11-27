{ src }: # local-args
{ ... }:
{
  home.file.".pi/agent/extensions/pi-model-project/index.ts".source = src + "/index.ts";
}
