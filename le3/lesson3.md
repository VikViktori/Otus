# Дисковая подсистема Linux

__Домашнее задание:__

• добавить в Vagrantfile еще дисков

• собрать R0/R5/R10 на выбор

• прописать собранный рейд в конф, чтобы рейд собирался при загрузке

• сломать/починить raid 

• создать GPT раздел и 5 партиций и смонтировать их на диск.

В качестве проверки принимается - измененный Vagrantfile, скрипт для создания рейда, конф для автосборки рейда при загрузке.

* Доп. задание - Vagrantfile, который сразу собирает систему с подключенным рейдом


__Проверка:__

- измененный Vagrantfile,
- скрипт для создания рейда,
- конф для автосборки рейда при загрузке.

## Результат

В качестве проверки:
- [Vagrantfile](./le3/Vagrantfile)
- [Скрипт настойки RAID](./le3/raid10.sh)
- [mdadm.conf](./le3/mdadm.conf)


## Ход

[vagrant@otuslinux ~]$ sudo lshw -short | grep disk
/0/100/1.1/0.0.0    /dev/sda   disk        42GB VBOX HARDDISK
/0/100/d/0          /dev/sdb   disk        104MB VBOX HARDDISK
/0/100/d/1          /dev/sdc   disk        104MB VBOX HARDDISK
/0/100/d/2          /dev/sdd   disk        104MB VBOX HARDDISK
/0/100/d/3          /dev/sde   disk        104MB VBOX HARDDISK
/0/100/d/0.0.0      /dev/sdf   disk        104MB VBOX HARDDISK


[vagrant@otuslinux ~]$ sudo mdadm --create --verbose /dev/md0 -l 1 -n 2 /dev/sdb /dev/sdd
mdadm: layout defaults to left-symmetric
mdadm: layout defaults to left-symmetric
mdadm: chunk size defaults to 512K
mdadm: size set to 100352K
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md0 started.
[vagrant@otuslinux ~]$ sudo mdadm --create --verbose /dev/md1 -l 1 -n 2 /dev/sde /dev/sdc
mdadm: Note: this array has metadata at the start and
    may not be suitable as a boot device.  If you plan to
    store '/boot' on this device please ensure that
    your boot-loader understands md/v1.x metadata, or use
    --metadata=0.90
mdadm: size set to 101376K
Continue creating array? 
Continue creating array? (y/n) y
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md1 started.
[vagrant@otuslinux ~]$ sudo mdadm --create --verbose /dev/md10 -l 0 -n 2 /dev/md0 /dev/md1
mdadm: chunk size defaults to 512K
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md10 started.
[vagrant@otuslinux ~]$ 


[vagrant@otuslinux ~]$ cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4] [raid1] [raid0] 
md10 : active raid0 md1[1] md0[0]
      198656 blocks super 1.2 512k chunks
      
md1 : active raid1 sdc[1] sde[0]
      101376 blocks super 1.2 [2/2] [UU]
      
md0 : active raid1 sdd[1] sdb[0]
      101376 blocks super 1.2 [2/2] [UU]
      
unused devices: <none>
[vagrant@otuslinux ~]$ 


[vagrant@otuslinux ~]$ sudo mdadm -D /dev/md0
/dev/md0:
           Version : 1.2
     Creation Time : Tue Nov 12 21:06:13 2024
        Raid Level : raid1
        Array Size : 101376 (99.00 MiB 103.81 MB)
     Used Dev Size : 101376 (99.00 MiB 103.81 MB)
      Raid Devices : 2
     Total Devices : 2
       Persistence : Superblock is persistent

       Update Time : Tue Nov 12 21:07:26 2024
             State : clean 
    Active Devices : 2
   Working Devices : 2
    Failed Devices : 0
     Spare Devices : 0

Consistency Policy : resync

              Name : otuslinux:0  (local to host otuslinux)
              UUID : 49a80f4f:aec4c5c6:14f83081:d895aeca
            Events : 17

    Number   Major   Minor   RaidDevice State
       0       8       16        0      active sync   /dev/sdb
       1       8       48        1      active sync   /dev/sdd
[vagrant@otuslinux ~]$ sudo mdadm -D /dev/md1
/dev/md1:
           Version : 1.2
     Creation Time : Tue Nov 12 21:07:10 2024
        Raid Level : raid1
        Array Size : 101376 (99.00 MiB 103.81 MB)
     Used Dev Size : 101376 (99.00 MiB 103.81 MB)
      Raid Devices : 2
     Total Devices : 2
       Persistence : Superblock is persistent

       Update Time : Tue Nov 12 21:07:26 2024
             State : clean 
    Active Devices : 2
   Working Devices : 2
    Failed Devices : 0
     Spare Devices : 0

Consistency Policy : resync

              Name : otuslinux:1  (local to host otuslinux)
              UUID : 6bec531f:15df094b:3319cab6:a9d33f88
            Events : 17

    Number   Major   Minor   RaidDevice State
       0       8       64        0      active sync   /dev/sde
       1       8       32        1      active sync   /dev/sdc
[vagrant@otuslinux ~]$ sudo mdadm -D /dev/md10
/dev/md10:
           Version : 1.2
     Creation Time : Tue Nov 12 21:07:25 2024
        Raid Level : raid0
        Array Size : 198656 (194.00 MiB 203.42 MB)
      Raid Devices : 2
     Total Devices : 2
       Persistence : Superblock is persistent

       Update Time : Tue Nov 12 21:07:25 2024
             State : clean 
    Active Devices : 2
   Working Devices : 2
    Failed Devices : 0
     Spare Devices : 0

        Chunk Size : 512K

