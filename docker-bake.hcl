variable "image" {
    default = "ghcr.io/heycartlabs/devcontainer"
}

variable "currentPHPVersion" {
    default = "8.2"
}

variable "currentHeyCartVersion" {
    default = "6.6.4.1"
}

target "base-slim" {
    name = "base-slim-${replace(php, ".", "-")}"
    matrix = {
        php = ["8.2", "8.3", "8.4"]
    }
    args = {
        PHP_VERSION = php
    }
    context = "base-slim"
    tags = [ "${image}/base-slim:${php}" ]
    platforms = ["linux/amd64", "linux/arm64"]
}

target "base-full" {
    name = "base-full-${replace(php, ".", "-")}"
    matrix = {
        php = ["8.2", "8.3", "8.4"]
    }
    args = {
        PHP_VERSION = php
    }
    contexts = {
        base = "docker-image://${image}/base-slim:${php}"
    }
    context = "base-full"
    tags = [ "${image}/base-full:${php}" ]
    platforms = ["linux/amd64", "linux/arm64"]
}

target "symfony-flex" {
    args = {
        PHP_VERSION = currentPHPVersion
        SHOPWARE_VERSION = currentHeyCartVersion
    }
    contexts = {
        base = "docker-image://${image}/base-full:${currentPHPVersion}"
        heycart-cli = "docker-image://heycart/heycart-cli:latest-php-${currentPHPVersion}"
    }
    context = "symfony-flex"
    tags = [ "${image}/symfony-flex:${regex("^[0-9]+\\.[0-9]+\\.[0-9]+", currentHeyCartVersion)}-${currentPHPVersion}" ]
    platforms = ["linux/amd64", "linux/arm64"]
}

target "dev" {
    args = {
        PHP_VERSION = currentPHPVersion
        SHOPWARE_VERSION = currentHeyCartVersion
    }
    contexts = {
        base = "docker-image://${image}/base-full:${currentPHPVersion}"
        heycart-cli = "docker-image://heycart/heycart-cli:latest-php-${currentPHPVersion}"
    }
    context = "dev"
    tags = [ "${image}/contribute:${regex("^[0-9]+\\.[0-9]+\\.[0-9]+", currentHeyCartVersion)}-${currentPHPVersion}" ]
    platforms = ["linux/amd64", "linux/arm64"]
}

target "image-proxy" {
    context = "image-proxy"
    tags = [ "${image}/image-proxy" ]
    platforms = ["linux/amd64", "linux/arm64"]
}