# Organization of npinsed sources {date="2026.04.16"}

## 1. Flat Structure: All Sources in `<project_root>/npins/sources.json`

- **Cons**: Difficult to manage logically grouped sources (e.g., updating all AI-related sources requires touching a single large file).

## ✅2. Hierarchical Structure within `<project_root>/npins/` and nest `pkgs.npinsed`:

- Example:
  - ```
    - <project_root>/npins/
      - default.nix
      - sources.json # pkgs.npinsed.<source-name>
      - ai/
        - sources.json # pkgs.npinsed.ai.<source-name>
      - vim/
        - sources.json # pkgs.npinsed.vim.<source-name>
        - lspconfig/
          - sources.json # pkgs.npinsed.vim.lspconfig.<source-name>
    ```
- **Pros**: Solves the management issues above.
- **Cons**: The hierarchy is disconnected from the nix script structure (`usr/cli/ai`, `usr/cli/vim`, ...), breaking modularity.
- **Tradeoff**: The npins hierarchy can be different from nix script hierarchy.
  - Example: there are AI-related nix scripts in `modules/ai/`, `usr/cli/ai/`, ...

## 3. Hierarchical Structure within `<project_root>`

Places npins alongside their corresponding nix scripts:

- Example:
  - ```
    - <project_root>/
      - npins/
        - default.nix
        - sources.json
      - usr/cli/
        - ai/
          - npins/sources.json
          - foo/
            - bar/default.nix # ((pkgs.npinsed) {input=../../npins/sources.json;}).<source-name>
        - vim/
          - npins/sources.json
          - lspconfig/
            - npins/sources.json
    ```
- **Pros**: Solves the modularity issues above.
- **Cons**: Accessing sources requires navigating deeper paths, making references more tedious.

## 4. Hierarchical structure within `<project_root>` and nest `pkgs.npinsed`

- Example:
  - ```
    <project_root>/usr/cli/ai/foo/bar/default.nix # pkgs.npinsed.usr.cli.ai.<source-name>
    ```
- **Pros**: solve the Cons above
- **Cons**: unnecessary complexity
