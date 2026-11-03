{ config, pkgs, ... }:
let
  retry = config.yq-merge.".pi/agent/settings.json".expr.retry;
  retriesBeforeCap = delay:
    if delay >= retry.maxAgentDelayMs then 0
    else 1 + retriesBeforeCap (delay * 2);
in
{
  home.file.".pi/agent/extensions/pi-retry" = {
    enable = retry.enabled;
    source = pkgs.npinsed.ai.pi.pi-retry.outPath;
  };

  yq-merge.".pi/agent/settings.json".expr.piRetry = {
    baseDelayMs = retry.baseDelayMs;
    maxDelayMs = retry.maxAgentDelayMs;
    # pi-retry counts only failures at the delay cap; subtract earlier retries.
    maxRetriesAtMaxDelay = retry.maxRetries - retriesBeforeCap retry.baseDelayMs;
  };
}
