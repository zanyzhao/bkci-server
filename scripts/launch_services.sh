cd /data/docker/bkci/ci/ || exit 1
if [[ ! "$1" =~ "start|stop|restart" ]];then
  exit 1
fi
for i in */boot-*.sh;do
  case $i in
    *notify*) continue;;
    *openapi*) continue;;
    *) bash $i $1
  esac
done
