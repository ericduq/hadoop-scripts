#!/usr/bin/.bashrc

# The following script setups up Hadoop 2.2.0 and Pig 0.12.0 on a single node.
# NOTES: The resources of the node should be of sufficient performance. For example, if implementation is on AWs, Hadoop will not realiably operate on the smallest instance. 

cd ~ 
sudo apt-get update

#### HADOOP INSTALLATION ###

# Download java jdk
sudo apt-get install openjdk-7-jdk
cd /usr/lib/jvm
sudo ln -s java-7-openjdk-amd64 jdk

# Uncommment to install ssh 
sudo apt-get install openssh-server

# Add hadoop user
sudo addgroup hadoop
sudo adduser --ingroup hadoop hduser
sudo adduser hduser sudo

# Generate keys
sudo -u hduser ssh-keygen -t rsa -P ''
sudo sh -c 'cat /home/hduser/.ssh/id_rsa.pub >> /home/hduser/.ssh/authorized_keys'
#ssh localhost

# Install Hadoop and set permissons
cd ~
if [ ! -f hadoop-2.2.0.tar.gz ]; then
	wget http://www.trieuvan.com/apache/hadoop/common/hadoop-2.2.0/hadoop-2.2.0.tar.gz
fi
sudo tar vxzf hadoop-2.2.0.tar.gz -C /usr/local
cd /usr/local
sudo mv hadoop-2.2.0 hadoop
sudo chown -R hduser:hadoop hadoop

# Hadoop variableis
sudo sh -c 'echo export JAVA_HOME=/usr/lib/jvm/jdk/ >> /home/hduser/.bashrc'
sudo sh -c 'echo export HADOOP_INSTALL=/usr/local/hadoop >> /home/hduser/.bashrc'
sudo sh -c 'echo export PATH=\$PATH:\$HADOOP_INSTALL/bin >> /home/hduser/.bashrc'
sudo sh -c 'echo export PATH=\$PATH:\$HADOOP_INSTALL/sbin >> /home/hduser/.bashrc'
sudo sh -c 'echo export HADOOP_MAPRED_HOME=\$HADOOP_INSTALL >> /home/hduser/.bashrc'
sudo sh -c 'echo export HADOOP_COMMON_HOME=\$HADOOP_INSTALL >> /home/hduser/.bashrc'
sudo sh -c 'echo export HADOOP_HDFS_HOME=\$HADOOP_INSTALL >> /home/hduser/.bashrc'
sudo sh -c 'echo export YARN_HOME=\$HADOOP_INSTALL >> /home/hduser/.bashrc'

# Modify JAVA_HOME 
cd /usr/local/hadoop/etc/hadoop
sudo -u hduser sed -i.bak s=\${JAVA_HOME}=/usr/lib/jvm/jdk/=g hadoop-env.sh
pwd

# Check that Hadoop is installed
/usr/local/hadoop/bin/hadoop version

# Edit configuration files
sudo -u hduser sed -i.bak 's=<configuration>=<configuration>\<property>\<name>fs\.default\.name\</name>\<value>hdfs://localhost:9000\</value>\</property>=g' core-site.xml 
sudo -u hduser sed -i.bak 's=<configuration>=<configuration>\<property>\<name>yarn\.nodemanager\.aux-services</name>\<value>mapreduce_shuffle</value>\</property>\<property>\<name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>\<value>org\.apache\.hadoop\.mapred\.ShuffleHandler</value>\</property>=g' yarn-site.xml
  
sudo -u hduser cp mapred-site.xml.template mapred-site.xml
sudo -u hduser sed -i.bak 's=<configuration>=<configuration>\<property>\<name>mapreduce\.framework\.name</name>\<value>yarn</value>\</property>=g' mapred-site.xml
 
cd ~
sudo mkdir -p mydata/hdfs/namenode
sudo mkdir -p mydata/hdfs/datanode

cd /usr/local/hadoop/etc/hadoop
sudo -u hduser sed -i.bak 's=<configuration>=<configuration>\<property>\<name>dfs\.replication</name>\<value>1\</value>\</property>\<property>\<name>dfs\.namenode\.name\.dir</name>\<value>file:/home/hduser/mydata/hdfs/namenode</value>\</property>\<property>\<name>dfs\.datanode\.data\.dir</name>\<value>file:/home/hduser/mydata/hdfs/datanode</value>\</property>=g' hdfs-site.xml


#### PIG INSTALLATION ####

# Prepare for Pig installation
cd ~
sudo apt-get install ant
sudo apt-get install junit
sudo apt-get install subversion
if [ ! -f pig-0.12.0.tar.gz ]; then
        wget http://download.nextag.com/apache/pig/pig-0.12.0/pig-0.12.0.tar.gz 
        #svn co http://svn.apache.org/repos/asf/pig/trunk   #Using svn would alternatively download pig-0.13.0.SNAPSHOT
fi
sudo tar vxzf pig-0.12.0.tar.gz -C /usr/local
sudo mv pig-0.12.0 pig
sudo chown -R hduser:hadoop pig

# Recomplie Pig 0.12.0 for Hadoop 2.2.0
cd /usr/local/pig
ant clean jar-withouthadoop -Dhadoopversion23

# Set paths
sudo sh -c 'export PIG_HOME=/usr/local/pig >> /home/hduser/.bashrc'
sudo sh -c 'export PATH=\$PATH:\$PIG_HOME/bin >> /home/hduser/.bashrc'
sudo sh -c 'export PIG_CLASSPATH=\$HADOOP_INSTALL/conf >> /home/hduser/.bashrc'

# Check pig version
\usr\local\pig\bin\pig --version


### Testing Hadoop and Pig

## Run the following commands as hduser to start and test hadoop
#sudo su hduser
# Format Namenode
#hdfs namenode -format
# Start Hadoop Service
#start-dfs.sh
#start-yarn.sh
# Check status
#hduser jps
# Example
#cd /usr/local/hadoop
#hadoop jar ./share/hadoop/mapreduce/hadoop-mapreduce-examples-2.2.0.jar pi 2 5

## Run the following commands as hduser to start and test pig (see http://pig/apache.org/docs/r0.12.0/start.html)
#sudo su hduser
#cp /etc/passwd ~/passwd 
#hdfs dfs -copyFromLocal passwd 
#pig
# Within pig
#A = load 'passwd' using PigStorage(':'); 
#B = foreach A generate $0 as id;
#dump B;
