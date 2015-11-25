#!/usr/bin/env python
import sys
import os
import subprocess
import argparse
import shutil
import urllib

def exists(p):
	return os.path.isfile(p) or os.path.isdir(p)

def cmd(c):
	new_env = os.environ.copy()
	new_env["DEBIAN_FRONTEND"] = "noninteractive"
	result = subprocess.Popen(c, shell = True, env = new_env)
	try:
		result.communicate()
	except KeyboardInterrupt:
		pass
	return (result.returncode == 0)

def sudo(s):
	return cmd("sudo %s" % s)

def die(d):
	print d
	sys.exit(1)

def is_docker():
	 return os.path.isfile("/.dockerinit")

def is_vagrant():
	return os.path.isfile("/etc/is_vagrant_vm")
	
def cp(s, d):
	return sudo("cp %s %s" % (s, d))
	
sudo("apt-get install -y git curl tar gzip") or die("Unable to install tar utilities.")
if exists("/tmp/btsync.tar.gz"):
	sudo("rm -fr /tmp/btsync.tar.gz")
sudo("curl http://download-new.utorrent.com/endpoint/btsync/os/linux-i386/track/stable > /tmp/btsync.tar.gz") or die("Unable to download BTSync tarball.")
sudo("tar xzvf /tmp/btsync.tar.gz -C /usr/bin btsync") or die("Unable to extract btsync binary.")
if exists("/tmp/ngcdn"):
	sudo("rm -fr /tmp/ngcdn")
sudo("git clone --depth 1 https://github.com/mattneel/ngcdn.git /tmp/ngcdn") or die("Unable to clone ngcdn repository.")
cp("/tmp/ngcdn/config/btsync.conf", "/etc/btsync.conf") or die("Unable to copy BTSync configuration.")
if not is_docker():
	cp("/tmp/ngcdn/config/btsync.upstart.conf", "/etc/init/btsync.conf") or die("Unable to copy BTSync daemon configuration.")
	sudo("service btsync start") or die("Unable to start BTSync service.")
