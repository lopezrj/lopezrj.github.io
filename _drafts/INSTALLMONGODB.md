---
layout: post
title:  "Install MongoDb"
date:   2022-09-28 21:51:27
categories: mongodb 
tags: [databases]
---
# INSTALL MONGODB

## INSTALL DATABASE in UBUNTU 20.04

```
# 1. Import the public key used by the package management system.
wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -

# Create a list file for MongoDB.
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list

# Reload local package database.
sudo apt-get update

# Install the MongoDB packages.
sudo apt-get install -y mongodb-org

# Optional. To prevent unintended upgrades, you can pin the package at the currently installed version:
echo "mongodb-org hold" | sudo dpkg --set-selections
echo "mongodb-org-server hold" | sudo dpkg --set-selections
echo "mongodb-org-shell hold" | sudo dpkg --set-selections
echo "mongodb-org-mongos hold" | sudo dpkg --set-selections
echo "mongodb-org-tools hold" | sudo dpkg --set-selections

```

### Run MongoDB Community Edition

##### ulimit Considerations
Most Unix-like operating systems limit the system resources that a process may use. These limits may negatively impact MongoDB operation, and should be adjusted. See UNIX ulimit Settings for the recommended settings for your platform.

Starting in MongoDB 4.4, a startup error is generated if the ulimit value for number of open files is under 64000.

##### Directories

If you installed via the package manager, the data directory /var/lib/mongodb and the log directory /var/log/mongodb are created during the installation.

By default, MongoDB runs using the mongodb user account. If you change the user that runs the MongoDB process, you must also modify the permission to the data and log directories to give this user access to these directories.

##### Configuration File

The official MongoDB package includes a configuration file (/etc/mongod.conf). These settings (such as the data directory and log directory specifications) take effect upon startup. That is, if you change the configuration file while the MongoDB instance is running, you must restart the instance for the changes to take effect.

#### Procedure

```
sudo systemctl daemon-reload
sudo systemctl start mongod
sudo systemctl status mongod
sudo systemctl enable mongod
```

#### Begin using MongoDB.

Start a mongo shell on the same host machine as the mongod. You can run the mongo shell without any command-line options to connect to a mongod that is running on your localhost with default port 27017:

```
mongo
```


## SECURITY

Change /etc/mongod.conf, ensure that
authotization is enabled in security section.

```
   security:
     authorization: enabled
```
By default th LOCALHOST EXCEPTION is working in a new cluster. It allows you to access a MongoDB server that enforces authentication but does not yet have a configured user for you to authenticate with.
   * You must run Mongo shell from the same host running the MongoDB server
   * The local host exception closes afeter you create yor first user
   * Always create a user with administrative privileges first.

```
   mongo --host 127.0.0.1:27017
   use admin
   db.createUser({ user : "root", pwd : "root", roles : [ "root" ] })
   exit
```

Connect to server
```
   mongo --host 127.0.0.1:27017 \
   --username root \
   --password root \
   --authenticationDatabase admin
```

Check stats
```
   db.stats()
```

## BUILT IN ROLES

Mongodb uses Role Based Acces Control (RBAC). Database Users are granted roles, that can be built-in roles or customs roles.

### Roles Structure

A role is composed of a set of privileges that allows to perform actions on resources.

Resources in Mongodb are: Database, Collection, Set of Collecionts, Cluster, Replica Set and Shard Cluster.

```
// specific database and collecion
{ db: "products", collection: "inventory" }

// all databases and all collections
{ db: "", collection: "" }

// any database and specific collection
{ db: "", collection: "accounts" }

// specific database any collection
{ db: "products", collection: "" }

// or cluster resource
{ cluster: true }
```

A role cn inherit from other role.

Roles can have Network Authentication Restrictions: clientSource or serverAddess


### Built-In Roles

There are five sets:
* Database User
  - read
  - readWrite 
* Database Administrator
  - dbAdmin
  - userAdmin
  - dbOwner
* Cluster Administrator
  - clusterAdmin
  - clusterManager
  - clusterMonitor
  - hostManager
* Backup/Restore
  - backup
  - restore
* Super User
  - root

There are Built-In Roles for All Databases Level
* Database User
  - readAnyDatabase
  - readWriteAnyDatabase
* Database Administration
  - dbAdminAnyDatabase
  - userAdminAnyDatabase
* Super User
  - root


## Create a security officer

Create a security officer in charge of manage users of instance. This is the first user to be created.
The role 'userAdmin' is able to execute these commands: changeCustomData, changePassword, createRole, createUser, dropRole,
dropUser, grantRole, revokeRole, setAuthenticationRestriction, viewRole, viewUser

But it is not able to change or access data in other databases.

```
mongo --host 127.0.0.1:27017 -u root -p root
db.createUser(
    { user: 'security_officer',
      pwd: 'h3ll0th3r3',
      roles: [ { db: 'admin', role: 'userAdmin' } ]
    }
)
```

Now create a user that is able to administer the database. We use the role 'dbAdmin' which is able to execute, among others, these commands:
collStats, dbHash, dbStats, killCursors, listIndexes, listCollections, bypassDocumentValidation, collMod, collStats, convertToCapped

```
mongo --host 127.0.0.1:27017 -u root -p root
use admin
db.createUser(
    { user: 'dba',
      pwd: 'c1lynd3rs',
      roles: [ { db: 'm103', role: 'dbAdmin' } ]
    }
)
```

#### dbOwner

The database owner can perform any administrative action on the database.
This role combines the privileges granted by the readWrite, dbAdmin and userAdmin roles.

```
mongo --host 127.0.0.1:27017 -u root -p root
use admin
db.grantRolesToUser('dba', [ { db: 'playground', role: 'dbOwner' }])
```

```
db.runCommand({rolesInfo: { role: 'dbOwner', db: 'playground'}, showPrivileges: true})

```

# TOOLS FOR MONGODB

The tools installed at `/usr/bin/` with mongodb are:

* mongostat
* mongodump (export BJSON files)
* mongorestore (import BJSON files)
* mongoexport (export json files)
* mongoimport (import json files)





