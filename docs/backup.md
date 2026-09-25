# Backup

## Create individual backup step script

### Create a backup from your home drive

```bash
#!/bin/bash

source "$HOME/okaeri/config/boot"

source=/home/smath
destination=/media/smath/ScooterBackup/backup/BASE20260802/home/smath
watchdog=<token>

echo "[backup] source:      $source"
echo "[backup] destination: $destination"
echo "[backup] watchdog:    $watchdog"

run="run-$(date +%s)"

echo "[backup] run:         $run"

$OKAERI_PATH/usr/bin/mytime-watchdog $watchdog $run begin

echo "[backup] start"

/usr/bin/rsync --archive \
  --verbose \
  --checksum \
  --delete-excluded \
  --filter=". $OKAERI_PATH/usr/etc/rclone/home-filter-from.txt" \
  --no-links \
  --info=progress2,name0 \
  "$source/" "$destination/"

if [[ $? -ne 0 ]]; then
  echo "[backup] end - error"

  $OKAERI_PATH/usr/bin/mytime-watchdog $watchdog $run error --message "Backup Failed ($?)"
  $OKAERI_PATH/usr/bin/mytime-notification --icon "fa-hdd-o red" --name "[$OKAERI_HOSTNAME] Home" --description "Backup Failed ($?)" --user backup
else
  echo "[backup] end - success"

  $OKAERI_PATH/usr/bin/mytime-watchdog $watchdog $run end
  $OKAERI_PATH/usr/bin/mytime-notification --icon "fa-hdd-o green" --name "[$OKAERI_HOSTNAME] Home" --description "Backup Complete" --user backup
fi

echo "[backup] done"
```

### Backup Virtual Machines

```bash
#!/bin/bash

source "$HOME/okaeri/config/boot"

source=/home/smath/VirtualMachines
destination=/media/smath/ScooterBackup/backup/VirtualMachines
watchdog=<token>
vm=win10

echo "[backup] source:      $source"
echo "[backup] destination: $destination"
echo "[backup] watchdog:    $watchdog"
echo "[backup] vm:          $vm"

run="run-$(date +%s)"

echo "[backup] run:         $run"

$OKAERI_PATH/usr/bin/mytime-watchdog $watchdog $run begin

running=$($OKAERI_PATH/usr/bin/virtual-machine-manager running $vm)

if [[ "$running" == "yes" ]]; then
	echo "[backup] stopping vm \`$vm\`"

	$OKAERI_PATH/usr/bin/mytime-watchdog $watchdog $run log --message "[backup] stopping vm \`$vm\`"

	$OKAERI_PATH/usr/bin/virtual-machine-manager stop $vm

	if [ $? -ne 0 ]; then
		$OKAERI_PATH/usr/bin/mytime-watchdog $watchdog $run error --message "Failed to stop VM ($?)"
		$OKAERI_PATH/usr/bin/mytime-notification --icon "fa-hdd-o red" --name "[$OKAERI_HOSTNAME] Virtual Machines" --description "Failed to stop VM ($?)" --user backup

		exit 1
	fi
fi

echo "[backup] start"
$OKAERI_PATH/usr/bin/mytime-watchdog $watchdog $run log --message "[backup] start"

/usr/bin/rsync --archive \
  --verbose \
  --checksum \
  --no-links \
  --info=progress2,name0 \
  "$source/" "$destination/"


if [ $? -ne 0 ]; then
  echo "[backup] end - error"

  $OKAERI_PATH/usr/bin/mytime-watchdog $watchdog $run error --message "Backup Failed ($?)"
  $OKAERI_PATH/usr/bin/mytime-notification --icon "fa-hdd-o red" --name "[$OKAERI_HOSTNAME] Virtual Machines" --description "Backup Failed ($?)" --user backup
else
  echo "[backup] end - success"

  $OKAERI_PATH/usr/bin/mytime-watchdog $watchdog $run end
  $OKAERI_PATH/usr/bin/mytime-notification --icon "fa-hdd-o green" --name "[$OKAERI_HOSTNAME] Virtual Machines" --description "Backup Complete" --user backup
fi

echo "[backup] done"
$OKAERI_PATH/usr/bin/mytime-watchdog $watchdog $run log --message "[backup] done"


if [[ "$running" == "yes" ]]; then
	echo "[backup] starting vm \`$vm\`"

	$OKAERI_PATH/usr/bin/virtual-machine-manager start $vm
fi
```

### Create a backup from your backup drive to diskstation

```bash
#!/bin/bash

source "$HOME/okaeri/config/boot"

source=/media/smath/ScooterBackup/backup
destination=diskstation.lasgarosses.net:/volume1/Encrypted/Machines/$OKAERI_HOSTNAME/backup
watchdog=<token>

echo "[backup] source:      $source"
echo "[backup] destination: $destination"
echo "[backup] watchdog:    $watchdog"

run="run-$(date +%s)"

echo "[backup] run:         $run"

$OKAERI_PATH/usr/bin/mytime-watchdog $watchdog $run begin

echo "[backup] start"

/usr/bin/rsync --archive \
  --verbose \
  --checksum \
  --delete \
  --no-links \
  --info=progress2,name0 \
  --rsync-path="/bin/rsync" \
  "$source/" "$destination/"

if [ $? -ne 0 ]; then
  echo "[backup] end - error"

  $OKAERI_PATH/usr/bin/mytime-watchdog $watchdog $run error --message "Backup Failed ($?)"
  $OKAERI_PATH/usr/bin/mytime-notification --icon "fa-hdd-o red" --name "[$OKAERI_HOSTNAME] Diskstation" --description "Backup Failed ($?)" --user backup
else
  echo "[backup] end - success"

  $OKAERI_PATH/usr/bin/mytime-watchdog $watchdog $run end
  $OKAERI_PATH/usr/bin/mytime-notification --icon "fa-hdd-o green" --name "[$OKAERI_HOSTNAME] Diskstation" --description "Backup Complete" --user backup
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
10 22 * * 3,6 ~/bin/backup-virtualmachines-to-backup > $HOME/Log/backup-virtualmachines-to-backup-cron.log 2>&1
10 23 * * * ~/bin/backup-backup-to-diskstation > $HOME/Log/backup-backup-to-diskstation-cron.log 2>&1
```