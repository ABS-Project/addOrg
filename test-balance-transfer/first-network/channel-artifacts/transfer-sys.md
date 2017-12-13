# ###########
cli：in folder channel-artifacts

ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
peer channel fetch config -o orderer.example.com:7050 -c mychannel --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA|xargs mv true mychannel_config_block.pb
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/users/Admin@example.com/msp/
CORE_PEER_LOCALMSPID="OrdererMSP"
peer channel fetch config -o orderer.example.com:7050 -c testchainid --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA|xargs mv true sys_config_block.pb


###########
在终端的channel-artifacts目录下执行：


curl -X POST --data-binary @sys_config_block.pb http://127.0.0.1:7059/protolator/decode/common.Block > sys_config_block.json
jq .data.data[0].payload.data.config sys_config_block.json > sys_config.json
#
执行org3-articacts下create.sh后，手动将Org3MSP的内容粘贴到sys_update_config.json
#
curl -X POST --data-binary @sys_config.json http://127.0.0.1:7059/protolator/encode/common.Config > sys_config.pb
curl -X POST --data-binary @sys_update_config.json http://127.0.0.1:7059/protolator/encode/common.Config > sys_update_config.pb
curl -X POST -F original=@sys_config.pb -F updated=@sys_update_config.pb http://127.0.0.1:7059/configtxlator/compute/update-from-configs -F channel=testchainid > sys_config_update.pb
curl -X POST --data-binary @sys_config_update.pb http://127.0.0.1:7059/protolator/decode/common.ConfigUpdate > sys_config_update.json
echo '{"payload":{"header":{"channel_header":{"channel_id":"testchainid", "type":2}},"data":{"config_update":'$(cat sys_config_update.json)'}}}' > sys_config_update_in_envelope.json
curl -X POST --data-binary @sys_config_update_in_envelope.json http://127.0.0.1:7059/protolator/encode/common.Envelope > sys_config_update_in_envelope.pb


# cli：in folder channel-artifacts
peer channel update -o orderer.example.com:7050 -c testchainid -f sys_config_update_in_envelope.pb --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
