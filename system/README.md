# System Builder


<a id="org1cc4dea"></a>

## Physical SuT Setup


<a id="orgdd06512"></a>

### sudo

Requires sudo without a password (on the target only), for I4 lab add the following to FAI config:

    # Luis Gerhorst
    gerhorst faui49easy*=(ALL:ALL) NOPASSWD: ALL


<a id="orgfad8b95"></a>

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


<a id="org30cd941"></a>

### Evaluation Mode

Reserve the target for exclusive access and disable automatic (re-)configuration, for example:

    # If supported:
    set-system-mode evaluation
    
    # Fallback:
    sudo systemctl disable fai-boot.timer
    sudo systemctl disable run-fai.timer
    
    # Undo:
    set-system-mode normal
    sudo systemctl enable run-fai.timer
    sudo systemctl enable fai-boot.timer


## Quick Start

Boot the VM (or boot the real target):

    make qemu

Other terminal:

    make all

The latter installs the required software on the target system under test and ensures that the kernel checked out in the subdirectory is booted. That is, the system is ready for evaluation. May be called repeatedly by bench-scripts to evaluate different configurations.


## Related Work

-   salt, cfengine, fai: Are they suitable for rapid deployment?

