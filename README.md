[![Open Source Helpers](https://www.codetriage.com/devsecopsbr/kubernetes/badges/users.svg)](https://www.codetriage.com/devsecopsbr/kubernetes)

# Welcome to Kubernetes space

This goal of this project is to contribute, help, guide and support everyone working with Kubernetes. </br>
You are very welcome to starting contributing and share ideas.</br>
Languages: English & Portuguese

## Resources

Below list shows the resources you will find freely to use in your private projects under MPL license. More resources are comming soon!

* pre-commit hooks

## Key features

...

## Enabling hooks

Creates a `.pre-commit-config.yaml` in your root folder if does't exist with below content.

```(text)
  - repo: https://github.com/DevSecOpsBr/kubernetes
    rev: v1.0.1
    hooks:
      - id: pluto_detect_files
        args: [ <charts-folder> ]
```

Install the hook as described below.

```(shell)
pre-commit install
pre-commit autoupdate
```
