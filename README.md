# Run bk-ci via docker composer
温馨提示：本教程不包含任何高可用部署，仅供本地开发、调试使用

- 请不要将本方案应用到生产环境！
- 请不要将本方案应用到生产环境！！
- 请不要将本方案应用到生产环境！！！


## Prepare Job
- 一台已安装docker的服务器（至少8核16G）

## 操作步骤
- 准备环境（只运行一次）
```shell
# 设置工作目录
mkdir -p /data/docker/
cd /data/docker
git clone https://github.com/zanyzhao/bkci-server.git bkci
```

- 下载并运行最新版的bkci release包（可重复运行）
```shell
cd /data/docker/bkci || exit 1
LATEST_TAG=v1.0.0 #LATEST_TAG为bk-ci的最新Release
wget https://github.com/Tencent/bk-ci/releases/download/$LATEST_TAG/bkci.tar.gz -O bkci.tar.gz
tar xzvf bkci.tar.gz
mv bkci ci
./init.sh
```
> LATEST_TAG请使用GitHub Release上的最新版本哈

- 在本地配置hosts，以macOS为例
```shell
sudo echo "${SERVER_IP} my-dev.ci.com" >> /etc/hosts
```

- 本地浏览器访问 http://my-dev.ci.com
