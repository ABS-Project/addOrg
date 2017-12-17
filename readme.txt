1.先执行bash.sh脚本下载镜像文件
2.进入test-balance-trance-transfer/first-network/目录,根据该目录下README.md文件中的内容，修改ca镜像并保存
3.进入test-balance-trance-transfer/first-network/目录，执行./byfn -m generate命令生成org1、org2的证书、创世区块以及channel.tx,
  其中证书位于crypto-config/目录中，创世区块在channel-artifacts目录中，docker-compose-e2e.yaml文件中的CA_PRIVATE_KEY被替换
4.打开一个端口，进入bin文件夹，执行./configtxlator start,该工具启动一个服务，提供后续区块文件和json文件的转换服务
5.进入test-balance-trance-transfer/first-network/org3-artifacts/,执行./create.sh,该命令会生成org3的证书文件并将其复制到
  ../crypto-config/peerOrganizations/目录中，同时替换docker-compose-org3.yaml文件CA_PRIVATE_KEY，并生成包含Org3MSP的genesis_org3.block
  经过转换得到genesis_org3.json文件。
6.准备工作完成，进入test-balance-trance-transfer/，执行./runApp.sh命令，该脚本会启动docker-compose-e2e.yaml,docker-compose-org3.yaml
  即启动orderer，org1、org2和org3的相关节点，另外启动了一个cli容器便于后续操作，并启动node-sdk服务。
7.打开新终端，进入test-balance-trance-transfer/，在新终端里执行./testAPIs.sh,等待执行完毕。该脚本是创建mychannel，将org1、org2的组织节点加入
  mychannel通道，安装src中的链码并实例化，并进行了invoke和query操作。
8.下面开始将组织org3的节点加入mychannel。由于一开始配置的orderer创世区块中不包含org3的证书内容，所以我们要
（1）首先将org3的MSP内容加入系统通道的配置中，
（2）然后将org3的MSP内容加入mychannel的配置中，便可以将org3加入mychannel通道。
（3）但是之前实例化账本时不包含Org3MSP,因此要升级所有节点的链码，重新实例化。
 新版本链码实例化完成后org3的节点便可以像org1,org2一样对链码进行操作，即动态加入新组织完成。下面将对上述3步进行更详细的操作详解。

8.1 将org3的MSP内容加入系统通道的配置中，主要参考test-balance-trance-transfer/first-network/channel-artifacts目录中transfer-sys.md。
8.2 将org3的MSP内容加入mychannel的配置中，主要参考test-balance-trance-transfer/first-network/channel-artifacts目录中transfer-mychannel.md。
8.3 执行./addorg3.sh,该脚本将org3加入mychannel通道，并在org1、org2、org3上面安装新版本的链码，注意账本名字mycc要和原先一致，版本号要不同
    然后参考chaincodeupgrade.md内容执行链码升级操作
8.4 最后执行updateChaincode.sh,该脚本是用来测试新加入的节点是否能正常工作。注意这里还有一次instantiate操作请求，但是会失败，但是必须要有，
    否则org2,org3无法对链码操作，可能这一步能够同步一下账本。
