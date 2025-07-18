# 使用 Debian Bullseye 作为基础镜像
FROM debian:bullseye

# 安装常用的构建工具和依赖包
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    build-essential \
    autoconf automake autotools-dev libtool xutils-dev \
    ca-certificates curl file && \
    rm -rf /var/lib/apt/lists/*

# 安装 Rust 工具链，包括 WASM 目标平台
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
    sh -s -- --target wasm32-unknown-unknown -y

# 将 Rust 工具链添加到系统 PATH 环境变量
ENV PATH=/root/.cargo/bin:$PATH 

# 安装 cargo-binstall 工具，用于快速安装 Rust 二进制包，减少镜像大小
WORKDIR /root/.cargo/bin
RUN curl -L --output cargo-binstall.tgz https://github.com/cargo-bins/cargo-binstall/releases/download/v0.19.3/cargo-binstall-x86_64-unknown-linux-gnu.tgz && \
    tar -xvzf cargo-binstall.tgz && \
    chmod +x cargo-binstall && \
    rm cargo-binstall.tgz

# 注释掉的可选组件安装（rust-analyzer、rustfmt、rust-src、clippy）
#RUN rustup component add rust-analyzer rustfmt rust-src clippy

# 使用 cargo-binstall 安装 trunk 构建工具（指定版本 0.16.0）
RUN cargo binstall trunk@0.16.0 -y

# 设置工作目录为 /app
WORKDIR /app

# 将当前目录（构建上下文）的所有文件复制到容器内的当前工作目录
COPY . . 

# 声明容器监听的端口（Railway 会自动设置 PORT 环境变量）
EXPOSE $PORT

# 启动 trunk 开发服务器，使用 Railway 提供的 PORT
CMD ["sh", "-c", "trunk serve --address 0.0.0.0 --port $PORT"]

