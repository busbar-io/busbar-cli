# busbar-cli

This is a Command Line Interface for the Busbar APIs.

## Installation (Recomended)

* The Busbar CLI tool should be installed through gem as show bellow:
  ```sh
  gem install busbar-cli
  ```

## Setup (chose one of the methods bellow)

* With a pre-existent Busbar CLI configuration file:
  ```sh
  busbar -f /path/to/configuration/file
  ```

* Passing interactivelly the needed configuration keys:
  ```sh
  busbar -a
  ```

## Uninstall
* For installations done through Ruby's gem:
  ```sh
  gem uninstall busbar-cli
  ```
  ```sh
  rm /usr/local/bin/busbar
  rm $HOME/.busbar/config
  rm $HOME/.busbar/kubectl-*
  ```

## Usage

```
  busbar --version                                            # Show Busbar's CLI version
  busbar app-config                                           # Local application CLI configuration.
  busbar apps                                                 # List the applications
  busbar busbar-setup                                         # Create the Busbar config file
  busbar clone APP ENV ENV_CLONE_NAME                         # Clone an environment
  busbar console APP ENV                                      # Run a fresh console in the context of an application
  busbar containers APP ENV                                   # List the containers of an application
  busbar copy SOURCE_FILE DESTINATION_FILE                    # Copy files and directories to and from containers
  busbar create APP [ENV]                                     # Create an application or an environment
  busbar create-db NAME TYPE ENV                              # Create a database
  busbar databases                                            # List databases available
  busbar deploy APP ENV [BRANCH]                              # Deploy an environment
  busbar destroy APP [ENV]                                    # Destroy an application or an environment and all of their resources
  busbar destroy-db DB-NAME                                   # Destroy a database
  busbar environments APP                                     # List the environments of an application
  busbar fetch-build-logs APP ENV                             # Get the logs from the latest build
  busbar get APP ENV SETTING                                  # Get the value of an environment variable of a given environment
  busbar help [COMMAND]                                       # Describe available commands or one specific command
  busbar kubeconfig-update                                    # Update kubectl configuration file
  busbar latest_build APP ENV                                 # Get information from the environment's latest build
  busbar logs APP_OR_CONTAINER ENV [COMPONENT_TYPE]           # Fetch the logs from a component or container
  busbar profile [PROFILE]                                    # Set the Busbar profile. With no arguments get current profile
  busbar profiles                                             # Show the available profiles
  busbar publish APP ENV                                      # Publish an environment
  busbar resize APP ENV [COMPONENT_TYPE] NODE_TYPE            # Change the current node type of an environment or a component
  busbar run COMMAND POD                                      # Run commands in a container.
  busbar scale APP ENV COMPONENT_TYPE SCALE                   # Scale a component
  busbar set APP ENV SETTING=VALUE OTHER_SETTING=VALUE [...]  # Set one or more environment variables at once. Use --no-deploy or --deploy=false to not deploy immediately
  busbar settings APP ENV                                     # List the settings of an environment
  busbar show APP [ENV]                                       # Show details of an application or an environment
  busbar show-db NAME                                         # Show details of a database
  busbar ssh CONTAINER ENV                                    # Run a console in a container
  busbar unset APP ENV SETTING                                # Delete an environment variable
  busbar url APP ENV                                          # Get the URL of an environment
  busbar version APP ENV                                      # Show an environment's version
  busbar wtf CONTAINER ENV                                    # Fetch the logs from a container failing to initialize (Error or CrashLoopBackOff)
```

## Profiles

Busbar can work with multiple Kubernetes clusters. In busbar we refer to them as profiles.

In order to switch between profiles, you must use the command: `busbar profile PROFILE_ID`

The profiles available can be listed by running the command: `busbar profiles`.

