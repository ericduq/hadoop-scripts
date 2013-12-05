# hadoop-scripts

## make-single-node.sh 

Creates a single-node Hadoop 2.2.0 server. 

Requirements: Suitable for Ubuntu-based distributions because of the need for the APT utility (e.g., apt-get).

Testing: Tested and executed on an ubuntu-precise-12.04-amd64-server-20131114 AMI (ami-d9a98cb0).

(Command seqeuence adopted from http://codesfusion.blogspot.com/2013/10/setup-hadoop-2x-220-on-ubuntu.html)

## make-single-node-withpig.sh 

Same as make-single-node.sh but also recomplies in Pig 0.12.0 to work with Hadoop 2.2.0.

Testing: Script is untested but should work.
