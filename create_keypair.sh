#!/bin/bash
#
# Just create a public/private keypair and set permissions
#
ssh-keygen -t rsa
chgrp -R Users ~/.ssh
chmod -R 700 ~/.ssh/
chmod 600 ~/.ssh/id_rsa


