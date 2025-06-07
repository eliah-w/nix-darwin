#.config/nix/flake.nix
{
  description = "nix-darwin Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    secrets.url = "git+ssh://git@github.com/eliah-w/nix-secrets.git";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      nix-homebrew,
      home-manager,
      secrets,
    }:

    let
      secrets = inputs.secrets.secrets;
      configuration =
        { pkgs, ... }:
        {
          nix.enable = true;

          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";

          system.configurationRevision = self.rev or self.dirtyRev or null;

          security.pam.services.sudo_local.touchIdAuth = true;

          # Used for backwards compatibility. please read the changelog
          # before changing: `darwin-rebuild changelog`.
          system.stateVersion = 5;
          system.primaryUser = secrets.userConfig.name;
          system.defaults = {
            NSGlobalDomain = {
              AppleICUForce24HourTime = true;
              AppleInterfaceStyle = "Dark";
              AppleMeasurementUnits = "Centimeters";
              AppleMetricUnits = 1;
              AppleShowAllExtensions = true;
              AppleShowAllFiles = true;
              AppleTemperatureUnit = "Celsius";
              NSAutomaticCapitalizationEnabled = false;
              NSAutomaticDashSubstitutionEnabled = false;
              NSAutomaticPeriodSubstitutionEnabled = false;
              NSAutomaticQuoteSubstitutionEnabled = true;
              NSAutomaticSpellingCorrectionEnabled = false;
              NSDocumentSaveNewDocumentsToCloud = false;
              NSTableViewDefaultSizeMode = 1;
              "com.apple.mouse.tapBehavior" = 1;
              "com.apple.sound.beep.feedback" = 0;
              "com.apple.trackpad.scaling" = 2.0;
            };
            SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;
            WindowManager = {
              AppWindowGroupingBehavior = true;
              AutoHide = true;
              EnableStandardClickToShowDesktop = true;
              # Stage Manager
              GloballyEnabled = false;
              HideDesktop = true;
              StageManagerHideWidgets = true;
              StandardHideDesktopIcons = true;
              StandardHideWidgets = true;
            };
            dock = {
              autohide = true;
              autohide-delay = 0.0;
              expose-animation-duration = 0.0;
              expose-group-apps = true;
              orientation = "left";
              show-recents = false;
            };
            finder = {
              AppleShowAllExtensions = true;
              AppleShowAllFiles = true;
              FXDefaultSearchScope = "SCcf";
              FXEnableExtensionChangeWarning = false;
              FXPreferredViewStyle = "Nlsv";
              ShowPathbar = true;
              ShowStatusBar = true;
              _FXShowPosixPathInTitle = true;
              _FXSortFoldersFirst = true;
            };
            loginwindow = {
              GuestEnabled = false;

            };
            menuExtraClock = {
              Show24Hour = true;
              ShowDate = 0;
              ShowDayOfMonth = true;
              ShowSeconds = true;
            };
            trackpad = {
              TrackpadRightClick = true;
              TrackpadThreeFingerDrag = true;
            };
          };
          system.activationScripts.diff = ''
            if [[ -e /run/current-system ]]; then
              if [[ -n $(${pkgs.nix}/bin/nix store diff-closures /run/current-system "$systemConfig") ]]; then echo; ${pkgs.nix}/bin/nix store diff-closures /run/current-system "$systemConfig" | grep -w "→" | grep -w "KiB" | column --table --separator " ,:" | ${pkgs.choose}/bin/choose :1 -4: | ${pkgs.gawk}/bin/awk '{s=$0; gsub(/\033\[[ -?]*[@-~]/,"",s); print s "\t" $0}' | sort -k5,5gr | ${pkgs.choose}/bin/choose 6: | column --table
              Sum=$(${pkgs.nix}/bin/nix store diff-closures /run/current-system "$systemConfig" | grep -w "→" | grep -w "KiB" | column --table --separator " ,:" | ${pkgs.choose}/bin/choose -2 | ${pkgs.ansifilter}/bin/ansifilter | tr "\n" " " | ${pkgs.gawk}/bin/awk 'NR == 1 { $0 = "0" $0 }; 1' | ${pkgs.bc}/bin/bc -l)
              if (( $(echo "$Sum != 0" | ${pkgs.bc}/bin/bc -l) )); then
              SumMiB=$(echo "scale=2; $Sum/1024" | ${pkgs.bc}/bin/bc -l)
              echo -en "\nSum: "
              if (( $(echo "$SumMiB > 0" | ${pkgs.bc}/bin/bc -l) )); then TERM=xterm-256color ${pkgs.ncurses}/bin/tput setaf 1; elif (( $(echo "$SumMiB < 0" | ${pkgs.bc}/bin/bc -l) )); then TERM=xterm-256color ${pkgs.ncurses}/bin/tput setaf 2; fi
              echo -e "$SumMiB MiB\n"
              TERM=xterm-256color ${pkgs.ncurses}/bin/tput setaf 7
              fi
            fi
          '';
          time.timeZone = "Europe/Berlin";

          # Apple Silicone
          nixpkgs.hostPlatform = "aarch64-darwin";

          nixpkgs.config = {
            allowUnfree = true;
          };

          users.users.eliah = secrets.userConfig;

          # Create /etc/zshrc that loads the nix-darwin environment.
          programs.zsh.enable = true;
          programs.zsh.enableFzfCompletion = true;
          programs.zsh.enableFzfGit = true;
          programs.zsh.enableSyntaxHighlighting = true;

          programs.nix-index.enable = true;
          programs.ssh.knownHosts = secrets.ssh.knownHosts;

          environment.systemPackages = [
            pkgs.alejandra
            pkgs.aria2
            pkgs.ast-grep
            pkgs.bat
            pkgs.blueutil
            pkgs.cabextract
            pkgs.cdrtools
            pkgs.chafa
            pkgs.cmake
            pkgs.cocoapods
            pkgs.coreutils
            pkgs.curl
            pkgs.deadnix
            pkgs.exiftool
            pkgs.expect
            pkgs.eza
            pkgs.fastfetch
            pkgs.fd
            pkgs.ffmpeg
            pkgs.fzf
            pkgs.fzf-zsh
            pkgs.gawk
            pkgs.gdu
            pkgs.ghostscript
            pkgs.git
            pkgs.gnutar
            pkgs.gnupg
            pkgs.gnugrep
            pkgs.htop
            # pkgs.hugo
            pkgs.imagemagick
            pkgs.lazygit
            pkgs.luajit
            pkgs.luarocks
            pkgs.neovim
            pkgs.ninja
            pkgs.nixd
            pkgs.nixfmt-rfc-style
            pkgs.nix-output-monitor
            pkgs.nvd
            pkgs.oh-my-zsh
            pkgs.php
            pkgs.php84Packages.composer
            pkgs.portaudio
            pkgs.pstree
            pkgs.python3Full
            pkgs.redis
            pkgs.restic
            pkgs.ripgrep
            # pkgs.spicetify-cli
            pkgs.chntpw
            pkgs.spoof-mac
            pkgs.tectonic
            pkgs.terminal-notifier
            pkgs.tmux
            pkgs.watchman
            pkgs.wget
            pkgs.wimlib
            pkgs.xz
            pkgs.yazi
            pkgs.zoxide
            pkgs.zsh
            pkgs.zsh-powerlevel10k
          ];
          homebrew = {
            enable = true;
            onActivation = {
              cleanup = "zap";
              autoUpdate = true;
              upgrade = true;
              extraFlags = [
                "--verbose"
              ];
            };
            global = {
              brewfile = true;
              autoUpdate = true;
            };

            taps = [ ];
            brews = [
              "docker-compose"
              "mas"
              "nvm"
              "spicetify-cli"
            ];
            masApps = {
              Amphetamine = 937984704;
              AusweisApp = 948660805;
              "CapCut - Foto & Video Editor" = 1500855883;
              "Cleaner One Pro" = 1133028347;
              CrystalFetch = 6454431289;
              iMovie = 408981434;
              Keynote = 409183694;
              MKPlayer = 1335612105;
              Numbers = 409203825;
              Pages = 409201541;
              "Perplexity: Ask Anything" = 6714467650;
              Playgrounds = 1496833156;
              Tailscale = 1475387142;
              "The Unarchiver" = 425424353;
              Xcode = 497799835;
            };
            casks = [
              { name = "ableton-live-suite"; greedy = true; }
              { name = "aldente"; greedy = true; }
              { name = "android-file-transfer"; greedy = true; }
              { name = "android-platform-tools"; greedy = true; }
              { name = "bartender"; greedy = true; }
              { name = "battle-net"; greedy = true; }
              { name = "betterdiscord-installer"; greedy = true; }
              { name = "betterdisplay"; greedy = true; }
              { name = "blockblock"; greedy = true; }
              { name = "chatgpt"; greedy = true; }
              { name = "chrome-remote-desktop-host"; greedy = true; }
              { name = "cleanshot"; greedy = true; }
              { name = "crystalfetch"; greedy = true; }
              #{ name = "cursor"; greedy = true; }
              { name = "discord"; greedy = true; }
              { name = "docker"; greedy = true; }
              { name = "elektron-transfer"; greedy = true; }
              { name = "epic-games"; greedy = true; }
              { name = "focusrite-control"; greedy = true; }
              { name = "gimp"; greedy = true; }
              { name = "google-assistant"; greedy = true; }
              { name = "google-chrome"; greedy = true; }
              # { name = "google-chrome@canary"; greedy = true; }
              { name = "hstracker"; greedy = true; }
              { name = "istat-menus"; greedy = true; }
              #{ name = "iterm2"; greedy = true; }
              { name = "izotope-product-portal"; greedy = true; }
              { name = "jetbrains-toolbox"; greedy = true; }
              { name = "karabiner-elements"; greedy = true; }
              # { name = "keybase"; greedy = true; }
              #{ name = "kitty"; greedy = true; }
              { name = "knockknock"; greedy = true; }
              { name = "lm-studio"; greedy = true; }
              { name = "logitech-g-hub"; greedy = true; }
              #{ name = "logseq"; greedy = true; }
              { name = "lulu"; greedy = true; }
              { name = "macupdater"; greedy = true; }
              { name = "native-access"; greedy = true; }
              #{ name = "neovide"; greedy = true; }
              { name = "notchnook"; greedy = true; }
              { name = "noti"; greedy = true; }
              { name = "notion"; greedy = true; }
              { name = "numi"; greedy = true; }
              { name = "obsidian"; greedy = true; }
              #{ name = "ollama"; greedy = true; }
              { name = "onyx"; greedy = true; }
              #{ name = "postman"; greedy = true; }
              { name = "proxyman"; greedy = true; }
              { name = "raycast"; greedy = true; }
              { name = "scroll-reverser"; greedy = true; }
              { name = "slack"; greedy = true; }
              { name = "spitfire-audio"; greedy = true; }
              { name = "splice"; greedy = true; }
              { name = "spotify"; greedy = true; }
              { name = "steam"; greedy = true; }
              { name = "swish"; greedy = true; }
              { name = "taskexplorer"; greedy = true; }
              { name = "the-unarchiver"; greedy = true; }
              { name = "topnotch"; greedy = true; }
              { name = "utm"; greedy = true; }
              { name = "vcv-rack"; greedy = true; }
              { name = "vmware-fusion"; greedy = true; }
              # { name = "warp"; greedy = true; }
              { name = "waves-central"; greedy = true; }
              { name = "wezterm@nightly"; greedy = true; }
              { name = "xca"; greedy = true; }
              { name = "youlean-loudness-meter"; greedy = true; }
              { name = "zoom"; greedy = true; }
            ];
          };
          fonts.packages = [
            pkgs.jetbrains-mono
            pkgs.nerd-fonts.jetbrains-mono
            pkgs.hack-font
            pkgs.meslo-lgs-nf
            pkgs.montserrat
          ];
          networking = {
            computerName = secrets.hostname;
            hostName = secrets.hostname;
            localHostName = secrets.hostname;
            dns = secrets.networking.dns;
            search = secrets.networking.search;
            knownNetworkServices = [
              "Wi-Fi"
              "USB 10/100/1000 LAN"
            ];
          };
          nix.settings = {
            allowed-users = secrets.allowed-users;
          };
        };
      homeconfig =
        { pkgs, ... }:
        {
          # this is internal compatibility configuration
          # for home-manager, don't change this!
          home.stateVersion = "24.05";

          # Let home-manager install and manage itself.
          programs.home-manager.enable = true;
          programs.git = {
            enable = true;
            userName = secrets.git.name;
            userEmail = secrets.git.mail;
            ignores = [ ".DS_Store" ];
            extraConfig = {
              init.defaultBranch = "main";
              push.autoSetupRemote = true;
            };
          };
          programs.zsh = {
            enable = true;
            oh-my-zsh = {
              enable = true;
              custom = ".zsh/";
              extraConfig = ''
                PATH="~/.spicetify:~/.config/composer/vendor/bin:/nix/var/nix/profiles/default/bin:~/.nix-profile/bin:/run/current-system/sw/bin:/opt/homebrew/bin:$PATH"
                fastfetch
                # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
                # Initialization code that may require console input (password prompts, [y/n]
                # confirmations, etc.) must go above this block; everything else may go below.
                if [[ -r "''\${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''\${(%):-%n}.zsh" ]]; then
                    source "''\${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''\${(%):-%n}.zsh"
                fi


                zstyle ':omz:update' mode reminder  # just remind me to update when it's time
                zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
                zstyle ':fzf-tab:complete:*:*' fzf-preview 'less ''\${(Q)realpath}'


                source ~/git/zsh-syntax-highlighting-rose/zsh-syntax-highlighting.zsh

                [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
                [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

                # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
                [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

                . "$HOME/.cargo/env"

                eval "$(zoxide init zsh --cmd cd)"

                unset ZSH_AUTOSUGGEST_USE_ASYNC
                                
                # Revalidate bat cache with mtime
                BAT_THEME_CACHE="$(command bat --cache-dir)/themes.bin"
                BAT_THEMES_DIR="$(command bat --config-dir)/themes"
                if [ ! -e "$BAT_THEME_CACHE" ] || [ -n "$(find "$BAT_THEMES_DIR" -name '*.tmTheme' -newer "$BAT_THEME_CACHE")" ]; then
                	command bat cache --build 1>/dev/null
                fi
              '';
              plugins = [
                "git"
                "bgnotify"
                "docker"
                "safe-paste"
                #"fzf"
              ];
            };
            shellAliases = secrets.shellAliases;
            sessionVariables = {
              PATH = "/opt/homebrew/bin:$PATH:~/.spicetify:~/.config/composer/vendor/bin";
              LANG = "en_US.UTF-8";
              # Limit restic backup CPU cores
              GOMAXPROCS = "4";
            };
            plugins = [
              {
                name = "zsh-autosuggestions";
                src = pkgs.fetchFromGitHub {
                  owner = "zsh-users";
                  repo = "zsh-autosuggestions";
                  rev = "v0.7.1";
                  sha256 = "sha256-vpTyYq9ZgfgdDsWzjxVAE7FZH4MALMNZIFyEOBLm5Qo=";
                };
              }
              {
                name = "fzf-tab";
                src = pkgs.fetchFromGitHub {
                  owner = "Aloxaf";
                  repo = "fzf-tab";
                  rev = "v1.2.0";
                  sha256 = "sha256-q26XVS/LcyZPRqDNwKKA9exgBByE0muyuNb0Bbar2lY=";
                };
              }
              {
                name = "zsh-syntax-highlighting";
                src = pkgs.fetchFromGitHub {
                  owner = "zsh-users";
                  repo = "zsh-syntax-highlighting";
                  rev = "0.8.0";
                  sha256 = "sha256-iJdWopZwHpSyYl5/FQXEW7gl/SrKaYDEtTH9cGP7iPo=";
                };
              }
              {
                name = "powerlevel10k";
                src = pkgs.zsh-powerlevel10k;
                file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
              }
            ];
          };

          programs.eza = {
            enable = true;
            enableZshIntegration = true;
            icons = "always";
            colors = "always";
          };

          programs.yazi = {
            enable = true;
            enableZshIntegration = true;
            initLua = ./yazi_init.lua;
          };

          home.packages = with pkgs; [
            (python3.withPackages (
              ps: with ps; [
                jupyterlab
                matplotlib
                numpy
                pandas
                psycopg2
                python-lsp-server
                seaborn
                sqlalchemy
              ]
            ))
          ];

          home.sessionVariables = {
            EDITOR = "nvim";
          };

          home.file.".resticignore".source = ./resticignore;
          home.file.".lessfilter" = {
            source = ./lessfilter;
            executable = true;
          };
          home.file.".config/wezterm/wezterm.lua".source = ./wezterm.lua;
          home.file.".config/yazi/yazi.toml".source = ./yazi.toml;
          home.file.".config/yazi/theme.toml".source = ./yazi_theme.toml;
          home.file.".config/yazi/flavors/tokyo-night.yazi" = {
            source = builtins.fetchGit {
              url = "https://github.com/BennyOe/tokyo-night.yazi.git";
              ref = "refs/heads/main";
              rev = "024fb096821e7d2f9d09a338f088918d8cfadf34";
              allRefs = true;
            };
            recursive = true;
          };
          home.file.".config/fastfetch/config.jsonc".source = ./fastfetch_config.jsonc;
          home.file.".config/bat/config".source = ./bat_config;
          home.file.".config/bat/themes/tokyonight_night.tmTheme".source = ./tokyonight_night.tmTheme;
          home.file."Library/KeyBindings/DefaultKeyBinding.dict".source = ./DefaultKeyBinding.dict;
        };
    in
    {
      darwinConfigurations.Geist = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              # Install Homebrew under the default prefix
              enable = true;

              user = secrets.userConfig.name;

              # Automatically migrate existing Homebrew installations
              autoMigrate = true;
            };
          }
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              verbose = true;
              users.eliah = homeconfig;
            };
          }
        ];
      };
    };
}
