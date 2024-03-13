# Sử dụng image Ubuntu 20.04
FROM ubuntu:20.04

# Cài đặt các gói cần thiết
RUN apt-get update && apt-get install -y \
    git \
    wget \
    unzip \
    xz-utils \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Thiết lập biến môi trường cho Flutter
ENV PATH="/flutter/bin:${PATH}"

# Tải và cài đặt Flutter SDK
RUN wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.19.3-stable.tar.xz \
    && tar xf flutter_linux_3.19.3-stable.tar.xz \
    && rm flutter_linux_3.19.3-stable.tar.xz

# Sao chép mã nguồn vào container
COPY . /app

# Thiết lập thư mục làm việc
WORKDIR /app




