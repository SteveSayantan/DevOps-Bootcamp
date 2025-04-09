## WHAT 
Amazon Elastic Block Store (Amazon EBS) provides scalable, high-performance block storage resources that can be used with Amazon Elastic Compute Cloud (Amazon EC2) instances.

Amazon EBS Volumes are storage volumes that you attach to Amazon EC2 instances. After you attach a volume to an instance, you can use it in the same way you would use a local hard drive attached to a computer, for example to store files or to install applications.

## PREFACE
When we create an EC2 instance, an EBS volume of size 8GB is assigned to it by default. It has a device name of `xvda`. It is represented by the file `/dev/xvda` and mounted at the root directory.

```bash
ubuntu@ip-172-31-85-225:~$ lsblk
NAME     MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
loop0      7:0    0 25.2M  1 loop /snap/amazon-ssm-agent/7993
loop1      7:1    0 55.7M  1 loop /snap/core18/2829
loop2      7:2    0 55.4M  1 loop /snap/core18/2846
loop3      7:3    0 38.8M  1 loop /snap/snapd/21759
loop4      7:4    0 44.4M  1 loop /snap/snapd/23545
xvda     202:0    0    8G  0 disk
├─xvda1  202:1    0    7G  0 part /
├─xvda14 202:14   0    4M  0 part
├─xvda15 202:15   0  106M  0 part /boot/efi
└─xvda16 259:0    0  913M  0 part /boot
```
A block device can have multiple partitions (e.g. xvda1, xvda14, xvda15, xvda16). These partitions are represented by the files `/dev/xvda1`, `/dev/xvda14`, `/dev/xvda15`,`/dev/xvda16`.

## HOW
### 📌 Step 1: Create an EBS Volume
- Log in to AWS Management Console.
- Navigate to **EC2 Dashboard** → Click on **"Volumes"** under the **Elastic Block Store (EBS)** section. The default volumes attached to the existing ec2 instances are also listed here. 
- Click **"Create Volume"**.
- Configure the volume:
  - **Size**: (e.g., 10 GiB)
  - **Volume Type**: (e.g., gp3 for general-purpose SSD)
  - **Availability Zone (AZ)**: Must match the EC2 instance's AZ.
  - **IOPS** and **Throughput**: Leave as default.
  - **Encryption** (Optional): Enable if needed.
  - **Snapshot ID**: Provide the ID of the snapshot from which to create the volume. Otherwise, choose **Don't create volume from a snapshot** .
- Click **Create Volume** → Wait for it to be in an Available state.
### 📌 Step 2: Attach the EBS Volume to an EC2 Instance
- Select the newly created volume from the Volumes page.
- Click **"Actions"** → Select **"Attach Volume"**.
- Choose the EC2 instance from the dropdown list.
- Set the Device Name, e.g.,`/dev/sdf` as it is a data volume.
  > Recommended device names for Linux: /dev/sda1 for root volume. /dev/sd[f-p] for data volumes.
- Click **"Attach volume"**.
> Important: Newer Linux kernels may rename the devices to **/dev/xvdf** through **/dev/xvdp** internally, even when the device name entered and displayed is **/dev/sdf** through **/dev/sdp**

We can verify that the new volume is attached to the ec2 using `lsblk`.
```bash
ubuntu@ip-172-31-85-225:~$ lsblk
NAME     MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
loop0      7:0    0 25.2M  1 loop /snap/amazon-ssm-agent/7993
loop1      7:1    0 55.7M  1 loop /snap/core18/2829
loop2      7:2    0 55.4M  1 loop /snap/core18/2846
loop3      7:3    0 38.8M  1 loop /snap/snapd/21759
loop4      7:4    0 44.4M  1 loop /snap/snapd/23545
xvda     202:0    0    8G  0 disk
├─xvda1  202:1    0    7G  0 part /
├─xvda14 202:14   0    4M  0 part
├─xvda15 202:15   0  106M  0 part /boot/efi
└─xvda16 259:0    0  913M  0 part /boot
xvdf     202:80   0    5G  0 disk
```

