# #!/bin/bash

#参数判断

if [ ! -d $1 ];then
echo "The first param is not a dictionary."
exit  1
fi

cd $1
cd ../sharedata/exceldata/

sh run_mac.sh
cp ./data/client/*.lua ../../client/LuaScript/Data/
echo success!
cd ../../client
