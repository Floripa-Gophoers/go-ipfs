# FUSE

As a golang project, `go-ipfs` is easily downloaded and installed with `go get github.com/ipfs/go-ipfs`. All data is stored in a leveldb data store in `~/.ipfs/datastore`. If, however, you would like to mount the datastore (`ipfs mount /ipfs`) and use it as you would a normal filesystem, you will need to install fuse.

As a precursor, you will have to create the `/ipfs` and `/ipns` directories explicitly. Note that modifying root requires sudo permissions.

```sh
# make the directories
sudo mkdir /ipfs
sudo mkdir /ipns

# chown them so ipfs can use them without root permissions
sudo chown <username> /ipfs
sudo chown <username> /ipns
```

Depending on whether you are using OSX or Linux, follow the proceeding instructions.

## Mac OSX -- OSXFUSE

It has been discovered that versions of `osxfuse` prior to `2.7.0` will cause a kernel panic. For everyone's sake, please upgrade (latest at time of writing is `2.7.4`). The installer can be found at https://osxfuse.github.io/. There is also a homebrew formula (`brew install osxfuse`) but users report best results installing from the official OSXFUSE installer package.

Note that `ipfs` attempts an automatic version check on `osxfuse` to prevent you from shooting yourself in the foot if you have pre `2.7.0`. Since checking the OSXFUSE version [is more complicated than it should be], running `ipfs mount` may require you to install another binary:

```sh
go get github.com/jbenet/go-fuse-version/fuse-version
```

If you run into any problems installing FUSE or mounting IPFS, hop on IRC and speak with us, or if you figure something new out, please add to this document!

## Linux

Install `fuse` with your favorite package manager:

```
sudo apt-get install fuse
```

Then change permissions on the fuse config:

```sh
sudo chown <username>:<groupname> /etc/fuse.conf
```

You may also have to change `/dev/fuse`:

```sh
sudo chown <username>:<groupname> /dev/fuse
```

Note: `<groupname>` will usually be `fuse`. Typically, you add the authorized users to the `fuse` group:

```sh
sudo usermod -a -G fuse <username>
```

## Mounting IPFS

Once FUSE and the mountpoints have been created, issue the following command:

```sh
ipfs daemon --mount
```

If you wish to allow other users to use the mount points, edit /etc/fuse.conf to enable non-root users, i.e.:

```sh
# /etc/fuse.conf - Configuration file for Filesystem in Userspace (FUSE)

# Set the maximum number of FUSE mounts allowed to non-root users.
# The default is 1000.
#mount_max = 1000

# Allow non-root users to specify the allow_other or allow_root mount options.
user_allow_other
```

and use the following:

```sh
ipfs config --json Mounts.FuseAllowOther true
ipfs daemon --mount
```

## Troubleshooting

### Getting `Permission denied` or `fusermount: user has no write access to mountpoint` error in Linux

Verify that the config file can be read by your user:
```sh
sudo ls -l /etc/fuse.conf
-rw-r----- 1 root fuse 216 Jan  2  2013 /etc/fuse.conf
```
In most distributions group named `fuse` will be created during installation. You can check with:

```sh
sudo grep -q fuse /etc/group && echo fuse_group_present || echo fuse_group_missing
```

If group is present, just add your regular user to the `fuse` group:
```sh
sudo usermod -G fuse -a <username>
```

If not, create `fuse` group (add your regular user to it) and set necessary permissions, for example:
```sh
sudo chgrp fuse /etc/fuse.conf
sudo chmod g+r  /etc/fuse.conf
sudo chgrp fuse /ipfs /ipns
sudo chmod g+rw /ipfs /ipns
```

Note that the use of `fuse` group is optional and may depend on your operating system.
It is okay to use a different group as long as proper permissions are set for user running `ipfs mount` command.

### Mount command crashes and mountpoint gets stuck

```
sudo umount /ipfs
sudo umount /ipns
```

If you manage to mount on other systems (or followed an alternative path to one above), please contribute to these docs :D
