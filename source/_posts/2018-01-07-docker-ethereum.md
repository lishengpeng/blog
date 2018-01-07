---
title: 基于Docker的Ethereum 开发环境搭建
date:  2018-01-07 21:16:20
---

## 背景
最近在研究区块链相关的东西，作为一个程序员，当然想自己动手尝试一下。最后决定选择搭建一个Ethereum的开发环境，试着开发一下智能合约。
折腾了两天，觉得搭建一个开发环境依赖太多的东西，这样对一个刚入门的新手来说不够友好，所以最后决定使用Docker来搭建开发环境，部署起来也方便，而且不过分依赖本机的环境。
本文主要将了使用docker搭建起geth的集群，然后使用remix做为IDE来开发和调试合约。

## docker环境准备
如果没有安装的，可以在docker的[官网](https://docs.docker.com/)安装下载，现在mac，windows都有桌面版，各个linux的发型版都也都有说明，这里就不细说了。

安装完之后，执行`docker -v`就可以查看docker的版本号了：
```
➜  ~ docker -v
Docker version 17.09.0-ce, build afdb6d4
```

## go-eth集群搭建

在github的[Capgemini-AIE/ethereum-docker](https://github.com/yutianwu/ethereum-docker)这个repo下有搭建geth集群的docker编排文件。细节有兴趣的回过头来可以详细了解一下。

### clone代码
```
➜  eth git clone https://github.com/yutianwu/ethereum-docker
Cloning into 'ethereum-docker'...
remote: Counting objects: 115, done.
remote: Total 115 (delta 0), reused 0 (delta 0), pack-reused 115
Receiving objects: 100% (115/115), 20.97 KiB | 0 bytes/s, done.
Resolving deltas: 100% (44/44), done.
Checking connectivity... done.
```
### 使用单机模式启动

用`docker-compose`使用`docker-compose-standalone.yml`在单机模式下启动，也就是启动一个docker容器。
```
➜  ethereum-docker git:(master) docker-compose -f docker-compose-standalone.yml up -d
Creating ethereumdocker_geth_1 ...
Creating ethereumdocker_geth_1 ... done
➜  ethereum-docker git:(master) docker ps
CONTAINER ID        IMAGE                COMMAND                  CREATED                  STATUS              PORTS                                                                                  NAMES
2b87b5a814ce        ethereum/client-go   "geth --datadir=/r..."   Less than a second ago   Up 4 seconds        0.0.0.0:8545->8545/tcp, 0.0.0.0:30303->30303/tcp, 8546/tcp, 0.0.0.0:30303->30303/udp   ethereumdocker_geth_1
```
使用`docker exec`进入容器：
```
➜  ethereum-docker git:(master) docker exec -it ethereumdocker_geth_1 geth attach ipc://root/.ethereum/devchain/geth.ipc
Welcome to the Geth JavaScript console!

instance: Geth/v1.7.3-unstable/linux-amd64/go1.9.2
coinbase: 0x007ccffb7916f37f7aeef05e8096ecfbe55afc2f
at block: 0 (Thu, 01 Jan 1970 00:00:00 UTC)
 datadir: /root/.ethereum/devchain
 modules: admin:1.0 debug:1.0 eth:1.0 miner:1.0 net:1.0 personal:1.0 rpc:1.0 txpool:1.0 web3:1.0

>
```
到这里ethereum的client已经运行起来啦。

### 使用集群模式启动

```
➜  ethereum-docker git:(master) docker-compose up -d
Creating netstats ...
Creating netstats ... done
Creating bootstrap ...
Creating bootstrap ... done
Creating ethereumdocker_eth_1 ...
Creating ethereumdocker_eth_1 ... done
➜  ethereum-docker git:(master) docker ps
CONTAINER ID        IMAGE                      COMMAND                  CREATED                  STATUS              PORTS                                                                                  NAMES
a345f0f315d1        ethereumdocker_eth         "/root/start.sh --..."   Less than a second ago   Up 7 seconds        8545-8546/tcp, 30303/tcp, 30303/udp                                                    ethereumdocker_eth_1
c852e32758e1        ethereumdocker_bootstrap   "/root/start.sh --..."   Less than a second ago   Up 8 seconds        0.0.0.0:8545->8545/tcp, 0.0.0.0:30303->30303/tcp, 8546/tcp, 0.0.0.0:30303->30303/udp   bootstrap
aa4712bd960b        ethereumdocker_netstats    "npm start"              Less than a second ago   Up 9 seconds        0.0.0.0:3000->3000/tcp                                                                 netstats
```
由于之前我已经下载过镜像了，所以容器就直接启动了，如果首次启动容器的话，会先拉取基础镜像，然后构建好环境才能启动，需要等一会。不过最后你会看到启动了3个容器，分别是两个go-eth的容器和netstats的容器。
容器启动之后，我们可以打开`http://localhost:3000`来查看各个go-eth的状态。
![](/img/ehereum_1.png)
这个时候只是还没有挖矿的节点，也就不会生成区块，虽然创世区块已经准备好啦，但是还是需要手动进入容器启动节点开始挖矿。

```
➜  ethereum-docker git:(master) docker exec -it ethereumdocker_eth_1 /bin/bash
bash-4.3# geth attach ipc://root/.ethereum/devchain/geth.ipc
Welcome to the Geth JavaScript console!

instance: Geth/v1.7.3-unstable/linux-amd64/go1.9.2
coinbase: 0x007ccffb7916f37f7aeef05e8096ecfbe55afc2f
at block: 0 (Thu, 01 Jan 1970 00:00:00 UTC)
 datadir: /root/.ethereum/devchain
 modules: admin:1.0 debug:1.0 eth:1.0 miner:1.0 net:1.0 personal:1.0 rpc:1.0 txpool:1.0 web3:1.0

> miner.start()
null
```
再打开netstats的监控界面，稍等一会，就可以看到矿工节点已经开始挖矿并不断生成新的区块啦。
![](/img/ehereum_2.png)

到这里，ethereum私链的集群已经搭建完毕，接下来就可以基于搭建的集群，搭建开发环境，部署我们的第一个合约啦。

### 搭建基于remix的开发环境
[remix](http://remix.ethereum.org/)是官方提供的IDE，可以在线调试，我们前期可以基于在线的Remix开始开发，熟悉之后，可以自己搭建remix或使用其他的开发工具。

![](/img/ehereum_3.png)
打开remix，默认的http协议为https,此时，**务必手动改为http**,因为使用https时连接不上geth。在Enviroment中选择`Web3 Provider`，最后就能够连上刚搭建的geth的集群了。

![](/img/ehereum_4.png)
连上集群之后，我们可以使用启动集群的时候创世区块的几个账号，里面各有一些ether。我们可以使用以下接口查看都有哪些账号：
```
> web3.eth.accounts
[
  "0x007ccffb7916f37f7aeef05e8096ecfbe55afc2f",
  "0x99429f64cf4d5837620dcc293c1a537d58729b68",
  "0xca247d7425a29c6645fa991f9151f994a830882d",
  "0x794f74c8916310d6a0009bb8a43a5acab59a58ad",
  "0x276ecb88715a503b00d1f15af4c17dc051991667",
  "0x83042c0147acce98e35ed9ef52e6dfc5c67ef92e",
  "0x8ab7114ba0f7ca706af69f799588766c8426aa24",
  "0x932d9e95e5d2cac02eebbe6763ab2c7b0a9d6a2f",
  "0x893c3f80d2a0375b3f00f856cf8a6775e4efc26a",
  "0xb1d3073bcc45462a3b0dfe69902cdd12971efec9"
]
```
然后解锁第一个账号，这样就可以使用该账号来部署合约了：
```
> web3.personal.unlockAccount("0x007ccffb7916f37f7aeef05e8096ecfbe55afc2f", "")
true
```
![](/img/ehereum_5.png)
接下来，我们将第一个账户，也就是`0x007ccffb7916f37f7aeef05e8096ecfbe55afc2f`填入`At Address`中，点击`Create`，稍等一会，我们就会看到合约的交易已经在下一个生成的区块,也就是`404`区块中了。

![](/img/ehereum_6.png)
部署好合约之后，在下面就会出现合约的接口，我们在`set`接口的参数中随便填一个数字，稍等一会，我们就会发现这次交易被包含到了`425`区块中了，查看详细信息，我们可以看到`storeData`已经变成了我们设置的值。

到此，我们的开发环境就算搭建好了。Have fun！
