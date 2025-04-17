FILE_NAME=$1
if [ ! -e $FILE_NAME ]; then
  echo "ファイルが存在しません:" $INPUT_FILE
  exit 1
fi
EXEC_COMMAND="java -classpath .:/usr/share/java/gdal.jar -Djava.library.path=/usr/lib/jni -jar voxel-data-link-command-0.0.1.jar --spring.config.location=application-at.yml --logging.config=logback-spring-voxel.xml -city "
divisor=$2
mod=0
count=0
UUIDS=""
while read LINE
do
  count=`expr $count + 1`
  if [ -z $UUIDS ]; then
    UUIDS=$LINE
  else
    UUIDS="${UUIDS},${LINE}"
  fi
#  echo $count $LINE
  mod=`expr $count % $divisor`
  if [ $mod -eq 0 ]; then
    echo ${EXEC_COMMAND} ${UUIDS}
    eval ${EXEC_COMMAND} ${UUIDS}
    UUIDS=""
  fi
done < ${FILE_NAME}
if [ ! -z $UUIDS ]; then
  echo ${EXEC_COMMAND} ${UUIDS}
  eval ${EXEC_COMMAND} ${UUIDS}
fi
