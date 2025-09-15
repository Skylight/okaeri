# okaeri

## Setup

### Change machine name

Change your machine name before anything else.

```
Settings -> About -> Machine Name
```

Then reboot.

### Generate SSH keys and add them to GitHub

If you are installing a new machine, generate SSH keys and add them to your github account.

```bash
ssh-keygen
```

### Run updates via Pop!_shop

Update all local packages on the system with `Pop!_shop`.

If you get the error "Pagekit Daemon disappeared" ([Reddit: PackageKit daemon disappeared](https://www.reddit.com/r/pop_os/comments/1hcmg6x/packagekit_daemon_disappeared/));

```bash
sudo dpkg --configure -a
sudo apt update
sudo apt upgrade
```

### Install packages via Pop!_shop

See [Developer machine setup instructions](docs/dev-setup.md);

### Run the installer script

Run the installer script.

```bash
curl -fsSL https://raw.githubusercontent.com/Skylight/okaeri/refs/heads/main/setup.sh | bash
```

