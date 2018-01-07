#!/bin/bash
cd ./source
git add .
git stash
git pull origin master
cd ..
hexo clean
hexo g
hexo d