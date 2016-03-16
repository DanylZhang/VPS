yum -y install yum-utils
rpm --import "http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF"
yum-config-manager --add-repo http://download.mono-project.com/repo/centos/
yum install mono-complete.x86_64 -y
wget http://www.linuxdot.net/down/jexus-5.8.1.tar.gz
tar -zxvf jexus-5.8.1.tar.gz
cd  jexus-5.8.1
./install
/usr/jexus/jws start
