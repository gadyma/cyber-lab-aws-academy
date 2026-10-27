# Attacker Kali web desktop, built on the public Kasm single-container Kali image.
# Adds a Kali tool metapackage and HexStrike AI so the student gets a browser
# desktop + CLI tools + the AI pentest MCP server in one container.
#
# Base image (KasmVNC web desktop on 6901) and the toolset are build args so the
# CloudFormation parameters flow through tools/lab-boot.sh.
ARG BASE_IMAGE=kasmweb/kali-rolling-desktop:1.16.0
FROM ${BASE_IMAGE}

ARG KALI_TOOLSET=kali-tools-top10
USER root
ENV DEBIAN_FRONTEND=noninteractive

# --- Kali tools + HexStrike dependencies ---------------------------------
# hexstrike-ai is packaged in Kali; fall back to the upstream repo if the
# package is unavailable at build time.
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      "${KALI_TOOLSET}" \
      python3 python3-pip python3-venv git curl jq \
 && ( apt-get install -y --no-install-recommends hexstrike-ai \
      || ( git clone --depth 1 https://github.com/0x4m4/hexstrike-ai.git /opt/hexstrike-ai \
           && python3 -m venv /opt/hexstrike-ai/venv \
           && /opt/hexstrike-ai/venv/bin/pip install --no-cache-dir -r /opt/hexstrike-ai/requirements.txt ) ) \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# --- Convenience launcher: `hexstrike-start` ------------------------------
# Starts the HexStrike API server (port 8888) and prints the MCP wiring hint.
COPY hexstrike-start.sh /usr/local/bin/hexstrike-start
COPY custom_startup.sh /dockerstartup/custom_startup.sh
RUN chmod +x /usr/local/bin/hexstrike-start /dockerstartup/custom_startup.sh

# Passwordless sudo for the desktop user (standard for a Kali workstation, and
# the Kasm base does not set a known sudo password). Kept last so the heavy
# toolset layer above stays cached on rebuilds.
RUN apt-get update \
 && apt-get install -y --no-install-recommends sudo \
 && echo 'kasm-user ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/kasm-user \
 && chmod 440 /etc/sudoers.d/kasm-user \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Kasm images drop back to the desktop user via their own entrypoint.
USER 1000
