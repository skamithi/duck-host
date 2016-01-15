Bring up wbenchvm because ssh keys are installed on all
of devices in the env
```
vagrant up wbenchvm
```

Bring up server1 because we need its ssh key to install on server2
```
vagrant up server1
```

Bring up everything else
```
vagrant up
```
