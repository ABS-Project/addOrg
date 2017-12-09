# 此脚本用于删除ca下面的server.db
function cleardb() {
  #statements
  # 此脚本用于删除ca下面的server.db
  CURRENT_DIR=$PWD
  ## for i in 1 2 3 4
  i=1
  while [ $i -lt 5 ]
    do
    cd $CURRENT_DIR
    cd ./first-network/fabric-ca-server/org$i
    if [ -d './msp' ];then
      sudo rm -rf msp
    fi

    # cd artifacts/crypto-config/peerOrganizations/org$i.example.com/ca/
    if [ -f *.db ];then
     sudo rm -f *db
    fi
    let "i = $i + 1"
  done
  cd "$CURRENT_DIR"
}
