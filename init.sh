#!/usr/bin/env bash

set -eu

function check_cmd(){
  # check command existed
	cmd=$1
	command -v $cmd >/dev/null 2>&1 || (echo >&2 "need $cmd but it's not installed. " && exit 1)
}

function install_compose(){
  # install docker-compose
  echo "docker-compose not exist, start installing.."
  sleep 1
  sudo curl -L "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

}

function create_network(){
  # create network docker-compose needs
  NETWORK_ID=$(docker network ls -f name=bkci_default -q)
  if [[ -z "$NETWORK_ID" ]];then
    docker network create bkci_default --subnet 192.168.1.0/24
  fi
}

function generate_config(){
  # compose up
  cp -vf bkenv.properties ci/scripts/
  cd ci/scripts && ./render_tpl -m ci ../support-files/templates/*
  cd ../../
  sed -i '/开发时需要配置Host解析到iam.service.consul/,$d' etc/ci/common.yml
  sed -i '/# certificate server/,+2d' etc/ci/common.yml
  sed -i '/#S3 Storage/,+6d' etc/ci/common.yml
  sed -i '/access_log/d' ci/gateway/core/devops.server.conf
  sed -i '/error_log/d' ci/gateway/core/devops.server.conf
}

function main(){
  cd /data/docker/bkci || (echo "workdir not found, exit.." && exit 1)
  check_cmd docker-compose || install_compose
  create_network
  test -d ci || (echo "ci not found, exit.." && exit 1)

  # prepare config
  generate_config
  chmod +x ci/*/boot-*.sh
  chmod +x scripts/*.sh
  # compose up
  
  docker-compose up -d --remove-orphans

  # launch consul
  echo "launch consul for backend and gateway.."
  docker-compose exec backend nohup bash -c "consul agent -datacenter=dc -domain=ci -data-dir=/tmp -join=consul &"
  docker-compose exec frontend nohup bash -c "consul agent -datacenter=dc -domain=ci -data-dir=/tmp -join=consul &"

  # patch db
  echo "patch multi sql to mysql.."
  sleep 15
  docker-compose exec mysql bash -c "/scripts/patch_sql.sh"

  # launch all services
  echo "launch all services begin.."
  docker-compose exec backend bash -c "/scripts/launch_services.sh start"

  # add hosts
  if grep -q '^127.0.0.1 my-dev.ci.com' /etc/hosts;then
    echo "host exist, skip.."
  else
    echo "127.0.0.1 my-dev.ci.com" >> /etc/hosts
  fi

}

main
