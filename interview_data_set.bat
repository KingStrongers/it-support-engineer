# 解压缩数据集文件（如果没有安装7-Zip，请先下载并安装）
& "C:\Program Files (x86)\360\360zip\360zip.exe" e interview_data_set.gz

# 使用Select-String和ForEach-Object分析日志文件并生成JSON
$device_name = "my_device"
$process_id = "0"
$process_name = ""
$description = ""
$time_window = ""
$num_occurrences = 0

Get-Content .\interview_data_set | Select-String "Error" | ForEach-Object {
  $line = $_ -replace "\s+", " "
  if ($line -match "Error") {
    $process_id = $line.Split()[3]
    $process_name = $line -replace ".*Process/Service Name: (.+?)( Description.*)?", '$1'
    $description = $line -replace ".*Description: (.+?)( Hour.*)?", '$1'
    $hour = $line.Substring(1,2)

    # 计算错误发生次数和时间窗口
    if ($time_window -eq "$hour`-*") {
      $num_occurrences++
    }
    else {
      if ($time_window -ne "") {
        $json = @{
          deviceName = $device_name
          processld = $process_id
          processName = $process_name
          description = $description
          timeWindow = $time_window
          numberOfOccurrence = $num_occurrences
        } | ConvertTo-Json
        Invoke-RestMethod -Uri "https://foo.com/bar" -Method Post -ContentType "application/json" -Body $json
      }
      $time_window = "$hour`-*"
      $num_occurrences = 1
    }
  }
}

# 删除解压后的数据文件
Remove-Item interview_data_set