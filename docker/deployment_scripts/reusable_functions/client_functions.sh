#!/bin/bash

#-----------------------------------------------------------------------------
# client_functions.sh:
# this file defines reusable client functions that are used for docker 
# deployments (intended for remote docker hosts)
#-----------------------------------------------------------------------------


# this function initializes the client deployment scripts by saving the script file name to $CURRENT_SCRIPT_NAME and creating a log file for the given script execution
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


# this generic function gets, validates, and sets a global variable.
#
# Arguments:
#   $1: var_name           (The string name of the global variable to set, e.g., "ENV_NAME")
#   $2: prompt_text        (The text to show the user if prompting)
#   $3: validation_regex   (A regex pattern for valid values, e.g., "dev|test|prod")
#   $4: error_list         (A human-readable list for the error message, e.g., "dev, test, prod")
#   $5: passed_value       (The optional value passed from the caller, e.g., "$1")
#
# Returns: nonzero on usage error or internal failure
# Usage: set_validated_var "ENV_NAME" "Enter environment (dev, test, prod)" "dev|test|prod" "dev, test, prod" "$1"
function set_validated_var () {
    local var_name="$1"
    local prompt_text="$2"
    local validation_regex="$3"
    local error_list="$4"
    local passed_value="$5"

    local chosen_value=""

    # Set from argument or prompt the user
    if [[ -n "$passed_value" ]]; then
        chosen_value="$passed_value"
    else
        # Prompt the user and read the value
        read -rp "$prompt_text: " chosen_value < /dev/tty
    fi

    # Validate the value
    # We use a regex match (which is what your `case` statement was doing)
    if [[ "$chosen_value" =~ ^($validation_regex)$ ]]; then
        # Set the global variable
        # "declare -g" assigns a variable in the global scope
        declare -g "$var_name"="$chosen_value"
    else
        # Show an error and exit
        # Sending errors to stderr (>&2) is good practice
        echo "ERROR: Invalid value '$chosen_value' for $var_name." >&2
        echo "       Must be one of: $error_list." >&2
        exit 1
    fi
}

# this function initializes the ENV_NAME variable for use in the script.
# this function accepts an optional parameter: the environment name (dev, test, prod) 
# Usage: 
#   set_env_var "$1"
#   or with no arguments to trigger prompts:
#   set_env_var
function set_env_var () {
    # Calls the helper with its specific parameters
    set_validated_var \
        "ENV_NAME" \
        "Enter environment (dev, test, prod)" \
        "dev|test|prod" \
        "dev, test, prod" \
        "$1"
}

# this function initializes the REBUILD_IMAGE variable for use in the script.
# this function accepts an optional parameter: a flag to indicate if the docker image should be rebuilt (yes) or not (no) 
# Usage: 
#   set_rebuild_var "$1"
#   or with no arguments to trigger prompts:
#   set_rebuild_var
function set_rebuild_var () {
    # Calls the helper with its specific parameters
    set_validated_var \
        "REBUILD_IMAGE" \
        "Rebuild image? (yes, no)" \
        "yes|no" \
        "yes or no" \
        "$1"
}

# this function initializes the EXEC_MODE variable for use in the script.
# this function accepts an optional parameter: the environment name (mount, stack) 
# Usage: 
#   set_exec_mode_var "$1"
#   or with no arguments to trigger prompts:
#   set_exec_mode_var
function set_exec_mode_var () {
    # Calls the helper with its specific parameters
    set_validated_var \
        "EXEC_MODE" \
        "Enter execution mode (mount = mounting source code directories, stack = deploying as docker stack with secrets)" \
        "mount|stack" \
        "mount or stack" \
        "$1"
}

# this function creates a logfile and populates it with all output from the script
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


# This cross-platform smart ssh function (Windows, macOS, Linux) function intelligently adapts its behavior based on the OS
# On Windows/Git Bash, it uses the stable native client and winpty.
# On macOS/Linux, it uses the standard, reliable system ssh.
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

# this function executes a remote command/script using ssh
# the function accepts one parameter: the command to be executed
# Usage:
# exec_remote_cmd "$1"
function exec_remote_cmd ()
{
	# store the command parameter in a local variable
	local passed_cmd="$1"
	
	# execute the command via ssh
	ssh "$DOCKER_HOSTNAME" "$passed_cmd"
}

# this function executes a remote command/script using ssh and pass values in via STDIN
# The function accepts two parameters: the STDIN value and the command to be executed
# Usage:
# exec_remote_cmd_with_stdin "$1" "$2"
function exec_remote_cmd_with_stdin ()
{
	# store the command parameter in a local variable
	local passed_stdin_content="$1"
	local passed_cmd="$2"

	# execute the command via ssh
	echo "$passed_stdin_content" | ssh "$DOCKER_HOSTNAME" "$passed_cmd"
}