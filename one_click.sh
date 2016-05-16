!/bin/sh

PROJECT_PATH=/opt/eoop

NGINX_CMD="/sbin/service nginx"
REDIS_CMD="/sbin/service redis"
IPTABLES_CMD="/sbin/service iptables"
ACTIVEMQ_CMD=$PROJECT_PATH/apache-activemq-5.1.0/bin/activemq
MEMCACHED_CMD=$PROJECT_PATH/memcached-1.4.22/memcached
OPENFILE_CMD=$PROJECT_PATH/openfire/bin/openfire 
CMS_SERVER_CMD=$PROJECT_PATH/cms-server/bin/catalina.sh
EOOP_SERVER_CMD=$PROJECT_PATH/eoop-server/bin/catalina.sh

# change workspace
cd $PROJECT_PATH

pid_redis=0
getRedisID()
{
    ps_redis=`ps -ef| grep redis | grep -v grep`
    if [ -n "$ps_redis" ]; then
        pid_redis=`echo ${ps_redis} | awk '{print $2}'`
    else
        pid_redis=0
    fi
}

pid_activemq=0
getActivemqID()
{
    ps_activemq=`ps -ef  | grep jdk | grep apache-activemq | grep 'Dorg.apache.activemq.UseDedicatedTaskRunner=true' | grep -v grep`
    if [ -n "$ps_activemq" ]; then
        pid_activemq=`echo ${ps_activemq} | awk '{print $2}'`
    else
        pid_activemq=0
    fi
}

pid_nginx=0
getNginxID()
{
    ps_nginx=`ps -ef| grep nginx | grep nginx.conf | grep -v grep`
    if [ -n "$ps_nginx" ]; then
        pid_nginx=`echo ${ps_nginx} | awk '{print $2}'`
    else
        pid_nginx=0
    fi
}

pid_memcache=0
getMemcacheID()
{
    ps_memcache=`ps -ef| grep memcached | grep -v grep`
    if [ -n "$ps_memcache" ]; then
        pid_memcache=`echo ${ps_memcache} | awk '{print $2}'`
    else
        pid_memcache=0
    fi
}

pid_openfire=0
getOpenfireID()
{
    ps_openfire=`ps -ef| grep jdk | grep openfire | grep -v grep`
    if [ -n "$ps_openfire" ]; then
        pid_openfire=`echo ${ps_openfire} | awk '{print $2}'`
    else
        pid_openfire=0
    fi
}

pid_cms_server=0
getCMSID()
{
    ps_cms_server=`ps -ef  | grep jdk | grep cms-server | grep 'org.apache.catalina.startup.Bootstrap start' | grep -v grep`
    if [ -n "$ps_cms_server" ]; then
        pid_cms_server=`echo ${ps_cms_server} | awk '{print $2}'`
    else
        pid_cms_server=0
    fi
}

pid_eoop_server=0
getEOOPID()
{
    ps_eoop_server=`ps -ef  | grep jdk | grep eoop-server | grep 'org.apache.catalina.startup.Bootstrap start' | grep -v grep`
    if [ -n "$ps_eoop_server" ]; then
        pid_eoop_server=`echo ${ps_eoop_server} | awk '{print $2}'`
    else
        pid_eoop_server=0
    fi
}

