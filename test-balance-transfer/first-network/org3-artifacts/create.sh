export PATH=${PWD}/../../../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}
CHANNEL_NAME="mychannel"
function generateChannelArtifacts() {
  which configtxgen
  if [ "$?" -ne 0 ]; then
    echo "configtxgen tool not found. exiting"
    exit 1
  fi

  echo "##########################################################"
  echo "#########  Generating Orderer Genesis block ##############"
  echo "##########################################################"
  # Note: For some unknown reason (at least for now) the block file can't be
  # named orderer.genesis.block or the orderer will fail to launch!
  configtxgen -profile TwoOrgsOrdererGenesis -outputBlock genesis_org3.block
  if [ "$?" -ne 0 ]; then
    echo "Failed to generate orderer genesis block..."
    exit 1
  fi
  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org3MSP   ##########"
  echo "#################################################################"
  configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ../channel-artifacts/Org3MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org3MSP
  if [ "$?" -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org2MSP..."
    exit 1
  fi
  echo

}

generateChannelArtifacts
curl -X POST --data-binary @genesis_org3.block http://127.0.0.1:7059/protolator/decode/common.Block > genesis_org3.json
jq .data.data[0].payload.data.config genesis_org3.json >genesis_new.json
