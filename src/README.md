# System Builder

## Physical SuT Setup

### sudo

Requires sudo without a password (on the target only), for I4 lab add the following to FAI config:

    # Luis Gerhorst
    gerhorst faui49easy*=(ALL:ALL) NOPASSWD: ALL

Without FAI, add it to `/etc/sudoers` on the target.

### Local Scratch Dir

```sh
system-under-test$ sudo mkdir -p /srv/scratch/$CONTROL_SYSTEM_USER
system-under-test$ sudo chown $USER /srv/scratch/$CONTROL_SYSTEM_USER
```

### Wake-on-LAN

SSH config must auto-wake the target SuT using WoL if it is suspended, for I4 lab add the following to `.ssh/config`:

    # On the control system.
    
    Host i4lab1*
    	Hostname i4lab1.informatik.uni-erlangen.de
    	ProxyJump none
    
    Host i4lab2*
    	Hostname i4lab2.informatik.uni-erlangen.de
    	ProxyJump none
    
    Match originalhost faui49* exec "bash -c 'ssh i4lab1 wake %n | grep --invert-match failed'"
    	Hostname %h.cs.fau.de
    	Port 22
    	ProxyJump i4lab1
        
If Wake-on-LAN is not available, [disable autosuspend and hibernation](https://wiki.debian.org/Suspend).

### Evaluation Mode

Reserve the target for exclusive access and disable automatic (re-)configuration, for example:

    # If supported:
    set-system-mode evaluation
    
    # Fallback:
    sudo systemctl disable fai-boot.service
    sudo systemctl disable run-fai.service
    sudo systemctl disable run-fai.timer
    
    # Undo, run by ./scripts/release-target.sh:
    set-system-mode normal
    sudo systemctl enable run-fai.timer
    sudo systemctl enable fai-boot.service


## Quick Start

Boot the VM (or boot the real target):

    make qemu

Other terminal:

    make all

The latter installs the required software on the target system under test and ensures that the kernel checked out in the subdirectory is booted. That is, the system is ready for evaluation. May be called repeatedly by bench-scripts to evaluate different configurations.

Rebooting qemu into a new kernel using grub does not work. For this, use VMM.

## Related Work

-   salt, cfengine, fai: Are they suitable for rapid deployment?

