{ pkgs, username, homeDirectory, ... }:

{
  home.username = username;
  home.homeDirectory = homeDirectory;
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    # Editor
    vscode

    # Languages / runtimes
    nodejs_22
    python312
    uv
    pnpm

    # Build toolchain
    gcc
    clang
    gnumake
    cmake
    ninja
    pkg-config

    # Source control
    git-lfs
    gh

    # Containers
    docker-compose

    # Kubernetes / infrastructure
    kubectl
    kubernetes-helm
    k9s
    terraform

    # Databases / data services
    postgresql
    redis

    # API / RPC
    protobuf
    grpcurl
    httpie

    # Modern CLI tools
    ripgrep
    fd
    jq
    yq-go
    tree
    htop
    btop
    bat
    eza

    # Networking
    wget
    openssl
    dnsutils
    iperf3

    # Archives
    zip
    unzip

    # Load testing
    hey
    vegeta
  ];

  programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
  };

  programs.tmux = {
    enable = true;
    mouse = true;
    clock24 = true;

    extraConfig = ''
      set -g history-limit 100000
      set -g base-index 1
      setw -g pane-base-index 1
      set -g default-terminal "tmux-256color"
      set -sg escape-time 10
    '';
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "eza -lah";
      ls = "eza";
      cat = "bat";

      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git pull";

      k = "kubectl";
      d = "docker";
      dc = "docker compose";
    };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
