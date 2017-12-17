####1#######
在终端执行docker exec -it cli bash进入cli容器，然后在cli容器的clichannel-artifacts目录下执行下面的命令：

ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
peer channel fetch config -o orderer.example.com:7050 -c mychannel --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA|xargs mv true mychannel_config_block.pb
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/users/Admin@example.com/msp/
CORE_PEER_LOCALMSPID="OrdererMSP"
peer channel fetch config -o orderer.example.com:7050 -c testchainid --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA|xargs mv true sys_config_block.pb


####2######
在test-balance-trance-transfer/first-network/channel-artifacts目录下执行：

curl -X POST --data-binary @sys_config_block.pb http://127.0.0.1:7059/protolator/decode/common.Block > sys_config_block.json
jq .data.data[0].payload.data.config sys_config_block.json > sys_config.json
#
手动复制sys_config.json文件并命名为sys_update_config.json
将test-balance-trance-transfer/first-network/channel-artifacts/genesis_org3.json中Org3MSP的内容追加到sys_update_config.json
#
然后执行下面的命令，主要是生成加入Org3MSP前后的差分文件
curl -X POST --data-binary @sys_config.json http://127.0.0.1:7059/protolator/encode/common.Config > sys_config.pb
curl -X POST --data-binary @sys_update_config.json http://127.0.0.1:7059/protolator/encode/common.Config > sys_update_config.pb
curl -X POST -F original=@sys_config.pb -F updated=@sys_update_config.pb http://127.0.0.1:7059/configtxlator/compute/update-from-configs -F channel=testchainid > sys_config_update.pb
curl -X POST --data-binary @sys_config_update.pb http://127.0.0.1:7059/protolator/decode/common.ConfigUpdate > sys_config_update.json
echo '{"payload":{"header":{"channel_header":{"channel_id":"testchainid", "type":2}},"data":{"config_update":'$(cat sys_config_update.json)'}}}' > sys_config_update_in_envelope.json
curl -X POST --data-binary @sys_config_update_in_envelope.json http://127.0.0.1:7059/protolator/encode/common.Envelope > sys_config_update_in_envelope.pb

#####3######
#在cli容器的channel-artifacts目录下执行下面的命令，执行成功则org3成功加入系统通道
peer channel update -o orderer.example.com:7050 -c testchainid -f sys_config_update_in_envelope.pb --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
