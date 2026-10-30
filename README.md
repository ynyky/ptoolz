# ptoolz
Container with useful devops tools based on python image (`python:3.13-bookworm`).

## What's inside

- **Kubernetes:** kubectl, helm, k9s, kind, eksctl
- **Cloud:** AWS CLI v2 + Session Manager plugin, OCI CLI, MinIO client (`mc`)
- **IaC / build:** terraform, packer, mise, docker CLI, docker-compose
- **Security:** trivy
- **Git:** glab
- **Languages:** Go (with `gore`, `gopls`), Python, OpenJDK 17 (headless)
- **Editors:** vim, neovim (with lazy.nvim preinstalled in `/opt/nvim-config`)
- **Misc:** postgres/mysql/redis clients, jq, ripgrep, tmux, pandoc, plantuml, socat, qemu/kvm, tigervnc and more

Tool versions are pinned as `ENV *_VERSION` in the `Dockerfile`.

## Configuration

`config/project.json` holds the image repo/name/tag (`docker.*`), the dev domain (`ptoolz.domain`) and the kind LB IP (`kind.panel.ip`).

Optional, git-ignored per-user files in `me/`:

- `me/.bashrc` – used as rcfile for the interactive shell
- `me/env` – passed to the container as `--env-file`
- `me/kube/config` – `KUBECONFIG`
- `me/helm` – `HELM_HOME`

## Usage

Build the image:

```bash
bin/build            # local build (tag: latest)
bin/build release    # build and tag with a timestamp
```

Run the container (opens a shell when no command is given):

```bash
bin/run                    # interactive shell
bin/run build              # docker build + tag with docker.dev.tag
bin/run update             # docker pull
bin/run release <tag>      # build and push latest + <tag>
```

`bin/run` uses host networking and mounts the docker socket, `~/.ssh`, the SSH agent, the GPG socket (if present) and `/dev/kvm`. It may call `sudo` to add the kind LB IP to `lo` and to chown `/var/run/docker.sock`.

## Plugins

`plugins/claude/prompt/prompt.py` – sends a single prompt to Claude: `python plugins/claude/prompt/prompt.py "question"` (needs `ANTHROPIC_API_KEY`).
