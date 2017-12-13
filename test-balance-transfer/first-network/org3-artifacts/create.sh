export PATH=${PWD}/../../../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}
CHANNEL_NAME="newchannel"


function generateCerts (){
  which cryptogen
  if [ "$?" -ne 0 ]; then
    echo "cryptogen tool not found. exiting"
    exit 1
  fi
  echo
  echo "##########################################################"
  echo "##### Generate certificates using cryptogen tool #########"
  echo "##########################################################"
  if [ -d "crypto-config" ]; then
    rm -Rf crypto-config
  fi
  if [ -d "../crypto-config/peerOrganizations/org3.example.com" ]; then
    sudo rm -Rf ../crypto-config/peerOrganizations/org3.example.com
  fi
  cryptogen generate --config=./crypto-config.yaml
  mv ./crypto-config/peerOrganizations/* ../crypto-config/peerOrganizations/
  if [ "$?" -ne 0 ]; then
    echo "Failed to generate certificates..."
    exit 1
  fi
  echo
}
# configuration
function replacePrivateKey () {
  # sed on MacOSX does not support -i flag with a null extension. We will use
  # 't' for our back-up's extension and depete it at the end of the function
  ARCH=`uname -s | grep Darwin`
  if [ "$ARCH" == "Darwin" ]; then
    OPTS="-it"
  else
    OPTS="-i"
  fi

  # Copy the template to the file that will be modified to add the private key
  cp ../docker-compose-org3-template.yaml ../docker-compose-org3.yaml

  # The next steps will replace the template's contents with the
  # actual values of the private key file names for the two CAs.
  CURRENT_DIR=$PWD
  cd ../crypto-config/peerOrganizations/org3.example.com/ca/
  PRIV_KEY=$(ls *_sk)
  cd "$CURRENT_DIR"
  sed $OPTS "s/CA3_PRIVATE_KEY/${PRIV_KEY}/g" ../docker-compose-org3.yaml
  # If MacOSX, remove the temporary backup of the docker-compose file
  if [ "$ARCH" == "Darwin" ]; then
    rm docker-compose-org3.yamlt
  fi
}
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
  echo "### Generating channel configuration transaction 'channel.tx' ###"
  echo "#################################################################"
  configtxgen -profile TwoOrgsChannel -outputCreateChannelTx newchannel.tx -channelID $CHANNEL_NAME
  if [ "$?" -ne 0 ]; then
    echo "Failed to generate channel configuration transaction..."
    exit 1
  fi
  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org3MSP   ##########"
  echo "#################################################################"
  configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./Org3MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org3MSP
  configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ../channel-artifacts/Org3MSPanchors.tx -channelID "mychannel" -asOrg Org3MSP
  if [ "$?" -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org3MSP..."
    exit 1
  fi
  echo

}
generateCerts
replacePrivateKey
generateChannelArtifacts
curl -X POST --data-binary @genesis_org3.block http://127.0.0.1:7059/protolator/decode/common.Block > genesis_org3.json
jq .data.data[0].payload.data.config genesis_org3.json >genesis_new.json
