#!/bin/bash

# スクリプトの親ディレクトリパスを自動取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/../credential/vpn_env"
OVPN_FILE="$SCRIPT_DIR/../credential/client.ovpn"

# ==========================================
# 1. 認証情報の読み込み
# ==========================================
if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
else
    echo "エラー: 認証ファイル ($ENV_FILE) が見つかりません。"
    exit 1
fi

# 一時的な認証ファイルのパス
AUTH_FILE="/tmp/vpn_auth_$$.txt"
trap "rm -f $AUTH_FILE" EXIT

# ==========================================
# 2. OTPの生成とタイミング調整
# ==========================================
NOW=$(date +%s)
REMAINING=$((30 - NOW % 30))

if [ "$REMAINING" -le 5 ]; then
    echo "OTPの有効期限が近いため（残り${REMAINING}秒）、新しいパスワードの発行を待機しています..."
    sleep 6
fi

# vpn_envから読み込んだ VPN_SECRET を使用
OTP=$(oathtool --totp -b "$VPN_SECRET")

if [ -z "$OTP" ]; then
    echo "エラー: OTPの生成に失敗しました。"
    exit 1
fi

# ==========================================
# 3. 認証ファイルの作成
# ==========================================
# vpn_envから読み込んだ VPN_USER と VPN_PASS を使用
echo "$VPN_USER" > "$AUTH_FILE"
echo "${VPN_PASS}${OTP}" >> "$AUTH_FILE"

# ==========================================
# 4. OpenVPNの実行
# ==========================================
echo "OTP ($OTP) を使用してVPNに接続しています..."
sudo $(brew --prefix openvpn)/sbin/openvpn --config "$OVPN_FILE" --auth-user-pass "$AUTH_FILE"