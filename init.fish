# ssh-agent initialization hook
#
# You can use the following variables in this file:
# * $package       package name
# * $path          package path
# * $dependencies  package dependencies

set -g ssh_environment $HOME/.ssh/environment.csh

function _iadf_start_ssh_agent
    echo-info --major "Initialising ssh-agent..."

    /usr/bin/ssh-agent -c | sed 's/^echo/#echo/' > $ssh_environment
    chmod 600 $ssh_environment
    . $ssh_environment > /dev/null

    set key_set $HOME/.ssh/keys/services/**.id_rsa

    echo-info --minor "Adding keys..."
    for key in $key_set
        /usr/bin/ssh-add $key
    end
end

which ssh-agent > /dev/null ^&1
if test $status -eq 0
  if test -e $ssh_environment
      . $ssh_environment > /dev/null
      if not ps -ef | grep $SSH_AGENT_PID | grep (which ssh-agent) > /dev/null
          echo-info --warning "ssh-agent environment is stale."
          _iadf_start_ssh_agent
      end
  else
      _iadf_start_ssh_agent
  end
else
  echo-info --warning "Not initialising ssh-agent (ssh-agent not found in path)."
end