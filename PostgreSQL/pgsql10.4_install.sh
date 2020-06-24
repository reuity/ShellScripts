#!/bin/bash
set -e -u
# 0 下载源码包
mkdir -p /data/xjk/software/pgsql
cd /data/xjk/software/pgsql

# 1 安装依赖包
yum install -y cmake gcc-c++ openssl-devel perl-ExtUtils-Embed readline-devel zlib-devel pam-devel libxml2-devel libxslt-devel openldap-devel python python-devel


# 2 解压源码包
cd /data/xjk/software/pgsql 
tar -zxf postgresql-10.4.tar.gz

cd postgresql-10.4
./configure --prefix=/usr/local/pgsql --with-perl --with-python --with-openssl
make -j `nproc`
make install

# 3 创建PG用户和目录
groupadd postgres
useradd -g postgres postgres
chown -R postgres.postgres /usr/local/pgsql
mkdir -p /data/postgres
chown postgres.postgres /data/postgres

# 4 设置PG环境变量
echo "export PGHOME=/usr/local/pgsql" >> /home/postgres/.bash_profile
echo "export PGDATA=/data/postgres" >> /home/postgres/.bash_profile
echo "export PATH=$PATH:/usr/local/pgsql/bin" >> /home/postgres/.bash_profile
echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/pgsql/lib" >> /home/postgres/.bash_profile

# 5 安装使用工具插件
cd /data/xjk/software/pgsql/postgresql-10.4/contrib
make -j `nproc`
make install

# 6 初始化PG数据库
su - postgres -c '/usr/local/pgsql/bin/initdb -D /data/postgres -E UTF8 --local=en_US.utf8'
mkdir -p /data/postgres/archived_log /data/postgres/pg_log
chown postgres.postgres /data/postgres/archived_log /data/postgres/pg_log

# 7 修改PG参数配置（用附件postgresql.conf替换,port,shared_buffers等根据实际情况修改）
cd /data/postgres
\cp -rp /data/xjk/software/postgresql10.4.conf ./postgresql.conf
chown postgres.postgres postgresql.conf

# 8 启动PG
su - postgres -c '/usr/local/pgsql/bin/pg_ctl -D /data/postgres -l logfile start'

# 9 连接测试
# psql
# postgres=#
# \l
# show wal_level;
# show max_connectionsl;
# CREATE EXTENSION pg_stat_statements;
# SELECT query,calls,total_time,(total_time/calls) as average,rows,100.0 * shared_blks_hit /nullif(shared_blks_hit + shared_blks_read,0) AS hit_percent FROM pg_stat_statements ORDER BY average DESC LIMIT 5;

# 删除PG安装
# userdel postgres
# rm -rf /home/postgres
# rm -rf /var/spool/mail/postgres
# rm -rf /data/postgres
# rm -rf /usr/local/pgsql