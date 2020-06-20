#!bin/bash
INSTALL_GROUP="mysql"
INSTALL_USER="mysql"
PORT=3306
DATA_HOME=/data/mysql
BACKUP_HOME=/data/backup
SCRIPT_HOME=/data/ops/shell
INSTALL_FILE="/data/ops/software/mysql/mysql-5.7.*.tar.gz"
INSTALL_FOLDER="/usr/local/mysql"
ROOT_PWD="root123"
START_TIME=$(date +'%Y-%m-%d %H:%M:%S')

echo "###step 1： create install group and user"
yum install -y libaio libaio-devel
groupadd ${INSTALL_GROUP}
useradd -r -g ${INSTALL_GROUP} -s /bin/false ${INSTALL_USER}

echo "###step 2: create mysql data & log folder"
mkdir -p ${DATA_HOME}
chmod -R 770 ${DATA_HOME}
chown -R ${INSTALL_USER}.${INSTALL_GROUP} ${DATA_HOME}
mkdir -p ${BACKUP_HOME}
mkdir -p ${SCRIPT_HOME}

echo "###step 3: configure /etc/my.cnf"
\cp -f ./my5.7.cnf /etc/my.cnf

echo "###step 4: unzip install file"
cd /usr/local
tar -zxf ${INSTALL_FILE}
mv mysql*-x86_64 mysql
chown -R ${INSTALL_USER}.${INSTALL_GROUP}/usr/local/mysql

echo "###step 5: initialize mysql"
cd ${INSTALL_FOLDER}/bin
./mysqld --defaults-file=/etc/my.cnf --initialize --user=${INSTALL_USER} --basedir=${INSTALL_FOLDER} --datadir=${DATA_HOME}
if [ $? -eq 0 ]; then
	echo $(date +'%Y-%m-%d %H:%M:%S')" initialize mysql completed"
else
	echo $(date +'%Y-%m-%d %H:%M:%S')" [ERROR] initialize mysql failed"
	exit
fi

echo "###step 6: config mysql service"
cp -f ${INSTALL_FOLDER}/support-files/mysql.server /etc/rc.d/init.d/mysqld
chmod 770 /etc/rc.d/init.d/mysqld
chkconfig mysqld on
echo $(date +'%Y-%m-%d %H:%M:%S')" configure mysql service completed"

echo "###step 7: make a soft link or setup env"
ln -sf ${INSTALL_FOLDER}/bin/mysql /usr/bin/mysql
echo $(date +'%Y-%m-%d %H:%M:%S')" make link completed"

echo "###step 8: start mysqld service"
service mysqld start
if [ $? -eq 0 ]; then
	echo $(date +'%Y-%m-%d %H:%M:%S')" mysql started"
else
	echo $(date +'%Y-%m-%d %H:%M:%S')" [ERROR] mysql start failed"
	exit
fi

echo "###step 9: change root's password"
tmpwd=$(grep "temporary password" ${DATA_HOME}/error.log | cut -d "@" -f 2 | cut -d " " -f 2)
echo "temporary password: ${tmpwd}"
tmpsql="alter user 'root'@'localhost' identified by '"${ROOT_PWD}"'"
mysql -uroot -p""""${tmpwd}"""" --connect-expired-password -e "${tmpsql}"
if [ $? -eq 0 ]; then
	echo $(date +'%Y-%m-%d %H:%M:%S')" change root's password successfully"
else
	echo $(date +'%Y-%m-%d %H:%M:%S')" [ERROR] change root's password failed"
	exit
fi

echo "##############################"
echo "mysql install successfully"
echo "##############################"
STOP_TIME=$(date +'%Y-%m-%d %H:%M:%S')
echo "start_time: ${START_TIME}"
echo "stop_time: ${STOP_TIME}"
