#! /bin/bash

cd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -d photos_iphone ]
then
    rm -r photos_iphone
fi

mkdir photos_iphone

./download_images_commons.py 640 photos_iphone database/PLData.json
