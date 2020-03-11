---
layout: post  
title: Debugging JekyII with Github Pages build errors
tags: jekyII github debug ruby
---

### Intro  
Mission: Debug failed github-pages site build (powered by JekyII).  

### Overview  
Some times ago my site stopped updating process. I looked in my default github CI and found that JekyII couldnt build site. All what I got - message "Page build failed." :)  
So I thought that where should be some way to debug this problem!    

### Preparation
We need to install several ruby gems and stuff. I used my Ubuntu 18 VM for that purpose.  
Disclaimer! It's very important to use the same versions of all gems that github itself uses. For reference use this page - https://pages.github.com/versions/.
I used this versions on some gems:  
- jekyll-3.8.5;
- public_suffix-3.0;
- github-pages-204;

Install apt packages and ruby gems.  
``apt-get install ruby-full build-essential zlib1g-dev -y
gem install jekyll -v 3.8.5 bundler``  
Create new temporary dir and initialize jekyII project.  
``jekyll new temp``  
Now copy your site from github  
``git clone github.com/myrepo``  
Move Gemfiles from temp directory to your project's dir  
``mv temp/Gemfile* myrepo/``  
Update in Gemfile line with JekyII  
vim myrepo/Gemfile
``#gem "jekyll", "~> 3.8.5"
gem "github-pages", "~> 204", group: :jekyll_plugins #insert that line``  
Now run your site  
``bundle exec jekyll serve``  
You can encounter some errors due to different gem's versions in Gemfile/Gemfile.lock, etc.. Resolve them locally (i.e. update Gemfile/lock, install required versions according to github-pages dep version page).  
After that I got my error printed, nice and clear  
``  Liquid Exception: Liquid error (line 260): wrong number of arguments (given 3, expected 2) in cheats.md``  
And in file cheats.md at line 260+6(header) I had this line:  
``msg: "\{\{ (groups['prometheus'] | map('extract', hostvars, ['custom_fact']) | join(',')).split(',') \}\}"``. Obviously, problem was in double curl braces with jinja syntax which JekyII was interpreted as Liquid syntax.  
So I escaped these bracese, commited code to github and got successful build of my site. 
