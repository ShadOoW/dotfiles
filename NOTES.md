#### Setting Up UDEV Rules

To create a new udev rule for a device:

1. Find the vendor and product ID:
```bash
lsusb
```
Example output:
```
Bus 002 Device 001: ID 1234:5678 Vendor Name Device Name
```
The format is `ID vendor_id:product_id`

2. Create your udev rule in the `udev` package directory

3. After adding or modifying rules:
```bash
# Reload udev rules
sudo udevadm control --reload-rules

# Trigger the rules
sudo udevadm trigger
```

## SSH Key Setup for GitHub

To generate an SSH key for GitHub authentication:

1. Generate a new SSH key:
```bash
ssh-keygen -t ed25519 -C "shadoow.ma@gmail.com" -f ~/.ssh/id_github
```

2. Start the SSH agent:
```bash
eval "$(ssh-agent -s)"
```

3. Add the key to SSH agent:
```bash
ssh-add ~/.ssh/id_github
```

4. Copy the public key to add to GitHub:
```bash
cat ~/.ssh/id_github.pub
```

5. Add the public key to your GitHub account:
   - Go to GitHub → Settings → SSH and GPG keys
   - Click "New SSH key"
   - Paste your public key and save

6. Test your connection:
```bash
ssh -T git@github.com
```
