#!/bin/bash

# Wbenchvm and server1 must come up in the following order
# in order for all devices to get the proper keys
# Wbenchvm creates a key and this is placed on the vagrant local
# directory and then copied to all other VMs
vagrant up wbenchvm

# server1's root key is copied to all other servers.
vagrant up server1

# bring up all other hosts
vagrant up

