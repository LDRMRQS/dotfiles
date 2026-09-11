#!/usr/bin/env bash
# system/ufw-rules.sh — arquivo de REFERÊNCIA (doc 06: domínio system/), executado pelo
# bootstrap.sh com sudo depois de instalar o `ufw` (doc 04). Não é um serviço nem um hook —
# roda uma vez pra deixar as regras no estado esperado; rodar de novo é seguro (idempotente,
# `ufw allow`/`ufw default` não duplicam regra igual).
set -euo pipefail

# Política padrão (doc 04): bloqueia tudo que chega, libera tudo que sai — notebook que não
# expõe nenhum serviço pra rede.
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Não bloquear o tráfego da rede virtual do libvirt (virbr0) — a VM Windows (doc 01) depende da
# NAT padrão do libvirt (dnsmasq/iptables-nft, doc 02) pra ter rede e pro virtiofs/SPICE
# funcionarem; sem essa liberação o ufw pode brigar com as regras que o próprio libvirt gerencia.
sudo ufw allow in on virbr0
sudo ufw allow out on virbr0

# Nenhuma porta de entrada liberada por padrão (nem SSH — o notebook não é acessado remotamente
# hoje). Se algum dia precisar (ex: SSH de outro dispositivo na mesma rede local), adicionar aqui
# explicitamente em vez de abrir tudo:
#   sudo ufw allow 22/tcp comment 'SSH'

sudo ufw enable
sudo ufw status verbose
