# 0.0.15 (5 Oct 2018)
* Add xmlrpc as explicit dependency
* Fix for md5 on OSX (wojciech@koszek.com)

# 0.0.14 (27 July 2017)
* Fix use of snapshots
* Better error when when the host doesn't have the required PIF
* No longer require netcat on the target host

# 0.0.8 (8 September 2014)

* Correct typos

# 0.0.7 (8 September 2014)

* Use --insecure when uploading, as XS uses self-signed certs

# 0.0.6 (8 September 2014)

* Change other uploaders to https too

# 0.0.5 (5 September 2014)

* Upload VHDs over https rather than http
* Suspend/Resume (Simon Beaumont)

# 0.0.4 (10 July 2014)

* Enable NFS synced folders
* Add the halt action

# 0.0.3 (8 July 2014)

* Enable vagrant ssh -c

# 0.0.2 (7 July 2014)

* Support older versions of qemu-img that don't output
  json

# 0.0.1 (7 July 2014)

* Use the md5 of the first meg of VHD to tag the base VDI
  This is much more unique than the name/version pair

# 0.0.0 (1 July 2014)

* Initial release.