Consistency Policy : none

              Name : otuslinux:10  (local to host otuslinux)
              UUID : 0de848d4:7ea73dc1:c38bc235:ea0651bb
            Events : 0

    Number   Major   Minor   RaidDevice State
       0       9        0        0      active sync   /dev/md0
       1       9        1        1      active sync   /dev/md1


Создание конфигурационного файла mdadm.conf

Для того, чтобы быть уверенным, что ОС запомнила, какой RAID массив требуется создать и какие компоненты в него входят, создадим файл mdadm.conf

Сначала убедимся, что информация верна:

[vagrant@otuslinux ~]$ mdadm --detail --scan --verbose
mdadm: must be super-user to perform this action
[vagrant@otuslinux ~]$ sudo mdadm --detail --scan --verbose
ARRAY /dev/md0 level=raid1 num-devices=2 metadata=1.2 name=otuslinux:0 UUID=49a80f4f:aec4c5c6:14f83081:d895aeca
   devices=/dev/sdb,/dev/sdd
ARRAY /dev/md1 level=raid1 num-devices=2 metadata=1.2 name=otuslinux:1 UUID=6bec531f:15df094b:3319cab6:a9d33f88
   devices=/dev/sdc,/dev/sde
ARRAY /dev/md10 level=raid0 num-devices=2 metadata=1.2 name=otuslinux:10 UUID=0de848d4:7ea73dc1:c38bc235:ea0651bb
   devices=/dev/md0,/dev/md1
[vagrant@otuslinux ~]$ sudo mkdir /etc/mdadm

[vagrant@otuslinux ~]$ echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
[vagrant@otuslinux ~]$ sudo mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf

Сломать/починить RAID

[vagrant@otuslinux ~]$ sudo mdadm /dev/md10 --fail /dev/md0
mdadm: set device faulty failed for /dev/md0:  Device or resource busy
[vagrant@otuslinux ~]$ sudo mdadm /dev/md0 --fail /dev/sdb
mdadm: set /dev/sdb faulty in /dev/md0
[vagrant@otuslinux ~]$ sudo mdadm -D /dev/md0
/dev/md0:
           Version : 1.2
     Creation Time : Tue Nov 12 21:06:13 2024
        Raid Level : raid1
        Array Size : 101376 (99.00 MiB 103.81 MB)
     Used Dev Size : 101376 (99.00 MiB 103.81 MB)
      Raid Devices : 2
     Total Devices : 2
       Persistence : Superblock is persistent

       Update Time : Tue Nov 12 21:11:51 2024
             State : clean, degraded 
    Active Devices : 1
   Working Devices : 1
    Failed Devices : 1
     Spare Devices : 0

Consistency Policy : resync

              Name : otuslinux:0  (local to host otuslinux)
              UUID : 49a80f4f:aec4c5c6:14f83081:d895aeca
            Events : 19

    Number   Major   Minor   RaidDevice State
       -       0        0        0      removed
       1       8       48        1      active sync   /dev/sdd

       0       8       16        -      faulty   /dev/sdb
[vagrant@otuslinux ~]$ sudo mdadm /dev/md0 --remove /dev/sdb
mdadm: hot removed /dev/sdb from /dev/md0
[vagrant@otuslinux ~]$ sudo mdadm -D /dev/md0
/dev/md0:
           Version : 1.2
     Creation Time : Tue Nov 12 21:06:13 2024
        Raid Level : raid1
        Array Size : 101376 (99.00 MiB 103.81 MB)
     Used Dev Size : 101376 (99.00 MiB 103.81 MB)
      Raid Devices : 2
     Total Devices : 1
       Persistence : Superblock is persistent

       Update Time : Tue Nov 12 21:12:10 2024
             State : clean, degraded 
    Active Devices : 1
   Working Devices : 1
    Failed Devices : 0
     Spare Devices : 0

Consistency Policy : resync

              Name : otuslinux:0  (local to host otuslinux)
              UUID : 49a80f4f:aec4c5c6:14f83081:d895aeca
            Events : 20

    Number   Major   Minor   RaidDevice State
       -       0        0        0      removed
       1       8       48        1      active sync   /dev/sdd
[vagrant@otuslinux ~]$ sudo mdadm /dev/md0 --add /dev/sdb
mdadm: added /dev/sdb
[vagrant@otuslinux ~]$ cat /proc/mdstat 
Personalities : [raid6] [raid5] [raid4] [raid1] [raid0] 
md10 : active raid0 md1[1] md0[0]
      198656 blocks super 1.2 512k chunks
      
md1 : active raid1 sdc[1] sde[0]
      101376 blocks super 1.2 [2/2] [UU]
      
md0 : active raid1 sdb[2] sdd[1]
      101376 blocks super 1.2 [2/1] [_U]
      [=====>...............]  recovery = 25.1% (25600/101376) finish=0.0min speed=12800K/sec
      
unused devices: <none>
[vagrant@otuslinux ~]$ 

Создать GPT раздел, пять партиций и смонтировать их на диск

[root@mdadm ~]$ parted -s /dev/md10 mklabel gpt

[vagrant@otuslinux ~]$ parted /dev/md10 mkpart primary ext4 0% 20%
[vagrant@otuslinux ~]$ parted /dev/md10 mkpart primary ext4 20% 40%
[vagrant@otuslinux ~]$ parted /dev/md10 mkpart primary ext4 40% 60%
[vagrant@otuslinux ~]$ parted /dev/md10 mkpart primary ext4 60% 80%
[vagrant@otuslinux ~]$ parted /dev/md10 mkpart primary ext4 80% 100%


[vagrant@otuslinux ~] $ for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md10p$i; done

[vagrant@otuslinux ~]$ mkdir -p /raid/part{1,2,3,4,5}
[vagrant@otuslinux ~]$ mount /dev/md10p1 /raid/part1
[vagrant@otuslinux ~]$ mount /dev/md10p2 /raid/part2
