#!/bin/bash
sudo mdadm --zero-superblock --force /dev/sd{b,c,d,e}
sudo mdadm --create --verbose /dev/md0 -l 1 -n 2 /dev/sdb /dev/sdd
sudo mdadm --create --verbose /dev/md1 -l 1 -n 2 /dev/sdc /dev/sde
sudo mdadm --create --verbose /dev/md10 -l 0 -n 2 /dev/md0 /dev/md1
sudo mkdir /etc/mdadm
echo "DEVICE partitions" | sudo tee /etc/mdadm/mdadm.conf
sudo mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' | sudo tee -a /etc/mdadm/mdadm.conf
sudo parted -s /dev/md10 mklabel gpt
sudo parted /dev/md10 mkpart primary ext4 0% 50%
sudo parted /dev/md10 mkpart primary ext4 50% 100%
sudo mkfs.ext4 /dev/md10p1
sudo mkfs.ext4 /dev/md10p2
sudo mkdir -p /raid/part1
sudo mkdir -p /raid/part2
sudo mount /dev/md10p1 /raid/part1
sudo mount /dev/md10p2 /raid/part2
cat /proc/mdstat