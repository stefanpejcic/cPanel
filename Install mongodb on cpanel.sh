#!/bin/bash
#
# Example MongoDB Install on CentOS 7 / cPanel
#
# This code is for informational purposes and not maintained or warrantied for any specific use
#
# (c) 2021 MongoDB Inc
# author: ryan.quinn@mongodb.com

# Create entry for MongoDB repository
cat > /etc/yum.repos.d/mongodb-org-4.4.repo <<- EOM
[mongodb-org-4.4]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/7/mongodb-org/4.4/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-4.4.asc
EOM

# Install MongoDB packages
sudo yum install -y mongodb-org;

# Configure SELinux (only needed if running SELinux in enforcing mode)
sudo yum install checkpolicy;
cat > mongodb_cgroup_memory.te <<EOF
module mongodb_cgroup_memory 1.0;

require {
    type cgroup_t;
    type mongod_t;
    class dir search;
    class file { getattr open read };
}

#============= mongod_t ==============
allow mongod_t cgroup_t:dir search;
allow mongod_t cgroup_t:file { getattr open read };
EOF

checkmodule -M -m -o mongodb_cgroup_memory.mod mongodb_cgroup_memory.te;
semodule_package -o mongodb_cgroup_memory.pp -m 
mongodb_cgroup_memory.mod;
sudo semodule -i mongodb_cgroup_memory.pp;

cat > mongodb_proc_net.te <<EOF
module mongodb_proc_net 1.0;

require {
    type proc_net_t;
    type mongod_t;
    class file { open read };
}

#============= mongod_t ==============
allow mongod_t proc_net_t:file { open read };
EOF

checkmodule -M -m -o mongodb_proc_net.mod mongodb_proc_net.te
semodule_package -o mongodb_proc_net.pp -m mongodb_proc_net.mod
sudo semodule -i mongodb_proc_net.pp

# Start the MongoDB Service
sudo systemctl daemon-reload;
sudo systemctl start mongod;

# Check MongoDB status
sudo systemctl status mongod;

# Enable MongoDB to automatically start on boot (optional)
sudo systemctl enable mongod;

cat << EOF
------------------------------------------------------
This script has completed.
Please check the output for any critical
errors and ensure that the MongoDB service is running.
------------------------------------------------------
EO