## Creating Partitions
Make sure the volume we'll be creating partitions on, is unmounted and empty. The device name of our volume is `xvdf`, hence, to unmount it, we would use `umount /dev/xvdf`. However, as our volume is not mounted, we don't need to do it.

Any data present in the volume will be completely lost after creating a new partition, so make sure to choose an empty volume.
### 📌 Creating a partition of size 2GB

- Run `sudo fdisk /dev/xvdf`.

- In the **fdisk** prompt, 
  - type `m` to get the list of available options.

  - type `F` to list the free unpartitioned space.

    ```bash
    Command (m for help): F
    Unpartitioned space /dev/xvdf: 5 GiB, 5367660544 bytes, 10483712 sectors
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes

    Start      End  Sectors Size
    2048 10485759 10483712   5G
    ```
    As we can see, we have 5GB of unpartitioned space.

  - To create a new empty GPT partition table (recommended), we type `g`.
    ```bash
    Command (m for help): g
    Created a new GPT disklabel (GUID: 6AB96D5B-D68F-4B10-AC7E-40072C93EE0F).
    ```
  - To add a new partition to the empty partition table, we type `n`.
  - When prompted for **Partition number**, choose the default (Press Enter).
  - When prompted for **First sector**, choose the default (Press Enter).
  - When prompted for **Last sector**, we type `+2G` for creating a partition of size 2 GB.
    ```bash
    Command (m for help): n
    Partition number (1-128, default 1):
    First sector (2048-10485726, default 2048):
    Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-10485726, default 10483711): +2G

    Created a new partition 1 of type 'Linux filesystem' and of size 2 GiB.
    ```
  - type `w` to save the changes.
    ```bash
    Command (m for help): w
    The partition table has been altered.
    Calling ioctl() to re-read partition table.
    Syncing disks.
    ```
  > The format for size of the partition is: 10K(KB), 10M(MB), 10G(GB),10T(TB)
### 📌 Creating another partition of size 3GB

- Run `sudo fdisk /dev/xvdf`.

- In the **fdisk** prompt, 
  - type `p` to print the existing partition table.
    ```bash
    Command (m for help): p
    Disk /dev/xvdf: 5 GiB, 5368709120 bytes, 10485760 sectors
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    Disklabel type: gpt
    Disk identifier: 6AB96D5B-D68F-4B10-AC7E-40072C93EE0F

    Device     Start     End Sectors Size Type
    /dev/xvdf1  2048 4196351 4194304   2G Linux filesystem
    ```
    Here, we can see our first partition of size 2 GB that we just created.

  - type `F` to list the free unpartitioned space.

    ```bash
    Command (m for help): F
    Unpartitioned space /dev/xvdf: 3 GiB, 3220160000 bytes, 6289375 sectors
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes

    Start      End Sectors Size
    4196352 10485726 6289375   3G
    ```
    So, we have 3GB of unpartitioned space remaining.

  - To add a new partition to the partition table, we type `n`.
  - When prompted for **Partition number**, choose the default (Press Enter).
  - When prompted for **First sector**, choose the default (Press Enter).
  - When prompted for **Last sector**, choose the default (Press Enter). It will create a partition out of the entire remaining space i.e. 3 GB.
    ```bash
    Command (m for help): n
    Partition number (2-128, default 2):
    First sector (4196352-10485726, default 4196352):
    Last sector, +/-sectors or +/-size{K,M,G,T,P}   (4196352-10485726, default 10483711):

    Created a new partition 2 of type 'Linux filesystem' and of size 3 GiB.
    ```
  - type `w` to save the changes.
    ```bash
    Command (m for help): w
    The partition table has been altered.
    Calling ioctl() to re-read partition table.
    Syncing disks.
    ```
