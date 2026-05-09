{
  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
    in
    {
      packages.${system} = {
        nixenv-rebuild = pkgs.writeShellApplication {
          name = "nixenv-rebuild";
          runtimeInputs = with pkgs; [ nix ];
          text = ''
            NIXENV_CONFIG="''${XDG_CONFIG_HOME:-$HOME/.config}/nixenv"
            nix --extra-experimental-features "nix-command flakes" run "$NIXENV_CONFIG#nixenv-setup"
          '';  
        };
        
        nixenv-setup = pkgs.writeShellApplication {
          name = "nixenv-setup";
          runtimeInputs = with pkgs; [ nix ];
          text = ''
            XDG_DATA_HOME="''${XDG_DATA_HOME:-$HOME/.local/share}"
            XDG_STATE_HOME="''${XDG_STATE_HOME:-$HOME/.local/state}"
            XDG_CONFIG_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}"

            NIXENV_CONFIG="$XDG_CONFIG_HOME/nixenv"
            NIXENV_STATE="$XDG_STATE_HOME/nixenv"

            nix --extra-experimental-features "nix-command flakes" build "$NIXENV_CONFIG" -o "$NIXENV_STATE"

            # echo fish_add_path --global "$NIXENV_STATE/bin" > "$XDG_CONFIG_HOME/fish/conf.d/nixenv.fish"
            # echo set --export --global --prepend --path MANPATH "$NIXENV_STATE/share/man" /usr/share/man >> "$XDG_CONFIG_HOME/fish/conf.d/nixenv.fish"

            # ln -s -n -f "$NIXENV_STATE/share/fish/vendor_completions.d" "$XDG_DATA_HOME/fish/vendor_completions.d" 
          '';
        };

        default = pkgs.buildEnv {
          name = "nixenv";
          paths = [
            pkgs.nix
            self.outputs.packages.${system}.nixenv-rebuild
          ]
          ++ pkgs.callPackage ./pkgs.nix { inherit pkgs; };
        };
      };
    };
}
