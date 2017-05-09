# ssh-agent initialization hook
#
# You can use the following variables in this file:
# * $package       package name
# * $path          package path
# * $dependencies  package dependencies

set -g SSH_ENV $HOME/.ssh/environment

function _iadf_start_ssh_agent
    echo-info --major "Initialising ssh-agent..."

    /usr/bin/ssh-agent -c | sed 's/^echo/#echo/' > $SSH_ENV
    chmod 600 $SSH_ENV
    . $SSH_ENV > /dev/null

    set SSH_KEY_DIR "$HOME/.ssh/keys/services"

    echo-info --minor "Adding keys..."
    for key in $SSH_KEY_DIR/**.id_rsa
        /usr/bin/ssh-add $key
    end
end

if test -e $SSH_ENV
    . $SSH_ENV > /dev/null
    if not ps -ef | grep $SSH_AGENT_PID | grep "ssh-agent\$" > /dev/null
        echo-info --warning "ssh-agent environment is stale."
        _iadf_start_ssh_agent
    end
else
    _iadf_start_ssh_agent
end
