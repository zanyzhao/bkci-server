cd /data/docker/bkci/ci/ || exit 1

for i in */boot-*.sh;do
  case $i in
    *notify*) continue;;
    *openapi*) continue;;
    *) sed -i 's/256m/2g/g' $i && bash $i $1
  esac
done
