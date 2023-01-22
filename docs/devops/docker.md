Docker is a set of platform as a service (PaaS) products that use OS-level virtualization to deliver software in
packages called `containers`. Containers are isolated from one another and bundle their software, libraries, and
configuration files; they can communicate with each other through well-defined channels. Because all of the
containers share the services of a single OS kernel, they use fewer resources that virtual machines.

## Docker compose

Work with multiple docker images and `.Dockerfile` files.

# Cheatsheet

See below some of the commands that I've been using. Official
[docs](https://docs.docker.com/engine/reference/commandline/cli/) also have extensive material on cli usage.

* `docker build .` build image from a Dockerfile that is located in your current directory.
* `docker volume ls` list all volumes
* `docker exec -it <MyContainer> bash` runs an interactive (`-it` flag) shell session in a running container.

Docker compose:

* `docker compose ps` list all containers, including their Service name (which you can pass to other docker compose
  commands in order to interact with a the container.).
* `docker compose up` create and start the containers.
* `docker compose exec` executes a command in a running container.
* `docker compose exec -i <Container Service Name> bash` executes an interactive (`-i` flag) bash shell in the
  container associated with the Service name you passed in the exec command.
* `docker compose logs` view output from containers.
