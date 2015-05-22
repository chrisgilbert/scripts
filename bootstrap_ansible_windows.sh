#!/bin/bash
#
# v2 Chris Gilbert - 22/05/2015
# Bootstrap ansible on Windows/Babun Shell
#
echo Setting up ansible pre-requisties on windows..

pact install python python-paramiko python-crypto python-setuptools openssl libsasl2_3 gettext ca-certificates
/usr/bin/easy_install-2.7 pip
/usr/bin/pip install --upgrade pyyaml jinja2 requests

echo Installing ansible from src..

git clone https://github.com/ansible/ansible /opt/ansible
cd /opt/ansible
# Switch to latest stable version at time of writing - list versions with 'git tag' command
git checkout v1.9.1-1
# Checkout submodules
git submodule update --init --recursive


echo """
source /opt/ansible/hacking/env-setup >/dev/null 2>&1
export ANSIBLE_LIBRARY=\$ANSIBLE_HOME/library
# This setting is to tweak SSH on Cygwin - will be a bit slower, but will work!
export ANSIBLE_SSH_ARGS=\"-o ControlMaster=no\"
export ANSIBLE_REMOTE_USER=root
export TERM=cygwin
""" | tee -a ~/.bash_profile ~/.zsh_profile

mkdir ~/.ssh
mkdir /etc/ansible
echo """
[training]
ansible-training
""" >> /etc/ansible/hosts


cat <<EOF > ~/.ssh_wrapper
#!/bin/bash
SSH_ENV="$HOME/.ssh/environment"

function start_agent {
    echo "Initialising new SSH agent..."
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "\${SSH_ENV}"
    echo succeeded
    chmod 600 "\${SSH_ENV}"
    . "\${SSH_ENV}" > /dev/null
    /usr/bin/ssh-add;
}

# Source SSH settings, if applicable

if [ -f "\${SSH_ENV}" ]; then
    . "\${SSH_ENV}" > /dev/null
    #ps \${SSH_AGENT_PID} doesn't work under cywgin
    ps -ef | grep \${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
        start_agent;
    }
else
    start_agent;
fi
EOF


echo You can use ~/.ssh_wrapper in your .bash_profile or .zsh_profile to automatically unlock your private SSH key on opening Babun.

chmod 755 ~/.zsh_profile ~/.ssh_wrapper
. ~/.zsh_profile

