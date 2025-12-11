# Valkey Multi-Architecture Builds

Automated multi-architecture builds of [Valkey](https://github.com/valkey-io/valkey) for various platforms.

## Supported Architectures

- **x86_64** (amd64) - Intel/AMD 64-bit
- **aarch64** (arm64) - ARM 64-bit
- **ppc64le** - PowerPC 64-bit Little Endian
- **s390x** - IBM System z
- **riscv64** - RISC-V 64-bit

## Docker Usage

```bash
# Pull the latest version
docker pull ghcr.io/calagopus-rs/valkey:latest

# Run Valkey
docker run -d -p 6379:6379 ghcr.io/calagopus-rs/valkey:latest
```

## Binary Usage

Download pre-built binaries from the [releases page](https://github.com/calagopus-rs/valkey/releases).

### Available Binaries

Each release includes the following binaries for each architecture:

- `valkey-server-{arch}-linux` - Valkey server
- `valkey-cli-{arch}-linux` - Command-line client
- `valkey-benchmark-{arch}-linux` - Benchmarking tool
- `valkey-check-aof-{arch}-linux` - AOF file checker
- `valkey-check-rdb-{arch}-linux` - RDB file checker

## Build Schedule

- Automatic builds run every Sunday at 00:00 UTC
- Manual builds can be triggered via GitHub Actions
- Versions track upstream [valkey-io/valkey](https://github.com/valkey-io/valkey) releases

## Architecture Mapping

| Docker Platform | Binary Name | Common Name |
|----------------|-------------|-------------|
| linux/amd64    | x86_64      | Intel/AMD   |
| linux/arm64    | aarch64     | ARM 64-bit  |
| linux/ppc64le  | ppc64le     | PowerPC     |
| linux/s390x    | s390x       | IBM Z       |
| linux/riscv64  | riscv64     | RISC-V      |

## Contributing

Issues and pull requests are welcome. This repository primarily automates building upstream [valkey-io/valkey](https://github.com/valkey-io/valkey).
