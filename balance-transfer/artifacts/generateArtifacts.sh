#generate artifacts based on fabric v1.0.0

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
  cp docker-compose-template.yaml docker-compose.yaml

  # The next steps will replace the template's contents with the
  # actual values of the private key file names for the two CAs.
  CURRENT_DIR=$PWD

  cd channel/crypto-config/peerOrganizations/org1.example.com/ca/
  PRIV_KEY=$(ls *_sk)
  cd $CURRENT_DIR
  sed $OPTS "s/CA1_PRIVATE_KEY/${PRIV_KEY}/g" docker-compose.yaml

  cd channel/crypto-config/peerOrganizations/org2.example.com/ca/
  PRIV_KEY=$(ls *_sk)
  cd $CURRENT_DIR
  sed $OPTS "s/CA2_PRIVATE_KEY/${PRIV_KEY}/g" docker-compose.yaml


  # cd channel/crypto-config/peerOrganizations/org3.example.com/ca/
  # PRIV_KEY=$(ls *_sk)
  # cd $CURRENT_DIR
  # sed $OPTS "s/CA3_PRIVATE_KEY/${PRIV_KEY}/g" docker-compose.yaml
  #
  #
  # cd crypto-config/peerOrganizations/org4.example.com/ca/
  # PRIV_KEY=$(ls *_sk)
  # cd $CURRENT_DIR
  # sed $OPTS "s/CA4_PRIVATE_KEY/${PRIV_KEY}/g" docker-compose.yaml

  # If MacOSX, remove the temporary backup of the docker-compose file
  if [ "$ARCH" == "Darwin" ]; then
    rm docker-compose.yamlt
  fi
}

function generateCerts (){
  CURRENT_DIR=$PWD
  cd channel/
  if [ -d './crypto-config' ];then
		sudo rm -r crypto-config/
	fi
	CRYPTOGEN=../../../bin/cryptogen
	if [ -f "$CRYPTOGEN" ]; then
            echo "Using cryptogen -> $CRYPTOGEN"
	else
	    echo "No cryptogen"
	    #make -C $FABRIC_ROOT release-all
	fi
  echo
  echo "##########################################################"
  echo "##### Generate certificates using cryptogen tool #########"
  echo "##########################################################"

  $CRYPTOGEN generate --config=../cryptogen.yaml
  if [ "$?" -ne 0 ]; then
    echo "Failed to generate certificates..."
    exit 1
  fi
  cd $CURRENT_DIR
  echo
}

export FABRIC_CFG_PATH=${PWD}
function generateChannelArtifacts() {
  if [ -d './channel' ];then
    rm -rf channel/*.block channel/*.tx
	fi
	CONFIGTXGEN=../../bin/configtxgen
	if [ -f "$CONFIGTXGEN" ]; then
            echo "Using configtxgen -> $CONFIGTXGEN"
	else
	    echo "No configtxgen"
	    #make -C $FABRIC_ROOT release-all
	fi

  echo "##########################################################"
  echo "#########  Generating Orderer Genesis block ##############"
  echo "##########################################################"
  # Note: For some unknown reason (at least for now) the block file can't be
  # named orderer.genesis.block or the orderer will fail to launch!
  $CONFIGTXGEN -profile TwoOrgsOrdererGenesis -outputBlock ./channel/genesis.block
  if [ "$?" -ne 0 ]; then
    echo "Failed to generate orderer genesis block..."
    exit 1
  fi
  echo
  echo "#################################################################"
  echo "### Generating channel configuration transaction 'mychannel.tx' ###"
  echo "#################################################################"
  $CONFIGTXGEN -profile TwoOrgsChannel -outputCreateChannelTx ./channel/mychannel.tx -channelID $CHANNEL_NAME
  if [ "$?" -ne 0 ]; then
    echo "Failed to generate channel configuration transaction..."
    exit 1
  fi

  echo
  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org1MSP   ##########"
  echo "#################################################################"
  $CONFIGTXGEN -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel/Org1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org1MSP
  if [ "$?" -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org1MSP..."
    exit 1
  fi

  echo
  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org2MSP   ##########"
  echo "#################################################################"
  $CONFIGTXGEN -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel/Org2MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org2MSP
  if [ "$?" -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org2MSP..."
    exit 1
  fi

  # echo
  # echo "#################################################################"
  # echo "#######    Generating anchor peer update for Org3MSP   ##########"
  # echo "#################################################################"
  # $CONFIGTXGEN -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel/Org3MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org3MSP
  # if [ "$?" -ne 0 ]; then
  #   echo "Failed to generate anchor peer update for Org3MSP..."
  #   exit 1
  # fi
  echo
}

CHANNEL_NAME=$1
: ${CHANNEL_NAME:="mychannel"}
echo $CHANNEL_NAME

generateCerts
replacePrivateKey
generateChannelArtifacts
sudo sync
