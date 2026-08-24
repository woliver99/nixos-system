# Update specific module
```
sudo git submodule update --remote --merge pkgs/nixvim
```

# NixOS Hardware merge all branches to master
```
git checkout master
git reset --hard upstream/master

git merge msi-gl65
git merge dell-latitude-3310
git merge intel-rocket-lake
```

## Don't forget to push changes:
```
git push origin master --force-with-lease
```