## Formatting the Partitions
We can't use any of the partitions unless they are formatted with a filesystem. Here, as we'll be using both of the partitions in a linux system only, so we'll format both of them with `ext4` filesystem.

However, if you plan to use a storage device on multiple operating systems e.g. Windows, macOS, use `exfat` filesystem.

- List the partitions using `lsblk` command.
  ```bash
  ubuntu@ip-172-31-85-225:~$ lsblk
  NAME     MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
  loop0      7:0    0 25.2M  1 loop /snap/amazon-ssm-agent/7993
  loop1      7:1    0 55.7M  1 loop /snap/core18/2829
  loop2      7:2    0 55.4M  1 loop /snap/core18/2846
  loop3      7:3    0 38.8M  1 loop /snap/snapd/21759
  loop4      7:4    0 44.4M  1 loop /snap/snapd/23545
  xvda     202:0    0    8G  0 disk
  ├─xvda1  202:1    0    7G  0 part /
  ├─xvda14 202:14   0    4M  0 part
  ├─xvda15 202:15   0  106M  0 part /boot/efi
  └─xvda16 259:0    0  913M  0 part /boot
  xvdf     202:80   0    5G  0 disk
  ├─xvdf1  202:81   0    2G  0 part
  └─xvdf2  202:82   0    3G  0 part
  ```
  `xvdf1` and `xvdf2` are the two partitions we just created.
- Run `sudo mkfs.ext4 /dev/xvdf1` for formatting the `xvdf1` with ext4.
  ```bash
  ubuntu@ip-172-31-85-225:~$ sudo mkfs.ext4 /dev/xvdf1
  mke2fs 1.47.0 (5-Feb-2023)
  Creating filesystem with 524288 4k blocks and 131072 inodes
  Filesystem UUID: 3c5dfe18-de28-4a7d-a320-e712f17b49e5
  Superblock backups stored on blocks:
          32768, 98304, 163840, 229376, 294912

  Allocating group tables: done
  Writing inode tables: done
  Creating journal (16384 blocks): done
  Writing superblocks and filesystem accounting information: done
  ```
- Run `sudo mkfs.ext4 /dev/xvdf2` for formatting the `xvdf2` with ext4.

  ```bash
  ubuntu@ip-172-31-85-225:~$ sudo mkfs.ext4 /dev/xvdf2
  mke2fs 1.47.0 (5-Feb-2023)
  Creating filesystem with 785920 4k blocks and 196608 inodes
  Filesystem UUID: b7097ef2-61b6-42ec-992f-ad557e94d492
  Superblock backups stored on blocks:
          32768, 98304, 163840, 229376, 294912

  Allocating group tables: done
  Writing inode tables: done
  Creating journal (16384 blocks): done
  Writing superblocks and filesystem accounting information: done
  ```
## Mounting Partitions
Mouting refers to attaching a storage volume to a folder on the filesystem. Mounting is essential to access the contents of the storage volume.

We can mount a storage to anywhere in the filesystem. Generally, `/media` and `/mnt` are considered the most appropriate directories to mount a storage volume. 
- `/media` is used for mounting temporary storage volumes.
- `/mnt` is used for mounting permanent storage volumes.