start()
{
    $IPTABLES_CMD start

    getNginxID
    if [ $pid_nginx -ne 0 ]; then  
        echo "Nginx already started(PID=$pid_nginx)" 
    else
        echo "[Starting Nginx]"
        $NGINX_CMD start
        if [[ $? -eq 0 ]];then
            echo "[Started Nginx OK]"
        else
            echo "[Start Nginx Failed]"
            exit 1
        fi
    fi

    echo
    getRedisID
    if [ $pid_redis -ne 0 ]; then
        echo "Redis already started(PID=$pid_redis)"
    else
        echo "[Starting Redis]"
        $REDIS_CMD start
        if [[ $? -eq 0 ]];then
            echo "[Started Redis OK]"
        else
            echo "[Start Redis Failed]"
            echo "[Stop all the other related processes!]"
            stop
            exit 1
        fi
    fi

    echo
    getActivemqID
    if [ $pid_activemq -ne 0 ]; then
        echo "Activemq already started(PID=$pid_activemq)"
    else
        echo "[Starting Activemq]"
        nohup $ACTIVEMQ_CMD &
        if [[ $? -eq 0 ]];then
            echo "[Started Activemq OK]"
        else
            echo "[Start Activemq Failed]"
            echo "[Stop all the other related processes!]"
            stop
            exit 1
        fi
    fi


    echo
    getOpenfireID
    if [ $pid_openfire -ne 0 ]; then
        echo "Openfire already started(PID=$pid_openfire)"
    else
        echo "[Starting Openfire]"
        $OPENFILE_CMD start
        if [[ $? -eq 0 ]];then
            echo "[Started Openfire OK]"
        else
            echo "[Start Openfire Failed]"
            echo "[Stop all the other related processes!]"
            stop
            exit 1
        fi
    fi

    echo
    getCMSID
    if [ $pid_cms_server -ne 0 ]; then
        echo "CMS Server already started(PID=$pid_cms_server)"
    else
        echo "[Starting CMS Server]"
        $CMS_SERVER_CMD start
        if [[ $? -eq 0 ]];then
            echo "[Started CMS Server OK]"
        else
            echo "[Start CMS Server Failed]"
            echo "[Stop all the other related processes!]"
            stop
            exit 1
        fi
    fi

    echo
    getEOOPID
    if [ $pid_eoop_server -ne 0 ]; then
        echo "EOOP Server already started(PID=$pid_eoop_server)"
    else
        echo "[Starting EOOP Server]"
        $EOOP_SERVER_CMD start
        if [[ $? -eq 0 ]];then
            echo "[Started EOOP Server OK]"
        else
            echo "[Start EOOP Server Failed]"
            echo "[Stop all the other related processes!]"
            stop
            exit 1
        fi
    fi

    echo
    echo "[Done all the startups successfully!]"
    echo
}

stop()
{
    
    $IPTABLES_CMD stop
    getNginxID
    if [ $pid_nginx -ne 0 ]; then
        echo "[Stopping Nginx]"
        $NGINX_CMD stop
        if [[ $? -eq 0 ]];then
            echo "[Stopped Nginx OK]"
        else
            echo "[Failed to Stop Nginx!]"
            exit 1
        fi
    else
        echo "Nginx is not running"
    fi

    echo
    getOpenfireID
    if [ $pid_openfire -ne 0 ]; then
        echo "[Stopping Openfire]"
        $OPENFILE_CMD stop
        if [[ $? -eq 0 ]];then
            echo "[Stopped Openfire OK]"
        else
            echo "[Failed to Stop Openfire!]"
            exit 1
        fi
    else
        echo "Openfire is not running"
    fi

    echo
    getCMSID
    if [ $pid_cms_server -ne 0 ]; then
        echo "[Stopping CMS Server]"
        $CMS_SERVER_CMD stop
        # seems we have to do this dirty kill for cms-sever!!!!!!!!
        kill -9 $pid_cms_server
        if [[ $? -eq 0 ]];then
            echo "[Stopped CMS Server OK]"
        else
            echo "[Failed to Stop CMS Server!]"
            exit 1
        fi
    else
        echo "CMS Server is not running"
    fi

    echo
    getEOOPID
    if [ $pid_eoop_server -ne 0 ]; then
        echo "[Stopping EOOP Server]"
        $EOOP_SERVER_CMD stop
        # seems we have to do this dirty kill for eoop-sever!!!!!!!!
        kill -9 $pid_eoop_server
        if [[ $? -eq 0 ]];then
            echo "[Stopped EOOP Server OK]"
        else
            echo "[Failed to Stop EOOP Server!]"
            exit 1
        fi
    else
        echo "EOOP Server is not running"
    fi

    echo
    getRedisID
    if [ $pid_redis -ne 0 ]; then
        echo "[Stopping Redis Server]"
	$REDIS_CMD stop
        if [[ $? -eq 0 ]];then
            echo "[Stopped Redis Server OK]"
        else
            echo "[Failed to Stop Redis Server!]"
            exit 1
        fi
    else
        echo "Redis Server is not running"
    fi

    echo
    getActivemqID
    if [ $pid_activemq -ne 0 ]; then
        echo "[Stopping Activemq Server]"
        kill -9 $pid_activemq
	if [[ $? -eq 0 ]];then
            echo "[Stopped Activemq Server OK]"
        else
            echo "[Failed to Stop Activemq Server!]"
            exit 1
        fi
    else
        echo "Activemq Server is not running"
    fi

    echo
    echo "[Done all the stop jobs successfully!]"
    echo
}

case "$1" in   
  start)   
      start   
      ;;   
  stop)   
      stop   
      ;;   
  restart)
      stop
      start
      ;;
  *)   
      echo $"Usage: $0 {start|stop|restart}"  
      exit 1  
esac   
exit 0  
