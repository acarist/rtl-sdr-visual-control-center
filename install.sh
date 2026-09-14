#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
install_dir="${XDG_DATA_HOME:-$HOME/.local/share}/rtl-sdr-visual-control-center"
desktop_dir="${XDG_DATA_HOME:-$HOME/.local/share}/applications"

for cmd in git cmake make docker zenity rtl_test; do
    command -v "$cmd" >/dev/null || { echo "Eksik komut: $cmd" >&2; exit 1; }
done

mkdir -p "$install_dir" "$install_dir/runtime/bin" "$install_dir/runtime/src" \
    "$install_dir/data/adsb" "$install_dir/data/acars" "$install_dir/run" "$desktop_dir"
cp "$repo_dir/compose.yaml" "$install_dir/compose.yaml"
cp "$repo_dir/bin/sdr-control" "$install_dir/runtime/sdr-control.tmp"
mkdir -p "$install_dir/bin"
mv "$install_dir/runtime/sdr-control.tmp" "$install_dir/bin/sdr-control"
chmod +x "$install_dir/bin/sdr-control"

if [[ ! -f "$install_dir/.env" ]]; then cp "$repo_dir/.env.example" "$install_dir/.env"; fi

if [[ ! -d "$install_dir/runtime/tar1090/.git" ]]; then
    git clone --depth 1 https://github.com/wiedehopf/tar1090.git "$install_dir/runtime/tar1090"
    git -C "$install_dir/runtime/tar1090" apply "$repo_dir/patches/tar1090-fr24.patch"
fi

if [[ ! -x "$install_dir/runtime/bin/readsb" ]]; then
    git clone --depth 1 https://github.com/wiedehopf/readsb.git "$install_dir/runtime/src/readsb"
    make -C "$install_dir/runtime/src/readsb" -j"$(nproc)" RTLSDR=yes
    install -m 0755 "$install_dir/runtime/src/readsb/readsb" "$install_dir/runtime/bin/readsb"
fi

if [[ ! -x "$install_dir/runtime/bin/acarsdec" ]]; then
    git clone --depth 1 https://github.com/TLeconte/acarsdec.git "$install_dir/runtime/src/acarsdec"
    cmake -S "$install_dir/runtime/src/acarsdec" -B "$install_dir/runtime/src/acarsdec/build" \
        -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -Drtl=ON -DCMAKE_BUILD_TYPE=Release
    cmake --build "$install_dir/runtime/src/acarsdec/build" -j"$(nproc)"
    install -m 0755 "$install_dir/runtime/src/acarsdec/build/acarsdec" "$install_dir/runtime/bin/acarsdec"
fi

sed "s|@INSTALL_DIR@|$install_dir|g" "$repo_dir/desktop/rtl-sdr-control.desktop.in" \
    >"$desktop_dir/rtl-sdr-control.desktop"
chmod +x "$desktop_dir/rtl-sdr-control.desktop"
command -v update-desktop-database >/dev/null && update-desktop-database "$desktop_dir" || true

docker compose --project-directory "$install_dir" --env-file "$install_dir/.env" \
    -f "$install_dir/compose.yaml" pull

echo
echo "Kurulum tamamlandı. Önce şu dosyayı düzenleyin: $install_dir/.env"
echo "Ardından uygulama menüsünden 'RTL-SDR Görsel Kontrol Merkezi'ni açın."
