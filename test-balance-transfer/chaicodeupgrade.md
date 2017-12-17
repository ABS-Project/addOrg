
#######以下在cli环境中进行，在执行完安装新版本链码后执行######

export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=peer0.org1.example.com:7051
peer chaincode upgrade -o orderer.example.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C mychannel -n mycc -v v1 -c '{"Args":["init",""]}' -P "OR ('Org1MSP.member','Org2MSP.member','Org3MSP.member')"

###########可顺手在cli中查以下账本的数据#########
peer chaincode query -C mychannel -n mycc -c '{"Args":["query","a"]}'


##########然后执行updatechaincode.sh