### Steps
- Create the following directories `/mnt/study` and `/mnt/devops`.
- Run `sudo mount /dev/xvdf1 /mnt/study`. This mounts **xvdf1** to **/mnt/study**.
- Run `sudo mount /dev/xvdf2 /mnt/devops`. This mounts **xvdf2** to **/mnt/devops**.
- Run `lsblk` to verify.
```bash
ubuntu@ip-172-31-85-225:~$ sudo mkdir /mnt/study
ubuntu@ip-172-31-85-225:~$ sudo mkdir /mnt/devops
ubuntu@ip-172-31-85-225:~$ sudo mount /dev/xvdf1 /mnt/study
ubuntu@ip-172-31-85-225:~$ sudo mount /dev/xvdf2 /mnt/devops
ubuntu@ip-172-31-85-225:~$ lsblk
NAME     MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
loop0      7:0    0 25.2M  1 loop /snap/amazon-ssm-agent/7993
loop1      7:1    0 55.7M  1 loop /snap/core18/2829
loop2      7:2    0 55.4M  1 loop /snap/core18/2846
loop3      7:3    0 38.8M  1 loop /snap/snapd/21759
loop4      7:4    0 44.4M  1 loop /snap/snapd/23545
xvda     202:0    0    8G  0 disk
├─xvda1  202:1    0    7G  0 part /
├─xvda14 202:14   0    4M  0 part
├─xvda15 202:15   0  106M  0 part /boot/efi
└─xvda16 259:0    0  913M  0 part /boot
xvdf     202:80   0    5G  0 disk
├─xvdf1  202:81   0    2G  0 part /mnt/study
└─xvdf2  202:82   0    3G  0 part /mnt/devops
```
So, we can see both of the partitions have been mounted successfully.

## Unmounting Partitions
Once, the partitions are mounted, they can be used for storing data. Let's first create a file in both `/mnt/study` and `/mnt/devops` folders.

```
root@ip-172-31-85-225:/mnt/study# sudo su -     # switch to the root user to avoid permission issues
root@ip-172-31-85-225:/mnt/study# cd /mnt/study
root@ip-172-31-85-225:/mnt/study# echo "hello from study">test.txt
root@ip-172-31-85-225:/mnt/study# cd /mnt/devops
root@ip-172-31-85-225:/mnt/devops# echo "hello from devops">test.txt
root@ip-172-31-85-225:/mnt/devops# cat /mnt/study/test.txt
hello from study
root@ip-172-31-85-225:/mnt/devops# cat /mnt/devops/test.txt
hello from devops
```

- To unmount the `xvdf1` paritition, we use `sudo umount /dev/xvdf1`.

- Now, we can't access the file `/mnt/study/test.txt` anymore.
  ```
  root@ip-172-31-85-225:/mnt/devops# cat /mnt/study/test.txt
  cat: /mnt/study/test.txt: No such file or directory
  ```
- However, we can again mount it and access its content.
  ```bash
  ubuntu@ip-172-31-85-225:~$ sudo mount /dev/xvdf1 /mnt/study
  ubuntu@ip-172-31-85-225:~$ cat /mnt/study/test.txt
  hello from study
  ```
## Unmounting the Entire Volume
Before unmounting the entire volume, **we must first unmount its partitions**.

#### **1️⃣ Check Mounted Partitions**
```bash
lsblk
```
**Example Output:**
```bash
NAME     MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
loop0      7:0    0 25.2M  1 loop /snap/amazon-ssm-agent/7993
loop1      7:1    0 55.7M  1 loop /snap/core18/2829
loop2      7:2    0 55.4M  1 loop /snap/core18/2846
loop3      7:3    0 38.8M  1 loop /snap/snapd/21759
loop4      7:4    0 44.4M  1 loop /snap/snapd/23545
xvda     202:0    0    8G  0 disk
├─xvda1  202:1    0    7G  0 part /
├─xvda14 202:14   0    4M  0 part
├─xvda15 202:15   0  106M  0 part /boot/efi
└─xvda16 259:0    0  913M  0 part /boot
xvdf     202:80   0    5G  0 disk
├─xvdf1  202:81   0    2G  0 part /mnt/study
└─xvdf2  202:82   0    3G  0 part /mnt/devops
```
👉 `xvdf` is the **volume**, while `xvdf1` and `xvdf2` are **mounted partitions**.

#### **2️⃣ Unmount the Partitions First**
```bash
sudo umount /dev/xvdf1
sudo umount /dev/xvdf2
```

