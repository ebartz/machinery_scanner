# Machinery Scanner



## Description

There is a Tool called [machinery](https://github.com/SUSE/machinery) which is capable of scanning an inventory of linux machines. This project consists of 2 components which are doing things around machinery. There is a scanner script which launches machinery for a bunch of hosts and is capable of doing it in parallel. Also the scanner script makes sure, that each time you scan a host, the result will be put into a GIT repository.

The second part of the project is a reporting script. As all scans are commited to a GIT repo, you can compare different states of your machines. For that reason this is kind of a change detection system.


## Quick Start

On CentOS 6 or 7 all you need to get started is machinery and GIT

### Machinery

Those commands will install you the requirements for machinery:

```
yum -y install ruby rubygems ruby-devel gcc zlib-devel patch xdg-utils golang
gem install rake machinery-tool
```
### GIT and Scripts
```
yum -y install git
git clone https://github.com/ebartz/machinery_scanner.git
```

### First Scans
After installing all the requirements, you can do the first scans just like this:

```
cd machinery_scanner
./scan.sh -h "host1 host2 host3"
```

## Components

### Scanner

```
Parameters:
  -h, --host     : specifies a hostname that you want to scan
  -f, --file     : specifies a file which contains a bunch of hostnames
  -p, --parallel : specifies the number of scans that should be performed in parallel. Default = 4

Examples:
Just scan one server:
./scan.sh -h my_server

Scan a list of hosts in a file with 10 scans in parallel:
./scan.sh -f host_list -p 10
```


### Reporting

```
[root@machinery_master machinery_scanner]# ./report.sh -h machinery_host1 -o machinery
List of available reports
9424859 Enrico Bartz    31 minutes ago  autocommit machinery_host1
d538be1 Enrico Bartz    24 hours ago    autocommit machinery_host1
dbd9337 Enrico Bartz    24 hours ago    autocommit machinery_host1
6119540 Enrico Bartz    24 hours ago    autocommit machinery_host1
b933c8f Enrico Bartz    25 hours ago    autocommit machinery_host1
cf2916b Enrico Bartz    25 hours ago    autocommit machinery_host1
dc581cc Enrico Bartz    25 hours ago    autocommit machinery_host1
e44e0e5 Enrico Bartz    25 hours ago    foo
9b5ae93 Enrico Bartz    25 hours ago    just some other changes
af5e9b2 Enrico Bartz    26 hours ago    initial commit
Please select an old Commit ID which you want to compare from.
d538be1
Please select a newer Commit ID with which ou want to compare.
9424859
# Packages

Only in 'machinery_host1_9424859':
  * httpd
  * httpd-tools
  * mailcap

# Users

Only in 'machinery_host1_9424859':
  * apache (Apache, uid: 48, gid: 48, shell: /sbin/nologin)

# Groups

Only in 'machinery_host1_9424859':
  * apache (gid: 48)

# Services

Only in 'machinery_host1_9424859':
  * htcacheclean.service: static
  * httpd.service: disabled

# Unmanaged Files

Only in 'machinery_host1_9424859':
  * /var/log/audit/audit.log.1 (file)

Following scopes are identical in both descriptions: os,patterns,repositories,changed_config_files,changed_managed_files
```
