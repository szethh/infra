# Setup NixOS in LXC

[This tutorial](https://blog.xirion.net/posts/nixos-proxmox-lxc/) is outdated but still has useful pointers.

Follow instructions [here](https://nixos.wiki/wiki/Proxmox_Virtual_Environment#LXC) to generate the lxc template.

Upload to proxmox using the webui. sample config file:
```
arch: amd64
cores: 2
features: nesting=1
hostname: blokk
memory: 4096
net0: name=eth0,bridge=vmbr0,firewall=1,hwaddr=0A:A4:81:19:E3:EF,ip=dhcp,ip6=dhcp,type=veth
ostype: nixos
rootfs: speed:subvol-103-disk-0,size=128G
swap: 512
unprivileged: 1

\# tailscale
lxc.cgroup2.devices.allow: c 10:200 rwm
lxc.mount.entry: /dev/net/tun dev/net/tun none bind,create=file
```

Then, create a CT (nesting enabled). `pct enter 103` to attach to it.
Every time we attach, we have to run `source /etc/set-environment`.

# Tailscale setup
As per [the tailscale docs](https://tailscale.com/kb/1130/lxc-unprivileged/)
edit the container config `nano /etc/pve/lxc/103.conf` and add
```
lxc.cgroup2.devices.allow: c 10:200 rwm
lxc.mount.entry: /dev/net/tun dev/net/tun none bind,create=file
```


# configuration.nix
`/etc/nixos/configuration.nix` should look like this:

```nix
[nix-shell:~]$ cat /etc/nixos/configuration.nix 
{ pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
  ];

  time.timeZone = "Europe/Amsterdam";

  networking.hostName = "blokk"; # Define your hostname.
  networking.nameservers = [ "1.1.1.1" "9.9.9.9" ];
  
  environment.systemPackages = with pkgs; [
    tailscale
    htop
  ];

  users.groups.szeth = {
    gid = 1000;
  };

  users.users.szeth = {
    isNormalUser = true;
    description = "szeth";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
    #  firefox
    #  thunderbird
    ];

    uid = 1000;
    group = "szeth";
    openssh.authorizedKeys.keys = [
    # Add more SSH public keys if needed, each on a new line.
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDgnIn7uXqucLjBn3fcJtRoeTVtpAIs/vFub8ULiud1f szeth@mackie.local"
   ];
  };

  virtualisation.docker.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.tailscale.enable = true;

  nix.settings.experimental-features = "nix-command flakes";

}
```


### Note on proxmox template
I made a lxc template (id 103), however i forgot to set the ssh public key for my mac (see above nix file).

I also forgot to run passwd... So run passwd for root and passwd szeth for the user.

Also, tailscale is installed but `tailscale up` must be run to login and register the container.




## Bind mount

To pass a folder into the container, run `pct set 100 -mp0 /mnt/storage,mp=/mnt/storage`.


The permissions will be fucked. 3 files must be edited:

Host: `/etc/subuid`
```
root:100000:65536
valorad:165536:65536
root:1000:1
```

Host: `/etc/subgid`
```
root:100000:65536
valorad:165536:65536
root:1000:1
```

Add this to the bottom of `/etc/pve/lxc/100.conf` and reboot the lxc:
```
lxc.idmap: u 0 100000 1000
lxc.idmap: g 0 100000 1000
lxc.idmap: u 1000 1000 1
lxc.idmap: g 1000 1000 1
lxc.idmap: u 1001 101001 64530
lxc.idmap: g 1001 101001 64530
```