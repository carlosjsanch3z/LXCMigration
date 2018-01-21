# LXCMigration
Small script to make the migration of a static web page from one LXC container to another

## Optional: 
Execute PurgeScenario.sh to clean traces of a previous execution.

## StartScenario.sh
Start container 1
Add the logical volume to the container
Mount the volume on /var/www/html
Restart the apache2 service

## Memtester.sh

The script will request the name of the container, depending on which container it will execute the memtester command with some options or others.

## Migration.sh 

When one of the containers is using more RAM, the script will perform the automatic migration.

### Automatic with Systemd

Move systemd files to the path: /etc/systemd/system/

Start timers:

~~~
systemctl enable minute-timer.timer
systemctl enable lxc-migration.service
systemctl start minute-timer.timer
~~~

Monitoring:
~~~
journalctl -f -u lxc-migration.service
journalctl -f -u minute-timer.timer
~~~

View timer list:

~~~
systemctl list-timers
~~~
