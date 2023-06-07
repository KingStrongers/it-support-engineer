#!/bin/bash

# 解压缩数据集文件
gzip -d interview_data_set.gz

# 使用grep和awk命令分析日志文件并生成JSON
device_name="my_device"
process_id="0"
process_name=""
description=""
time_window=""
num_occurrences=0

while read -r line; do
  # 匹配关键字，提取相关信息
  if echo "$line" | grep -q "Error"; then
    process_id=$(echo "$line" | awk '{print $4}')
    process_name=$(echo "$line" | grep -o -E 'Process/Service Name: [^ ]+' | cut -d' ' -f4-)
    description=$(echo "$line" | grep -o -E 'Description: [^ ]+' | cut -d' ' -f2-)
    hour=$(echo "$line" | cut -c 2-3)

    # 计算错误发生次数和时间窗口
    if [ "$time_window" = "$hour"-* ]; then
      ((num_occurrences++))
    else
      if [ "$time_window" != "" ]; then
        json='{
          "deviceName": "'"$device_name"'",
          "processld": "'"$process_id"'",
          "processName": "'"$process_name"'",
          "description": "'"$description"'",
          "timeWindow": "'"$time_window"'",
          "numberOfOccurrence": '"$num_occurrences"'
        }'
        curl -H "Content-Type: application/json" -X POST -d "$json" https://foo.com/bar
      fi
      time_window="$hour"-*
      num_occurrences=1
    fi
  fi
done < <(zcat interview_data_set)

# 删除解压后的数据文件
rm interview_data_set