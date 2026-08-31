# Running large backups on diskstation

## Backup Strategy & Architecture

### Redundancy & Synchronization

Our backup infrastructure relies on two local backup servers deployed across separate branch offices, connected via a site-to-site VPN. Local drives are encrypted at the hardware level, and data is synchronized weekly between both servers every weekend.

### Directory Structure & Base Backups

Each host is assigned its own directory under `/volume1/Encrypted/Machines/`. Inside each host directory, backups are organized by baseline folders named using the `BASE[YYYYMMDD]` convention (reflecting the initial setup date). If a machine is wiped or reinstalled, a new `BASE` folder is created to begin a fresh chain.

### Archiving & Snapshots

When a BASE directory becomes obsolete (e.g., after a machine replacement) or reaches a major milestone, it is archived into a compressed .tar.gz file paired with a file list log. These archives are saved to the primary snapshot directory at `/volume1/Encrypted/Snapshots/`.

### Cloud Offsite Replication

Snapshot archives are synced to at least two distinct cloud providers using rclone. rclone performs client-side encryption prior to transfer, ensuring all offsite data remains fully encrypted end-to-end.


**The following needs verification and refactoring of the current commands if needed. Check also to see difference in Snapshot directory vs. Fridge (long term storage) concept?**

```bash

# example of copy scripts to either Hetzner or BackBlaze;

/usr/local/bin/rclone copy /volume1/InSync enc-hsb01:/home/Machines/diskstation/Fridge --verbose
/usr/local/bin/rclone copy /volume1/InSync enc-bb2-eu:SkylightDiskstationFridge --b2-chunk-size 200M --verbose

# example of check script to Hetzner

/usr/local/bin/rclone cryptcheck /volume1/InSync enc-hsb01:/home/Machines/diskstation/Fridge --verbose

```


## Create an archived version of a BASE folder as a zipped tar file

This process creates a compressed snapshot of a directory as a .tar.gz file, accompanied by a sidecar log file. The log file allows you to quickly search for specific files without uncompressing or extracting the full archive.

The archive itself remains unencrypted locally because rclone automatically handles client-side encryption before syncing it to the cloud.

```bash
nohup tar -cvzf /volume1/Encrypted/Snapshots/macbook-elisabeth/BASE20260703.tar.gz -C /volume1/Encrypted/Machines/macbook-elisabeth/backup BASE20260703 > /volume1/Encrypted/Snapshots/macbook-elisabeth/BASE20260703.log 2>&1 &
```

Monitor the progress in real time by tailing the log file:

```bash
tail -f BASE20260703.log
```

### TODO

```bash
/usr/local/bin/rclone bisync /volume1/Encrypted ds-hq:Encrypted
nohup /usr/local/bin/rclone bisync /volume1/Encrypted ds-hq:Encrypted --resync -v > ./rclone-bisync-resync.log 2>&1 &
```
