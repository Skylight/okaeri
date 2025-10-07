# Backup

## Create individual backup step script

### Create a backup from your home drive

```bash
#!/bin/bash

source "$HOME/okaeri/config/boot"

source=<home>
destination=<destination>
watchdog=<watchdog>

echo "[backup] source:      $source"
echo "[backup] destination: $destination"
echo "[backup] watchdog:    $watchdog"

run="run-$(date +%s)"

echo "[backup] run:         $run"

/usr/bin/curl -X POST "https://mytime.skylight.be/api/radar/watchdog/$watchdog/$run/begin"

echo "[backup] start"

/usr/bin/rclone sync $source $destination \
  --filter-from $OKAERI_PATH/usr/etc/rclone/home-filter-from.txt \
  --delete-excluded \
  --log-level info \
  --checksum \
  --skip-links

if [ $? -ne 0 ]; then
  echo "[backup] end - error"

  /usr/bin/curl -X POST "https://mytime.skylight.be/api/radar/watchdog/$watchdog/$run/error"
else
  echo "[backup] end - success"

  /usr/bin/curl -X POST "https://mytime.skylight.be/api/radar/watchdog/$watchdog/$run/end"
fi

echo "[backup] done"
```

### Create a backup from your backup drive to diskstation

```bash
#!/bin/bash

source "$HOME/okaeri/config/boot"

source=/media/smath/BackupSmatPopOs/backup/BASE20251006
destination=diskstation:Encrypted/Machines/slider/BASE20251006
watchdog=212cbb674003b45c4ec4651b6c53313db877776f

echo "[backup] source:      $source"
echo "[backup] destination: $destination"
echo "[backup] watchdog:    $watchdog"

run="run-$(date +%s)"

echo "[backup] run:         $run"

/usr/bin/curl -X POST "https://mytime.skylight.be/api/radar/watchdog/$watchdog/$run/begin"

echo "[backup] start"

/usr/bin/rclone sync $source $destination \
  --log-level info \
  --checksum \
  --skip-links

if [ $? -ne 0 ]; then
  echo "[backup] end - error"

  /usr/bin/curl -X POST "https://mytime.skylight.be/api/radar/watchdog/$watchdog/$run/error"
else
  echo "[backup] end - success"

  /usr/bin/curl -X POST "https://mytime.skylight.be/api/radar/watchdog/$watchdog/$run/end"
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