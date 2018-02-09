---
layout: post
title: Mongo Basics
tags: mongo db
---
### Basic mongo commands and checks  

#### Begining  

``mongo  
db  or showdbs #show all dbs  
use test #use or create new DB  
db.test.find("something") #find in db test something  
show collections #show collections  
db.createCollection("testCollection") #Create Collections  
rs.slaveOk() #give permission on slave queries - only for current connection
``
