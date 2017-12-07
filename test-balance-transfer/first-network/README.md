## Build Your First Network (BYFN)

The directions for using this are documented in the Hyperledger Fabric
["Build Your First Network"](http://hyperledger-fabric.readthedocs.io/en/latest/build_network.html) tutorial.



CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/users/Admin@example.com/msp/
CORE_PEER_LOCALMSPID="OrdererMSP"
peer channel fetch config -o orderer.example.com:7050 -c "mychannel" --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem



ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
peer channel fetch config -o orderer.example.com:7050 -c mychannel --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA|xargs mv true config_block.pb
curl -X POST --data-binary @config_block.pb http://127.0.0.1:7059/protolator/decode/common.Block > config_block.json
jq .data.data[0].payload.data.config config_block.json > config.json
