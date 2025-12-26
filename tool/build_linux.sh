if [ "$1" = "x64" ]; then
  rustup target add target x86_64-unknown-linux-gnu
  cargo build --target x86_64-unknown-linux-gnu --features sqlcipher-vendored --release
  mv "target/x86_64-unknown-linux-gnu/release/libisar.so" "libisar_linux_x64.so"
else
  rustup target add aarch64-unknown-linux-gnu
  # 构建（使用环境变量）
  export RUSTFLAGS="-C linker=aarch64-linux-gnu-gcc"
  # 安装 nightly
  rustup install nightly
  # 设置为项目默认（在项目目录中）
  # rustup override set nightly
  # 或者只为当前命令使用 nightly
  cargo +nightly build --target aarch64-unknown-linux-gnu --features sqlcipher-vendored --release
  mv "target/aarch64-unknown-linux-gnu/release/libisar.so" "libisar_linux_arm64.so"
fi