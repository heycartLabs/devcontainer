# Devcontainer Image

> [!NOTE]
> This is an experiment and may be discontinued based on user feedbacks

Devcontainers are a feature of Visual Studio Code that allow you to define a development environment in a container. This allows you to have a consistent development environment across different machines and operating systems. This is adapted also to different other edtitors like PhpStorm.

## Example file for plugin development

```json
{
	"image": "ghcr.io/heycartlabs/devcontainer/symfony-flex:6.6.3-8.3",
	"workspaceMount": "source=${localWorkspaceFolder}/,target=/var/www/html/custom/plugins/FroshTools,type=bind",
	"workspaceFolder": "/var/www/html",
	"overrideCommand": false,
	"portsAttributes": {
		"8000": {
			"label": "HeyCart",
			"onAutoForward": "notify"
		},
		"8080": {
			"label": "Administration Watcher",
			"onAutoForward": "notify"
		}
	},
	"onCreateCommand": "php bin/console plugin:refresh && php bin/console plugin:install --activate FroshTools"
}
```

## Enabling PHP Profiler

By default any PHP Profiler is disabled, you can set the environment variable `PHP_PROFILER` to enable one of them. Supported are:

- Blackfire
- Xdebug
- Tideways
- Pcov

All of them are conflicting each other, therefore it's only possible to enable one of them at once.

Blackfire and Tideways will require a sidecar with the daemon running. Blackfire expects a `blackfire` service in the docker-compose file. Tideways expects a `TIDEWAYS_CONNECTION` environment variable to be set with the connection string to the daemon.

## Support

We will rebuild only Base images only for all supported PHP versions, and for HeyCart versions also only supported ones