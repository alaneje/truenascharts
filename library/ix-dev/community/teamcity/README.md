# TeamCity

[TeamCity](https://www.jetbrains.com/teamcity/). TeamCity is a continuous integration and continuous deployment server by JetBrains.

> When application is installed and on each startup, a container will be launched with **root** privileges.
> This is required in order to apply the correct permissions to the `TeamCity` directories.
> Afterward, the `TeamCity` container will run as a **non**-root user (`1000`).
> All mounted storage(s) will be `chown`ed only if the parent directory does not match the user and group (`1000`).
