for i in /sql/*.sql;do
  export MYSQL_PWD=root
  mysql -uroot < $i
done
