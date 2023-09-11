#!/bin/bash

# Введите путь к директории, в которой нужно искать большие файлы
dir_path="/home/bitrix/www/upload/disk/"

# Введите размер файла в килобайтах, выше которого файлы будут удалены
file_size="1800000"

# Ищем файлы, размер которых больше указанного значения, и сохраняем их в отдельный файл
#find $dir_path -type f -size +${file_size}k 2>/dev/null
find $dir_path -type f -size +${file_size}k -print > big_files.txt

# Показываем найденные файлы
# cat big_files.txt

# Читаем файл со списком больших файлов и удаляем каждый из них
while IFS= read -r file; do
  rm "$file"
done < big_files.txt

# Удаляем временный файл
rm big_files.txt
