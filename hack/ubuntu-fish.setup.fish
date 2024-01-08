#!/bin/fish

set OMNISOCATCMD $HOME/omni-socat/omni-socat.exe
export SSH_AUTH_SOCK=$HOME/.ssh/agent.sock

function __get_omnisocat
  echo "Get omni-socat.exe"
  curl https://github.com/masahide/OmniSSHAgent/releases/latest/download/omni-socat.zip \
      -sLo omni-socat.zip
  unzip -o omni-socat.zip -d (dirname $OMNISOCATCMD)
  chmod +x $OMNISOCATCMD
  rm omni-socat.zip
end

function __get_socat
  echo "Install socat"
  sudo apt -y install socat
end


function setup_omnisocat
  if not test -f $OMNISOCATCMD
    __get_omnisocat
  end
  if not command -v socat >/dev/null 2>&1
    __get_socat
  end
  
  # Checks wether $SSH_AUTH_SOCK is a socket or not
  ss -a | grep -q $SSH_AUTH_SOCK
  if test -S $SSH_AUTH_SOCK -a $status -eq 0
    return
  end

  # Create directory for the socket, if it is missing
  set SSH_AUTH_SOCK_DIR (dirname $SSH_AUTH_SOCK)
  mkdir -p $SSH_AUTH_SOCK_DIR

  # Applying best-practice permissions if we are creating $HOME/.ssh
  if test "$SSH_AUTH_SOCK_DIR" = "$HOME/.ssh"
      chmod 700 $SSH_AUTH_SOCK_DIR
  end
  
  rm -f $SSH_AUTH_SOCK

  setsid nohup socat UNIX-LISTEN:$SSH_AUTH_SOCK,fork EXEC:"$HOME/omni-socat/omni-socat.exe" >/dev/null 2>&1 & disown
end

setup_omnisocat
