NixOS Version 26.05

# Update

```
sudo bash ./nixos-system/scripts/update.sh
```

If you are on a version before the update script run this command before running the update script to apply all the migrations:

```
echo "0" | sudo tee nixos-system.version > /dev/null
```

# Setup

```
cd /etc/nixos/ && curl -sSL https://raw.githubusercontent.com/woliver99/nixos-system/refs/heads/master/scripts/setup.sh | sudo bash
```

# NixOS Minimal Install Script

```
curl -sL https://raw.githubusercontent.com/woliver99/nixos-system/refs/heads/master/scripts/install.sh -o /tmp/install.sh && sudo bash /tmp/install.sh && rm /tmp/install.sh
```
