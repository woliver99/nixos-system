# Update repository

```
sudo git submodule update --remote --merge
```

# Setup

1. Go to configuration directory:
```
cd /etc/nixos/
```
2. Create a git repository if not already created (for local changes)
```
sudo git init
```
3. Add this repository as a gitmodule
```
sudo git submodule add https://github.com/woliver99/nixos-system.git nixos-system
```
4. Pull all gitmodules
```
sudo git submodule update --init --recursive
```
