#!/bin/bash

########################################################

# 定时删除es索引，默认保留7天之内的数据，保留天数也可匹配具体的服务

########################################################

# 删除索引函数，参数1: 索引类别  参数2: 保留天数
function delete_indices() {
    echo $1,$2
    # 获取比较日期
    CMP_DATE=`date -d "$2 day ago" +"%Y-%m-%d"`
    # 获取当前索引类型下的所有日期
    curl -XGET http://ip:port/_cat/indices -u username:password | awk -F " " '{if($3 ~ pattern)print $3}' pattern=$1 | awk -F "-" '{print $NF}' | egrep "[0-9]*\.[0-9]*\.[0-9]*" | awk -F "." '{if(NF=4)$NF=""}{print $1"."$2"."$3}' | sort | uniq  | sed 's/\./-/g' | while read DATE
    do
        date1="${DATE} 00:00:00"
        date2="${CMP_DATE} 00:00:00"

        t1=`date -d "$date1" +%s`
        t2=`date -d "$date2" +%s`

        if [ $t1 -le $t2 ]; then
            echo $1
            format_date=`echo ${DATE} | sed 's/-/\./g'`
            echo $format_date

            curl -XDELETE http://ip:port/$1*$format_date* -u username:password
        fi
    done

}

# 获取所有索引类型，一般一个服务对应一种类型，某个服务也可对应多种索引类型
curl -XGET http://ip:port/_cat/indices -u username:password | awk -F" " '{print $3}' | awk -F "-" '{{$NF=""};print $0}'| awk 'gsub(" ","-")' | sort | uniq | while read INDICES
do
    # 当前默认所有索引保存7天，可根据不同服务设定保留天数
    delete_indices ${INDICES} 1
done
