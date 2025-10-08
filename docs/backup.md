# Backup

## Create individual backup step script

### Create a backup from your home drive

```bash
#!/bin/bash

source "$HOME/okaeri/config/boot"

source=/home/smath
destination=/media/smath/BackupSmatPopOs/backup/BASE20251006/home/smath
watchdog=<token>

echo "[backup] source:      $source"
echo "[backup] destination: $destination"
echo "[backup] watchdog:    $watchdog"

run="run-$(date +%s)"

echo "[backup] run:         $run"

$OKAERI_PATH/usr/bin/mytime-watchdog $watchdog $run begin

echo "[backup] start"

/usr/bin/rclone sync $source $destination \
  --filter-from $OKAERI_PATH/usr/etc/rclone/home-filter-from.txt \
  --delete-excluded \
  --log-level info \
  --checksum \
  --skip-links

if [ $? -ne 0 ]; then
  echo "[backup] end - error"

  $OKAERI_PATH/usr/bin/mytime-watchdog $watchdog $run error --message "Backup Failed ($?)"
  $OKAERI_PATH/usr/bin/mytime-notification --icon "fa-hdd-o red" --name "[slider] Home" --description "Backup Failed ($?)" --user backup
else
  echo "[backup] end - success"

  $OKAERI_PATH/usr/bin/mytime-watchdog $watchdog $run end
  $OKAERI_PATH/usr/bin/mytime-notification --icon "fa-hdd-o green" --name "[slider] Home" --description "Backup Complete" --user backup
fi

echo "[backup] done"
```

### Create a backup from your backup drive to diskstation

```bash
#!/bin/bash

source "$HOME/okaeri/config/boot"

source=/media/smath/BackupSmatPopOs/backup
destination=diskstation:Encrypted/Machines/slider/backup
watchdog=<token>

echo "[backup] source:      $source"
echo "[backup] destination: $destination"
echo "[backup] watchdog:    $watchdog"

run="run-$(date +%s)"

echo "[backup] run:         $run"

$OKAERI_PATH/usr/bin/mytime-watchdog $watchdog $run begin

echo "[backup] start"

/usr/bin/rclone sync $source $destination \
  --log-level info \
  --checksum \
  --skip-links

if [ $? -ne 0 ]; then
  echo "[backup] end - error"

  $OKAERI_PATH/usr/bin/mytime-watchdog $watchdog $run error --message "Backup Failed ($?)"
  $OKAERI_PATH/usr/bin/mytime-notification --icon "fa-hdd-o red" --name "[slider] Diskstation" --description "Backup Failed ($?)" --user backup
else
  echo "[backup] end - success"

  $OKAERI_PATH/usr/bin/mytime-watchdog $watchdog $run end
  $OKAERI_PATH/usr/bin/mytime-notification --icon "fa-hdd-o green" --name "[slider] Diskstation" --description "Backup Complete" --user backup
fi

echo "[backup] done"
```

### Create a backup all script

```bash
#!/bin/bash

source "$HOME/okaeri/config/boot"

source "$HOME/bin/backup-home-to-backup"
source "$HOME/bin/backup-backup-to-diskstation"
```

## Cron

```bash
10 20 * * * ~/bin/backup-home-to-backup > $HOME/Log/backup-home-to-backup-cron.log 2>&1
10 2 * * * ~/bin/backup-backup-to-diskstation > $HOME/Log/backup-backup-to-diskstation-cron.log 2>&1
```