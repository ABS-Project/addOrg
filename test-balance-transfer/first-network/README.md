## Build Your First Network (BYFN)
这里因为涉及到org3,所有启动CA的配置文件fabric-ca-server-config.yaml必须修改，
为了方便，我们采用的方法是将本地的fabric-ca-server-config.yaml修改后复制到ca镜像hyperledger/fabric-ca的相应目录下，操作如下：
###### bash
sudo docker run -t -i hyperledger/fabric-ca:latest /bin/bash  #启动ca镜像，得到容器id，然后退出容器
docker cp fabric-ca-server-config.yaml c49b088cb3b6:/etc/hyperledger/fabric-ca-server/  #将本地文件复制到容器相应位置，注意容器id要与上面一致
sudo docker commit -m "add fabric-ca-server-config.yaml" -a "Docker Newbee" c49b088cb3b6 hyperledger/fabric-ca:v1  #其中，-m 来指定提交的说明信息，跟我们使用的版本控制工具一样；-a 可以指定更新的用户信息；之后是用来创建镜像的容器的 ID；最后指定目标镜像的仓库名和 tag 信息。创建成功后会返回这个镜像的 ID 信息
######

这里我的tag为v1，和我的docker-compose中的文件一致。
在docker-compose.yaml文件中启动ca时注意指定文件
#####
command: sh -c 'fabric-ca-server start --config /etc/hyperledger/fabric-ca-server/fabric-ca-server-config.yaml --ca.certfile /etc/hyperledger/fabric-ca-server-config/ca.org3.example.com-cert.pem --ca.keyfile /etc/hyperledger/fabric-ca-server-config/CA3_PRIVATE_KEY -b admin:adminpw -d'
#####
