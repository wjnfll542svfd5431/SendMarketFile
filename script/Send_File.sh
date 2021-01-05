#作者：wjn
#!/bin/bash
#读取配置函数
function GetConfig(){
    #获取下游系统名称
    section=$(echo $1 | cut -d '.' -f 1)
    #获取对象属性
    key=$(echo $2 | cut -d '.' -f 2)
    sen -n '/\${section\},/\[.*\]/{
        /^[.*\]/d
	/^[\t]*$/d
	/^$/d
	/^#.*$/d
	s/^[\t]*$key[ \t]*=[ \t]*\(.*\)[ \t]*/\1/p
  }' $CONFIGFILE
}
#配置文件地址
CONFIGFILE=configPath
#获取配置中下游名称
profile=`sed -n '/ids/'p $CONFIGFILE | awk -F='{print $2}' | sed 's/,/ /g'`
for subsystem in $profile
do
    IP=$(GetConfig "${subsystem}.ip")
    USER =$(GetConfig "${subsystem}.user")
    SRCDIR=$(GetConfig "${subsystem}.srcdir")
    PORT=$(GetConfig "${subsystem}.port")
    DEDIR=$(GetConfig "${subsystem}.dedir")
    DAY=$(GetConfig "${subsystem}.dat")
    TIME=$(GetConfig "${subsystem}.time")
    cd ${SRCDIR}
    #查询${DAY}前增加的文件夹
    FOLDERS=`find ${SRCDIR} -ctime -${DAY} -type d -maxdepth 1`
    for FOLDER_NAME in $FOLDERS
    do
	#查询#{TIME}分钟内增加文件
        FILES=`find ${FOLDER_NAME}/ -name '*.*' -mmin -${TIME}`
	for FILE in ${FILES}
	    do
	        sftp -oPoer=${PORT} ${USER}@${IP} <<EOF
		cd ${PATH}
		lcd ${SRCDIR}
		put ${FILE}
		by
EOF
            done
    done    
done        
