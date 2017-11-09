---
layout: post
title: Jenkins pipeline jobs integration with bitbucket
tags: jenkins bitbucket scm cicd
---
### Jenkins jobs integration with bitbucket SCM  

In this article I provide some workarounds for bitbucket-jenkins integration.    
In my work I faced some problems with configuration since I have got only ssh key
which was mapped on project, not user/pass service login, so i couldn't configure some jenins plugins for pipeline job, saddly. Also, bitbucket plugin could not be configured in jenkins pipeline jobs to watch SCM changes, so I had need some workaround for trigger build which I'll show here.  

### Components:
- Jenkins 2.60.3 (login with admin rights)  
- Bitbucket without full admin access  
- Project in Bitbucket with developer rights  

### Bitbucket Configuration  
1. Login in Bitbucket, go to your project  
2. Click on Settings -> Hooks
3. Find hook 'Bitbucket server webhook to Jenkins' in marketplace, request installation from admin  
4. Configure hook:  
- jenins url (should be resolvable from scm)
- skip ssl verification (if you have a self-signed certificate)  
- repo clone - ssh or http  

### Jenkins Configuration  
1. Login in Jenkins, go to Manage Jenkins - plugins  
2. Install these plugins:  
- Bitbucket branches  
- Bitbucket pipeline for BlueOcean  
- Scm-api plugin  
3. Go to Manage Jenkins - System configuration  
4. In Bitbucket endpoint section choose Manage Hooks - add credentials
5. Paste your ssh key, fill in Description and name  
6. Click Add  
Although you will not see created credentials in this drop-down menu you can find them in Manage Jenkins - Credentials menu  

### Jenkins Trigger job    
1. Create freestyle job with name 'Trigger' or something like that  
2. Choose Git in Source Code Manage section  
3. Fill in  
- repository URL (ssh://git@scm.company.com:7999/...)  
- credentials from previous 'Jenkins Configuration' section of tutorial  
- Branches to build - i use \*/master  
4. Choose these options  
- Build when a change is pushed to BitBucket  
- Polling for SCM changes ( * * * * *  - every minute)  
5. Click Save  

### Jenkins pipeline job  
1. Create pipeline job  
2. Configure it  
3. In Build Trigger section choose _Build after other projects are built_, specify _Trigger_ job  
4. Click save  

That's it! Now you have simple cicd pipeline between bitbucket and Jenkins pipeline job. However, it is far from ideal - You cannot notify scm about build and stage status and Jenkins is creating some overhead with SCM polling. So if you want some real cool CICD you should have full access to Bitbucket with service account (logit with pass, not ssh-rsa) and Jenkins. And all is going to be supadupa. Cheers!
