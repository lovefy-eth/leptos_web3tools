# 使用 Debian Bullseye 作为基础镜像
FROM debian:bullseye

# 安装常用的构建工具和依赖包
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    build-essential \                    # 编译工具链
    autoconf automake autotools-dev libtool xutils-dev \  # 自动构建工具
    ca-certificates curl file && \       # SSL证书、网络工具、文件类型检测
    rm -rf /var/lib/apt/lists/*         # 清理apt缓存以减小镜像大小

# 安装 Rust 工具链，包括 WASM 目标平台
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
    sh -s -- --target wasm32-unknown-unknown -y

# 将 Rust 工具链添加到系统 PATH 环境变量
ENV PATH=/root/.cargo/bin:$PATH 

# 安装 cargo-binstall 工具，用于快速安装 Rust 二进制包，减少镜像大小
WORKDIR /root/.cargo/bin
RUN curl -L --output cargo-binstall.tgz https://github.com/cargo-bins/cargo-binstall/releases/download/v0.19.3/cargo-binstall-x86_64-unknown-linux-gnu.tgz && \
    tar -xvzf cargo-binstall.tgz && \   # 解压下载的文件
    chmod +x cargo-binstall && \        # 给可执行文件添加执行权限
    rm cargo-binstall.tgz               # 删除压缩包

# 注释掉的可选组件安装（rust-analyzer、rustfmt、rust-src、clippy）
#RUN rustup component add rust-analyzer rustfmt rust-src clippy

# 使用 cargo-binstall 安装 trunk 构建工具（指定版本 0.16.0）
RUN cargo binstall trunk@0.16.0 -y

# 设置工作目录为 /root
WORKDIR /root

# 将当前目录（构建上下文）的所有文件复制到容器内的当前工作目录
COPY . . 

# 暴露端口
EXPOSE $PORT
# 启动 trunk 开发服务器
CMD ["trunk", "serve"]

