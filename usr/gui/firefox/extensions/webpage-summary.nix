{ pkgs, ... }: let
  addonId = "{b33fc9ba-eac3-4adb-a3c7-d0f50634182e}";
in {
  programs.firefox.profiles.xieby1.extensions.packages = [(
    pkgs.nur.repos.rycee.firefox-addons.buildFirefoxXpiAddon {
      pname = "webpage_summary";
      version = "0.6.2";
      inherit addonId;
      url = "https://addons.mozilla.org/firefox/downloads/file/4681585/webpage_summary-0.6.2.xpi";
      sha256 = "sha256-6FP2RMDJUYWHNJRg/6jDckCo94dgyLmnZH7A2aZX3l4=";
      meta = {
        mozPermissions = ["storage" "contextMenus" "scripting" "activeTab" "cookies" "webRequest" "webRequestBlocking" "*://*.kimi.com/*" "<all_urls>"];
        platforms = pkgs.lib.platforms.all;
      };
    }
  )];
  firefox-extensions.xieby1.browser-extension-data."${addonId}" = {
    storage = {
      is-first-install = true;
      default-prompt-id = "8zuiQHnivwU2scwZ";
      prompt-configs = [{
        id = "8zuiQHnivwU2scwZ";
        name = "Sample";
        systemMessage = ''
          You are a one-webpage content summarize expert to help users quickly and intuitively understand the content of the webpage.
          Please NOTICE:
          1. Be concise and clear, DO NOT just retell.
          2. The entire conversation and instructions should be aligned with webpage content.
          3. Your output format should be raw markdown(not a markdown code block).
          4. Do not exceed 1000 words.
          5. User may asks questions after a message of input content, then YOU should chat but not summary.
        '';
        userMessage = ''
          here is the url:
          <Webpage URL>{{articleUrl}}</Webpage URL> 
          here is the content of webpage:
          <Webpage Content>{{textContent}}</Webpage Content>
        '';
        at = 0;
      }];
      default-model-id = "p4s0PTKm1x4xga8X";
      model-configs = [{
          id = "LwC1DkGB6Fs01U99";
          name = "siliconflow-deepseek";
          modelName = "Pro/deepseek-ai/DeepSeek-V3.2";
          apiKey = pkgs.lib.trim (builtins.readFile "/home/xieby1/Gist/Vault/siliconflow_api_key_chatbox.txt");
          providerType = "deepseek";
          baseURL = "https://api.siliconflow.cn/v1";
          at = 0;
      } {
          id = "p4s0PTKm1x4xga8X";
          name = "deepseek-offical";
          modelName = "deepseek-chat";
          apiKey = pkgs.lib.trim (builtins.readFile "/home/xieby1/Gist/Vault/deepseek_api_key_nvim.txt");
          providerType = "deepseek";
          baseURL = "";
          at = 0;
      }];
      config-model-list-is-edit-mode = true;
      right-floating-ball-top-page = "75%";
      enable-floating-ball = false;
      user-custom-style = /*css*/ ''
        --webpage-summary-panel-width: 50vw;
        --webpage-summary-panel-dialog-max-height: 60vh;
        --webpage-summary-panel-top: 10vh;
        --webpage-summary-panel-right: 0.5em;
        --webpage-summary-markdown-font-size: 10pt;
        --webpage-summary-markdown-line-height: 1em;
      '';
    };
  };

  firefox-extensions.xieby1 = {
    extension-settings = {
      commands = {
        COMMAND_ADD_SELECTION.precedenceList = [{
          id = addonId;
          installDate = 0;
          value.shortcut = "";
          enabled = true;
        }];
        COMMAND_INVOKE_SUMMARY.precedenceList = [{
          id = addonId;
          installDate = 0;
          value.shortcut = "Alt+A";
          enabled = true;
        }];
      };
    };
  };
}
