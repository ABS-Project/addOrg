######1######
在在test-balance-trance-transfer/first-network/channel-artifacts目录下执行目录下执行：

curl -X POST --data-binary @mychannel_config_block.pb http://127.0.0.1:7059/protolator/decode/common.Block > mychannel_config_block.json
jq .data.data[0].payload.data.config mychannel_config_block.json > mychannel_config.json
#
手动复制mychannel_config.json文件并命名为mychannel_update_config.json
将test-balance-trance-transfer/first-network/channel-artifacts/genesis_org3.json中Org3MSP的内容追加到mychannel_update_config.json

#执行下面的命令，主要是生成加入Org3MSP前后的差分文件
curl -X POST --data-binary @mychannel_config.json http://127.0.0.1:7059/protolator/encode/common.Config > mychannel_config.pb
curl -X POST --data-binary @mychannel_update_config.json http://127.0.0.1:7059/protolator/encode/common.Config > mychannel_update_config.pb
curl -X POST -F original=@mychannel_config.pb -F updated=@mychannel_update_config.pb http://127.0.0.1:7059/configtxlator/compute/update-from-configs -F channel=mychannel > mychannel_config_update.pb
curl -X POST --data-binary @mychannel_config_update.pb http://127.0.0.1:7059/protolator/decode/common.ConfigUpdate > mychannel_config_update.json
echo '{"payload":{"header":{"channel_header":{"channel_id":"mychannel", "type":2}},"data":{"config_update":'$(cat mychannel_config_update.json)'}}}' > mychannel_config_update_in_envelope.json
curl -X POST --data-binary @mychannel_config_update_in_envelope.json http://127.0.0.1:7059/protolator/encode/common.Envelope > mychannel_config_update_in_envelope.pb


# 然后手动将mychannel_config_update_in_envelope.pb复制到../app/路径中，这是因为需要使用node-sdk收集org1、org2、orderer的对配置更新mychannel_config_update_in_envelope.pb的签名。
