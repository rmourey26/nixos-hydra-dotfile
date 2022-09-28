# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{

  nix.package = pkgs.nixFlakes;
  nix.useSandbox = true;
  nix.autoOptimiseStore = true;
  nix.readOnlyStore = false;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
    keep-outputs = true
    keep-derivations = true
  '';

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
  
  nix.buildMachines = [
    { hostName = "localhost";
      system = "x86_64-linux";
      supportedFeatures = ["kvm" "nixos-test" "big-parallel" "benchmark"];
      maxJobs = 8;
    }
  ];
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.useOSProber = true;
  networking.hostName = "nixos"; # Define your hostname.
  # Define additional host names
  networking.extraHosts = '' 
    127.0.0.2 other-localhost
    10.0.0.1 server
  '';  
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "America/New_York";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp2s0.useDHCP = true;
  networking.interfaces.wlp3s0.useDHCP = true;
  #Nixpks
  nixpkgs.config = {
    allowUnfree = true;
  }; 
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };
  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # Enable the Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.gnome.core-developer-tools.enable = true;
  services.postfix = {
    enable = true;
    setSendmail = true;
  };
  # Configure keymap in X11
  services.xserver.layout ="us";
  # services.xserver.xkbOptions = "eurosign:e";
  # Enable CUPS to print documents.
  services.printing.enable = true;
  programs.sway.enable = true;
  xdg.portal.wlr.enable = true;
  # Sandboxes
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;
  
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.rmourey26 = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" "deployer" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFtzlvFCMI+H8Cwa5yHo7X4tazSefdQ9vKyRMQFe9Z5V rmourey_jr@quantumone.network" ];
    packages = with pkgs; [
      python39Full
    ]; 
  };
  
 # home-manager.users.rmourey26 = { ... }: {
 #   imports = [ ../lib/rmourey26/base.nix ];   
 #   home.packages = [ pkgs.atool pkgs.httpie ];
 #     programs.bash.enable = true;
 #     programs.git = {
 #       package = pkgs.gitAndTools.gitFull;
 #       enable = true;
 #       userName = "rmourey26";
 #       userEmail = "rmourey_jr@quantumone.network";
 #     };
 # };
  # Entrusting the Nixops deployer

  nix.trustedUsers = [ "deployer" "rmourey26" "hydra" "hydra-evaluator" "hydra-queue-runner"  ];
  users.users.deployer.group = "deployer";
  security.sudo.wheelNeedsPassword = false;
  users.users.deployer = {
    isSystemUser = true;
  };
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    gh
    inotify-tools
    nodejs
    firefox
    perl
    gitAndTools.gitFull
    google-cloud-sdk-gce
    kubernetes
    kubernetes-helm
    kubeseal
    binutils
    gnutls
    bind
    neovim
    mkpasswd
    cachix
    shutter
    docker
    awscli
    python3
    ngrok  
  ];
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.seahorse.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
      permitRootLogin = "no";
      passwordAuthentication = false;
      forwardX11 = true;
      ports = [ 2022 ];
  };
  virtualisation.docker.enable = true;
  services.flatpak.enable = true;
  services.hydra = {
    enable = true;
    hydraURL = "https://hydra.quantumone.network";
    notificationSender = "hydra@hydra.quantumone.network";
    buildMachinesFiles = [];
    useSubstitutes = true;
    logo = "/var/lib/hydra/www/qone-color.png";
  };
  services.yggdrasil = {
    enable = true;
    persistentKeys = false;
      # The NixOS module will generate new keys and a new IPv6 address each time
      # it is started if persistentKeys is not enabled.

    config = {
      Peers = [
        # Yggdrasil will automatically connect and "peer" with other nodes it
        # discovers via link-local multicast annoucements. Unless this is the
        # case (it probably isn't) a node needs peers within the existing
        # network that it can tunnel to.
        "tcp://1.2.3.4:1024"
        "tcp://1.2.3.5:1024"
        # Public peers can be found at
        # https://github.com/yggdrasil-network/public-peers
      ];
    };
  };
  security.acme.acceptTerms = true;
  security.acme.email = "rmourey_jr@da-fi.com";
  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 20 22 80 443 53 111 113 2049 1080 3000 5432 8125 9198 9199 63333 ];
  networking.firewall.allowedUDPPorts = [ 20 22 80 443 53 111 113 2049 1080 3000 5432 8125 9198 9199 63333 ];
  networking.firewall.allowedTCPPortRanges = [
  { from = 512; to = 515; }
  { from = 4000; to = 4007; }
  { from = 6000; to = 6069; }
  { from = 8000; to = 8010; }
  { from = 3000; to = 3010; }
  { from = 8500; to = 8600; }
  { from = 5500; to = 5600; }
  ];
  networking.firewall.allowedUDPPortRanges = [
  { from = 512; to = 515; }
  { from = 4000; to = 4007; }
  { from = 6000; to = 6069; }
  { from = 8000; to = 8010; }
  { from = 3000; to = 3010; }
  { from = 8500; to = 8600; }
  { from = 5500; to = 5600; }
  ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  networking.defaultGateway = "10.0.0.120";
  networking.nameservers = [ "1.1.1.1" ];
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}

