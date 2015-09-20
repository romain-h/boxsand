#!/usr/bin/env bash

set -e

USER=vagrant
PASSWORD=vagrant

export GOPATH=$HOME/golang
export GOROOT=$HOME/go
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH

apt_get_update () {
  # We only want to do this on the very first run.
  if [ ! -f $HOME/.apt_get_last_updated ]; then
    sudo apt-get update
    date "+%s" > $HOME/.apt_get_last_updated
  fi
}

install_dotfiles () {
  if [ ! -f /etc/apt/sources.list.d/git-core-ppa-precise.list ]; then
    sudo add-apt-repository ppa:git-core/ppa
    sudo apt-get update
  fi

  sudo apt-get install -y git

  if [ ! -d $HOME/.dotfiles ]; then
    git clone https://github.com/romain-h/dotfiles.git $HOME/.dotfiles

    $HOME/.dotfiles/install.sh init

    # Change the remote to one we can push to.
    cd $HOME/.dotfiles
    git remote set-url origin "git@github.com:romain-h/dotfiles.git"
  fi
}

install_go () {
  sudo apt-get install -y mercurial

  if [ ! $(which go) ]; then
    if [ ! -d $GOROOT ]; then
      hg clone -u release https://code.google.com/p/go $GOROOT
    fi

    cd $GOROOT/src
    ./all.bash
  fi

  mkdir -p $GOPATH

  go get code.google.com/p/go.tools/cmd/goimports
  go get github.com/golang/lint/golint
  go get golang.org/x/tools/cmd/vet
}

install_ruby () {
  sudo apt-get install -y python-software-properties

  if [ ! -f /etc/apt/sources.list.d/brightbox-ruby-ng-precise.list ]; then
    sudo add-apt-repository ppa:brightbox/ruby-ng
    sudo apt-get update
  fi

  sudo apt-get install -y ruby2.1
}

install_java () {
  sudo apt-get install -y python-software-properties

  if [ ! -f /etc/apt/sources.list.d/webupd8team-java-precise.list ]; then
    sudo add-apt-repository ppa:webupd8team/java
    sudo apt-get update
  fi

  sudo apt-get install -y oracle-java8-installer
}

install_scala () {
  if [ ! $(which scala) ]; then
    curl -s -o /tmp/scala-2.10.5.tgz http://downloads.typesafe.com/scala/2.10.5/scala-2.10.5.tgz
    tar -xzf /tmp/scala-2.10.5.tgz -C /tmp
    sudo mv /tmp/scala-2.10.5 /usr/local/share/scala
    echo "export SCALA_HOME=\"/usr/local/share/scala\"" >> $HOME/.env_custom
    echo "export PATH=\"\$PATH:\$SCALA_HOME/bin\"" >> $HOME/.env_custom

    # Install sbt
    if [ ! /etc/apt/sources.list.d/sbt.list ]; then
      echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
      sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 642AC823
      sudo apt-get update
    fi

    sudo apt-get install sbt
  fi
}

main () {
  apt_get_update
  install_dotfiles
  install_go
  install_ruby
  install_java
  install_scala
}

main
