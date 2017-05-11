#! /bin/bash

# 變量設置
VOLUME_DIRECTORY_DEVELOPER_SRC=/Users/nangua/Developer/src
VOLUME_DIRECTORY_DEVELOPER_DATA=/Users/nangua/Developer/data
VOLUME_DIRECTORY_DEVELOPER_DEVOPS=/Users/nangua/Developer/src/coding.net/nangua/nangua.me/DevOps

DEFAULT_CONTAINERS="dataContainer php-fpm nginx redis mysql"


### 數據容器，多個容器間共享數據卷
function docker_do_start_dataContainer() {
	echo "start data container"
	docker run --name dataContainer \
		-v /tmp:/tmp \
		-v /tmp/data:/data \
		-v /tmp/log/nginx:/var/log/nginx \
		-v $VOLUME_DIRECTORY_DEVELOPER_SRC:/www \
		-v $VOLUME_DIRECTORY_DEVELOPER_SRC:/var/www/html \
		-v $VOLUME_DIRECTORY_DEVELOPER_DEVOPS/docker.d/nginx/nginx.conf:/etc/nginx/nginx.conf \
		-v $VOLUME_DIRECTORY_DEVELOPER_DEVOPS/docker.d/nginx/conf.d:/etc/nginx/conf.d \
		-v $VOLUME_DIRECTORY_DEVELOPER_DEVOPS/docker.d/php/conf.d:/usr/local/etc/php/conf.d \
		-v $VOLUME_DIRECTORY_DEVELOPER_DATA/mysql:/var/lib/mysql \
		-d -P alpine:latest echo data container only
}


# 命令行連接
# docker run -it --link mysql:mysql --rm mysql sh -c 'exec mysql -h"$MYSQL_PORT_3306_TCP_ADDR" -P"$MYSQL_PORT_3306_TCP_PORT" -uroot -p"$MYSQL_ENV_MYSQL_ROOT_PASSWORD"'
function docker_do_start_mysql() {
	echo "start mysql"
	docker run --name mysql \
		-p 3306:3306 \
		-e MYSQL_ROOT_PASSWORD=11211 \
		-e MYSQL_ROOT_HOST=% \
		--volumes-from dataContainer \
		-d mysql:latest
}


# 命令行連接
#docker run --name redis-cli -it --link redis:redis --rm redis:alpine redis-cli -h redis -p 6379
function docker_do_start_redis() {
	echo "start redis"
	docker run --name redis \
		-p 6379:6379 \
		--volumes-from dataContainer \
		-d redis:alpine redis-server --appendonly yes
}


function docker_do_start_php-fpm() {
	echo "start php-fpm"
	docker run --name php-fpm\
		-p 9000:9000 \
		--volumes-from dataContainer \
		--link mysql:mysql \
		--link redis:redis \
		-d nangua/php:latest
}


function docker_do_start_nginx() {
	echo "start nginx"
	docker run --name nginx \
		-p 80:80 \
		-p 443:443 \
		--volumes-from dataContainer \
		--link php-fpm:php-fpm \
		-d nginx:alpine
}


function docker_start() {
	echo "removing all default container"
	echo "docker rm -f $DEFAULT_CONTAINERS"
	docker rm -f $DEFAULT_CONTAINERS

	echo "starting all default container"
	docker_do_start_dataContainer
	docker_do_start_mysql
	docker_do_start_redis
	docker_do_start_php-fpm
	docker_do_start_nginx
}


function docker_stop() {
	if [ "$1" == "" ]; then
		echo "stoping all default container"
		echo "docker stop $DEFAULT_CONTAINERS"
		docker stop $DEFAULT_CONTAINERS
	else
		echo "stoping container $1"
		docker stop $1
	fi
}


function docker_restart() {
	if [ "$1" == "" ]; then
		echo "restarting all default container"
		echo "docker restart  $DEFAULT_CONTAINERS"
		docker restart $DEFAULT_CONTAINERS
	else
		echo "restarting container $1"
		docker restart $1
	fi
}


function docker_remove() {
	if [ "$1" == "" ]; then
		echo "removing all default container"
		echo "docker rm -f $DEFAULT_CONTAINERS"
		docker rm - $DEFAULT_CONTAINERS
	else
		echo "removing container $1"
		docker rm -f $1
	fi
}


# main func
case $1 in
	start)
		docker_start $2
	;;
	stop)
		docker_stop
	;;
	restart)
		docker_restart $2
	;;
	remove)
		docker_remove $2
	;;
	*)
		echo "Usage:"
		echo "$0 start|stop|restart|rm [container name]"
		echo 
		echo "不指定容器名稱，則默認遍歷 {dataContainer,php-fpm,nginx,redis,mysql}"
	;;
esac
