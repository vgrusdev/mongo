how I made mongod-org (community edition) 4.0.3 binaries for ppc64le:

used base from Dockerfile, then...

https://github.com/mongodb/mongo/blob/r4.0.3/docs/building.md

pip2 install -r buildscripts/requirements.txt
used manually one-be-one... in other case there is an error....

apt-get install python-pip git libffi-dev

pip install pyyaml
pip install typing

git clone https://github.com/mongodb/mongo.git
cd mongo
git checkout r4.0.3

python2 buildscripts/scons.py mongod
python2 buildscripts/scons.py mongos
python2 buildscripts/scons.py mongo

python2 buildscripts/scons.py [mongod] --prefix=/opt/mongo install



Linking build/opt/mongo/mongod
Install file: "build/opt/mongo/mongod" as "mongod"
scons: done building targets.

build/opt/mongo/mongod --version
db version v4.0.3
git version: 7ea530946fa7880364d88c8d8b6026bbc9ffa48c
allocator: tcmalloc
modules: none
build environment:
    distarch: ppc64le
    target_arch: ppc64le


You can try hkp://p80.pool.sks-keyservers.net:80 or hkps://hkps.pool.sks-keyservers.net in place of ha.pool.sks-keyservers.net, and might have more success in limited enviroments (since it'll then use port 80 or 443 instead):


mongodb-org-tools	Contains the following MongoDB tools: mongoimport bsondump, mongodump, mongoexport, mongofiles, mongorestore, mongostat, and mongotop.


+ apt-get install -y mongodb-org=4.0.3 mongodb-org-server=4.0.3 mongodb-org-shell=4.0.3 mongodb-org-mongos=4.0.3 mongodb-org-tools=4.0.3
Reading package lists...
Building dependency tree...
Reading state information...
The following extra packages will be installed:
  ca-certificates krb5-locales libcurl3 libgssapi-krb5-2 libidn11 libk5crypto3
  libkeyutils1 libkrb5-3 libkrb5support0 libldap-2.4-2 librtmp1 libsasl2-2
  libsasl2-modules libsasl2-modules-db libssh2-1 libssl1.0.0 openssl
Suggested packages:
  krb5-doc krb5-user libsasl2-modules-otp libsasl2-modules-ldap
  libsasl2-modules-sql libsasl2-modules-gssapi-mit
  libsasl2-modules-gssapi-heimdal
The following NEW packages will be installed:
  ca-certificates krb5-locales libcurl3 libgssapi-krb5-2 libidn11 libk5crypto3
  libkeyutils1 libkrb5-3 libkrb5support0 libldap-2.4-2 librtmp1 libsasl2-2
  libsasl2-modules libsasl2-modules-db libssh2-1 libssl1.0.0 mongodb-org
  mongodb-org-mongos mongodb-org-server mongodb-org-shell mongodb-org-tools
  openssl
0 upgraded, 22 newly installed, 0 to remove and 0 not upgraded.

/etc/mongod.conf

/usr/bin/mongo
/usr/bin/mongod
/usr/bin/mongos

/usr/bin/install_compass
/usr/bin/bsondump
/usr/bin/mongodump
/usr/bin/mongoexport
/usr/bin/mongofiles
/usr/bin/mongoimport
/usr/bin/mongorestore
/usr/bin/mongostat
/usr/bin/mongotop


	
To see all the files the package installed onto your system, do this:

dpkg-query -L <package_name>
To see the files a .deb file will install

dpkg-deb -c <package_name.deb>
To see the files contained in a package NOT installed, do this once (if you haven't installed apt-file already:

sudo apt-get install apt-file
sudo apt-file update
then

apt-file list <package_name>

I'm trying to build MongoDB from source codes, for now just mongod. After build "mongod" executable file is big as 510Mb (!!!). Does someone know about this, what parameters I must pass to make result build more compact? I'm chasing a build result that is close to "releases from MongoDB", where mongod is almost ~50Mb.

This is almost certainly due to debug information. The binaries you get when downloaded are stripped, but the raw build results are not (since developers typically want the debug info). If you would like to strip the debug info out, try the following scons invocation (note that the \ before the $ is significant and required):

scons <your-args-here> \$BUILD_DIR/mongo/stripped/mongod

That should yield you a stripped mongod binary under <some-path>/mongo/stripped, and an associated debug file mongod.debug, in the parent directory. For me, for instance:

$ buildscripts/scons.py --dbg=on -j16 \$BUILD_DIR/mongo/stripped/mongod
...
scons: Building targets ...
...
/usr/bin/objcopy --only-keep-debug build/debug/mongo/mongod build/debug/mongo/mongod.debug
/usr/bin/objcopy --strip-debug --add-gnu-debuglink build/debug/mongo/mongod.debug build/debug/mongo/mongod build/debug/mongo/stripped/mongod
scons: done building targets.

Then you can get the stripped mongod binary from build/debug/mongo/stripped/mongod and the associated debug symbols file from build/debug/mongo/mongod.debug. Note that if you are comfortable with objcopy, you can simply perform the above steps yourself on your existing binary, or just use the strip utility if you aren't interested in the debug symbols.


hat files is stripped (debugging symbols & sections and relocation information are cleaned from files). Try this:

strip -sg mongod