#### **3️⃣ Detach the Entire Volume**
- Log in to AWS Management Console.
- Navigate to **EC2 Dashboard** → **Elastic Block Store** section.
- Select the corresponding volume from the Volumes page.
- Click **"Actions"** → Select **"Detach Volume"**.
```bash
ubuntu@ip-172-31-85-225:~$ lsblk
NAME     MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
loop0      7:0    0 25.2M  1 loop /snap/amazon-ssm-agent/7993
loop1      7:1    0 55.7M  1 loop /snap/core18/2829
loop2      7:2    0 55.4M  1 loop /snap/core18/2846
loop3      7:3    0 38.8M  1 loop /snap/snapd/21759
loop4      7:4    0 44.4M  1 loop /snap/snapd/23545
xvda     202:0    0    8G  0 disk
├─xvda1  202:1    0    7G  0 part /
├─xvda14 202:14   0    4M  0 part
├─xvda15 202:15   0  106M  0 part /boot/efi
└─xvda16 259:0    0  913M  0 part /boot
```

#### **4️⃣ For Remounting**
  - Attach the volume to our ec2 instance using the same steps as earlier.
  - Mount the two partitions.

## Persistent Mounting
Everytime we reboot our instance, we need to mount these partitions manually. To avoid that, we add an entry in `/etc/fstab`. While booting, the system looks at this file and mounts everything included in it line-by-line.

Here, we make entry for the partition `xvdf1`:

- First, create a backup of `/etc/fstab` for safety.
  ```bash
  sudo cp /etc/fstab /etc/fstab.bk
  ```
- Run `sudo blkid /dev/xvdf1` to get the UUID for the partition `xvdf1`. Here, its UUID is `3c5dfe18-de28-4a7d-a320-e712f17b49e5`.
  ```
  ubuntu@ip-172-31-85-225:~$ sudo blkid /dev/xvdf1
  /dev/xvdf1: UUID="3c5dfe18-de28-4a7d-a320-e712f17b49e5" BLOCK_SIZE="4096" TYPE="ext4" PARTUUID="b756aea8-d30d-43f3-bb78-abf321a0f4df"
  ```
- Make sure the partition is **not mounted**, else **unmount it**.

- Run `sudo vi /etc/fstab`, add the line `UUID=3c5dfe18-de28-4a7d-a320-e712f17b49e5 /mnt/study ext4 defaults 0 2` at the end and save the file.
  - `UUID=3c5dfe18-de28-4a7d-a320-e712f17b49e5` is the device/partition to be mounted.
  - `/mnt/study` is the location of mounting.
  - `ext4` is the type of filesystem present in the device/partition.
  - `defaults` for applying default behaviors while mounting.
  - `0` used by the **dump** command; indicates **No automatic backup** for the filesystem in the device/partition. 
  - `2` indicates lower priority; The device/partition will be checked during boot by **fsck** (filesystem check), but only after the root filesystem.

- Run `sudo mount -a`: This will mount everything in `/etc/fstab` that are not mounted. In case of any misconfiguration, this will show error and the system will not boot up properly.

- Run `df -h` to check if it is mounted properly.

- Now, execute the same steps for `xvdf2`.

Finally, the `/etc/fstab` file will look like:
```bash
LABEL=cloudimg-rootfs   /        ext4   discard,commit=30,errors=remount-ro     0 1
LABEL=BOOT      /boot   ext4    defaults        0 2
LABEL=UEFI      /boot/efi       vfat    umask=0077      0 1
UUID=3c5dfe18-de28-4a7d-a320-e712f17b49e5 /mnt/study ext4 defaults 0 2
UUID=b7097ef2-61b6-42ec-992f-ad557e94d492 /mnt/devops ext4 defaults 0 2
```

## Useful Commands
- `lsblk`: lists all the block devices attached to the workstation. Use `-f` flag to get information about their filesystem type.
- `mount`: lists all the mounted storage devices on the system.