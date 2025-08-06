#!/bin/bash



# this function initializes the client deployment scripts
# this function accepts 1 parameter: the full script path name that was executed
# Usage:
#   initialize_deployment_script "$0"
function initialize_deployment_script
{

	# retrieve the current script name that was originally invoked
	get_script_name_from_path "$1"

	# create the client logfile
	create_logfile $CURRENT_SCRIPT_NAME

}



# function that initializes the ENV_NAME variable for use in the script.
# this function accepts an optional parameter: the environment name (dev, test, prod) 
# Usage: 
#   set_env_var "$1"
#   or with no arguments to trigger prompts:
#   set_env_var

function set_env_var ()
{
  local passed_env_name="$1"

#	echo "running set_env_and_user_vars($1, $2)"

  # Set ENV_NAME from argument or prompt the user
  if [[ -n "$passed_env_name" ]]; then
    ENV_NAME="$passed_env_name"
  else

	# prompt the user for an environment value
	read -rp "Enter environment (dev, test, prod): " ENV_NAME < /dev/tty

# 	echo "The value of ENV_NAME is: $ENV_NAME"

  fi

  # Validate that ENV_NAME is one of the accepted values
  case "$ENV_NAME" in
    dev|test|prod) ;;
    *)
      echo "ERROR: Invalid environment name '$ENV_NAME'. Must be one of: dev, test, prod."
      exit 1
      ;;
  esac


}


# function that creates a logfile and populates it with all output from the script
# this function accepts one parameter, the logfile prefix
# Usage:
#   create_logfile "$1"
function create_logfile ()
{
	# store the log file prefix in a local variable
	local passed_logfile_prefix="$1"

	# create the logfile with a date/time suffix
	LOGFILE="../../deployment_script_logs/$passed_logfile_prefix.$(date +%Y%m%d_%H%M%S).log"
	exec > >(tee -a "$LOGFILE") 2>&1
}


# =====================================================================
#      CROSS-PLATFORM SMART SSH FUNCTION (Windows, macOS, Linux)
# =====================================================================
# This function intelligently adapts its behavior based on the OS.
# On Windows/Git Bash, it uses the stable native client and winpty.
# On macOS/Linux, it uses the standard, reliable system ssh.
# =====================================================================
ssh() {
  # Detect the operating system kernel name
  case "$(uname -s)" in

    # --- Case 1: Windows (Git Bash) ---
    MINGW*)
      # This is the special logic we developed for Windows
      local ssh_executable="/c/Windows/System32/OpenSSH/ssh.exe"
      if [ "$#" -eq 1 ]; then
        # Interactive session -> use winpty for terminal compatibility
        winpty "$ssh_executable" "$@"
      else
        # Non-interactive command -> call ssh.exe directly to avoid bugs
        "$ssh_executable" "$@"
      fi
      ;;

    # --- Case 2: macOS, Linux, or any other Unix-like system ---
    *)
      # On macOS and Linux, the standard 'ssh' command works perfectly
      # for both interactive and non-interactive use. No special
      # handling is needed.

      # The 'command' builtin bypasses this function, preventing an
      # infinite loop and calling the real /usr/bin/ssh.
      command ssh "$@"
      ;;
  esac
}
# --- End of Smart SSH Function ---


# function to execute a remote command/script using ssh
# The function accepts one parameter: the command to be executed
# Usage:
# exec_remote_cmd "$1"
function exec_remote_cmd ()
{
	# store the command parameter in a local variable
	local passed_cmd="$1"

	echo "running exec_remote_cmd ($1)"

	echo "ssh $DOCKER_HOSTNAME $passed_cmd"
	
	# execute the command via ssh
	ssh "$DOCKER_HOSTNAME" "$passed_cmd"

}


# function to execute a remote command/script using ssh and pass values in via STDIN
# The function accepts two parameters: the STDIN value and the command to be executed
# Usage:
# exec_remote_cmd_with_stdin "$1" "$2"
function exec_remote_cmd_with_stdin ()
{
	# store the command parameter in a local variable
	local passed_stdin_content="$1"
	local passed_cmd="$2"

	echo "running exec_remote_cmd ($2)"

# echo "ssh $DOCKER_USERNAME@$DOCKER_HOSTNAME $passed_cmd"
	# execute the command via ssh
	echo "$passed_stdin_content" | ssh "$DOCKER_HOSTNAME" "$passed_cmd"

}



