var util = require('util');
var path = require('path');
var fs = require('fs');

var Peer = require('fabric-client/lib/Peer.js');
var EventHub = require('fabric-client/lib/EventHub.js');
var tx_id = null;
var nonce = null;
var config = require('../config.json');
var helper = require('./helper.js');
var logger = helper.getLogger('Join-Channel');
//helper.hfc.addConfigFile(path.join(__dirname, 'network-config.json'));
var ORGS = helper.ORGS;
var allEventhubs = [];


var signatures = [];
//读取增量pb文件
var config_proto = fs.readFileSync(path.join(__dirname, 'mychannel_config_update.pb'));

return Client.newDefaultKeyValueStore({
        path: 'kvs_' + org
    }).then((store) => {
        client.setStateStore(store);
        client._userContext = null;
        return getPeerAdmin(client, 'org1');
    }).then((admin) => {
        logger.info('Successfully enrolled user \'admin\' for org1');
        the_user = admin;
        //org1对config_proto进行签名
        var signature = client.signChannelConfig(config_proto);
        logger.info('Successfully signed config update by org1');
        signatures.push(signature);
        client._userContext = null;
        return getPeerAdmin(client, 'org2');
    }).then((admin) => {
        logger.info('Successfully enrolled user \'admin\' for org2');
        the_user = admin;
        //org2对config_proto进行签名
        var signature = client.signChannelConfig(config_proto);
        logger.info('Successfully signed config update by org2');
        signatures.push(signature);
        client._userContext = null;
        return getOrdererAdmin(client);
    }).then((admin) => {
        logger.info('Successfully enrolled user \'admin\' for orderer');
        the_user = admin;
        //orderer对config_proto进行签名
        var signature = client.signChannelConfig(config_proto);
        logger.info('Successfully signed config update by org2');
        signatures.push(signature);
        let tx_id = client.newTransactionID();
        request = {
            config: config_proto,
            signatures : signatures,
            name : channelName,
            orderer : orderer,
            txId  : tx_id
        };
        //更新通道
        return client.updateChannel(request);
    }).then((result) => {
        if(result.status && result.status === 'SUCCESS') {
            logger.info('Successfully updated the channel.');
            return sleep(5000);
        } else {
            logger.error('Failed to update the channel. ');
            Promise.reject('Failed to update the channel');
        }
    }).then((nothing) => {
        logger.info('Successfully waited to make sure new channel was updated.');
