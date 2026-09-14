# RTL-SDR Visual Control Center

A desktop control panel for sharing one RTL-SDR dongle between:

- ADS-B aircraft tracking with a tar1090 map
- ACARS message reception with ACARS Hub
- SatDump live satellite reception and image decoding
- GPredict satellite maps, footprints and pass predictions
- Gqrx or other SDR applications when all modes are stopped

Starting a receiver mode releases the dongle from the previous mode. The ADS-B
map also adds a **Flightradar24** button to the selected aircraft panel.

## Screens and ports

| Mode | Interface | Default address |
|---|---|---|
| ADS-B | tar1090 aircraft map | <http://127.0.0.1:8090> |
| ACARS | ACARS Hub message dashboard | <http://127.0.0.1:8081> |
| Satellite reception | SatDump desktop GUI | application window |
| Satellite prediction | GPredict desktop GUI | application window |

Ports, station coordinates, callsign, RTL-SDR serial and ACARS frequencies are
all configurable in `.env`.

## Requirements

- Linux desktop with Bash and Zenity
- Docker Engine or Docker Desktop with Compose
- RTL-SDR drivers and development files (`rtl-sdr`, `librtlsdr-dev`)
- Git, CMake, Make, a C/C++ compiler and libusb development files
- Optional but recommended: SatDump and GPredict

Example package names:

```bash
# Arch/CachyOS (SatDump may be obtained from the AUR)
sudo pacman -S --needed base-devel cmake git libusb rtl-sdr zlib zstd ncurses \
  libsndfile zenity docker docker-compose gpredict
yay -S satdump

# Debian/Ubuntu essentials
sudo apt install git build-essential cmake pkg-config libusb-1.0-0-dev \
  librtlsdr-dev zlib1g-dev libzstd-dev libncurses-dev libsndfile1-dev \
  rtl-sdr zenity docker.io docker-compose-plugin gpredict
```

For SatDump installation alternatives, use the project's official instructions:
<https://docs.satdump.org/>.

## Quick installation

```bash
git clone https://github.com/acarist/rtl-sdr-visual-control-center.git
cd rtl-sdr-visual-control-center
./install.sh
```

Then edit:

```bash
nano ~/.local/share/rtl-sdr-visual-control-center/.env
```

At minimum set your callsign/name, location and dongle serial:

```dotenv
CALLSIGN=N0CALL
RTL_SERIAL=00000001
LAT=41.0082
LON=28.9784
ALT=0m
```

Find the RTL-SDR serial with:

```bash
rtl_test -t
```

Open **RTL-SDR Görsel Kontrol Merkezi** from the desktop application menu.

## Using the modes

### ADS-B aircraft map

Use a 1090 MHz antenna, choose **ADS-B Harita**, then open the local map. Click
an aircraft to see its details and the red **Flightradar24'te Aç** button.

### ACARS

Use a VHF air-band antenna and choose **ACARS Mesajları**. The defaults monitor
131.525, 131.725 and 131.825 MHz. Availability varies by region.

### Satellites

Choose **Uydu Merkezi** to open GPredict and SatDump together. In GPredict set
your ground station and update orbital elements. In SatDump use a Recorder,
select the RTL-SDR source, select the appropriate satellite pipeline and start
live processing.

Common receive-only targets include Meteor LRPT, amateur satellites, ISS
transmissions and supported CubeSat telemetry. The NOAA-15/18/19 POES fleet was
decommissioned in 2025, so old NOAA APT tutorials are now useful mainly for
processing archived recordings. Use an
antenna designed for the relevant band; a V-dipole or QFH is common for 137 MHz.

### First Meteor image: beginner click path

1. In GPredict select your ground station and update TLE data from the network.
2. Add METEOR-M N2-3 and N2-4 to a module, then check the next high-elevation pass.
3. In SatDump choose **Add > Recorder** and select the RTL-SDR device.
4. Use roughly 1.024 MS/s, tune to the downlink shown for that pass, and start the SDR.
5. Select **METEOR M2-x LRPT 72k** as the live processing pipeline.
6. Choose an output directory and start processing shortly before acquisition of signal.
7. Watch the constellation/synchronization indicators; decoded products appear in
   SatDump's viewer after enough valid data is received.

## Troubleshooting

- **Device busy:** choose **Tümünü Durdur**, then retry. Close other SDR apps.
- **No aircraft:** verify the 1090 MHz antenna, cable and clear view of the sky.
- **Map port occupied:** change `ADSB_PORT` in `.env`.
- **No ACARS:** check regional frequencies and use a VHF antenna.
- **No satellite signal:** verify the pass elevation, frequency, Doppler shift,
  antenna orientation and SatDump pipeline.
- Logs are stored under `~/.local/share/rtl-sdr-visual-control-center/run/`.

## Privacy and legality

This project is receive-only. Radio regulations and permitted uses vary by
country. Do not rebroadcast private or sensitive messages; follow local law.

## Upstream projects

- [readsb](https://github.com/wiedehopf/readsb)
- [tar1090](https://github.com/wiedehopf/tar1090)
- [ADS-B Ultrafeeder](https://github.com/sdr-enthusiasts/docker-adsb-ultrafeeder)
- [acarsdec](https://github.com/TLeconte/acarsdec)
- [ACARS Hub](https://github.com/sdr-enthusiasts/docker-acarshub)
- [SatDump](https://github.com/SatDump/SatDump)
- [GPredict](https://github.com/csete/gpredict)

## License

MIT. Upstream applications and container images retain their own licenses.
