# 开发环境配置

*Ubuntu20.04 / WSL*

## 基础

```bash
sudo apt-get install curl git cmake net-tools protobuf-compiler sshpass inotify-tools
```

## Rust

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

## Asdf

```bash
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.10.0
```

* 添加以下内容到 ~/.bashrc

```bash
. $HOME/.asdf/asdf.sh
```

```bash
. $HOME/.asdf/completions/asdf.bash
```

## Erlang

```bash
sudo apt-get -y install build-essential autoconf m4 libncurses5-dev libwxgtk3.0-gtk3-dev libwxgtk-webview3.0-gtk3-dev libgl1-mesa-dev libglu1-mesa-dev libpng-dev libssh-dev unixodbc-dev xsltproc fop libxml2-utils libncurses-dev openjdk-11-jdk
```

```bash
asdf plugin-add erlang
```

```bash
asdf install erlang 25.0
```

```bash
asdf global erlang 25.0
```

## Elixir

```bash
asdf plugin-add elixir
```

```bash
asdf install elixir 1.13.4-otp-25
```

```bash
asdf global elixir 1.13.4-otp-25
```

## Redis
