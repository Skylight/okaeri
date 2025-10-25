Format a USB drive in ext4 (passwordless) and give the volume a name e.g. 'unlock'

Identify the USB key (device name should look something like `/dev/sdX1`)
```bash
lsblk -f # lists the devices, note the drive id e.g. /dev/sdb1
```

Obtain the USB_UUID (replace `/dev/sdX1` with the actual device);
```bash
sudo blkid /dev/sdX1
```

The device id will look something like we'll use it later as `USB_UUID`;
```bash
12345678-90ab-cdef-1234-567890abcdef
```

Find the USB drive in your system;
```bash
ls /media/smath # e.g. /media/smath/unlock
```

Generate a random key and place it on the usb key, change the file mode to 0400;
```bash
sudo dd if=/dev/urandom of=/media/smath/unlock/luks-key.bin bs=4096 count=1
sudo chmod 0400 /media/smath/unlock/luks-key.bin
```

Identify the actual drive that you want to unlock with the key;
```bash
lsblk -f # lists the devices, note the drive id e.g. /dev/sdb1
```

Outputs:

```bash
NAME        FSTYPE      LABEL    UUID                                 MOUNTPOINT
sda
├─sda1      vfat                 1234-ABCD                            /boot/efi
├─sda2      ext4                 5678-90EF                            /boot
└─sda3      crypto_LUKS          a1b2c3d4-e5f6-7890-1234-56789abcdef0
  └─cryptroot
     ├─vgubuntu-root ext4        1111-2222                            /
     └─vgubuntu-swap swap        3333-4444                            [SWAP]
```

Where `/dev/sda3` in this example is the drive to unlock.

Verify;

```bash
sudo cryptsetup luksDump /dev/sda3
```


```
sudo cryptsetup luksAddKey /dev/sda3 /mnt/usb/luks-key.bin
```

Create a file that contains the following script `/etc/initramfs-tools/scripts/local-top/usb-key-unlock`
```bash
#!/bin/sh

PREREQ=""
prereqs() { echo "$PREREQ"; }
case "$1" in prereqs) prereqs; exit 0 ;; esac

USB_UUID="8d724db0-e7fc-4720-aaa5-b0376cb7a695"
KEY_ON_USB_PATH="/luks-key.bin"

USB_DEV="/dev/disk/by-uuid/$USB_UUID"
if [ -e "$USB_DEV" ]; then
  mkdir -p /keytmp
  mount "$USB_DEV" /keytmp 2>/dev/null || exit 0
  if [ -r /keytmp${KEY_ON_USB_PATH} ]; then
    cp /keytmp${KEY_ON_USB_PATH} /crypto_keyfile.bin
    chmod 0400 /crypto_keyfile.bin
  fi
  umount /keytmp
fi
```

The change the mode to `755`;

```bash
sudo chmod 755 /etc/initramfs-tools/scripts/local-top/usb-key-unlock
```

Modify the `/etc/crypttab` file from;
```bash
cryptroot UUID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx none luks
```

to
```bash
cryptroot UUID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx /crypto_keyfile.bin luks
```

The whole file should look something like this;
```bash
cryptdata UUID=c958f979-c6be-424b-afe9-2b69cdb93faf /crypto_keyfile.bin luks
```

Regenerate initramfs;
```bash
sudo update-initramfs -u
```

Reboot and test!