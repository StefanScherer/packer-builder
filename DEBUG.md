# Debugging packer builds

## hyperv

Fetch the IP address of the Azure VM. Then adjust the login password
trough SSH.

```
ssh packer@1.2.3.4 net user packer TheNewPassword
```

Now you can RDP into the machine with user packer and TheNewPassword
and open the Hyper-V Manager and connect to the Hyper-V VM.
