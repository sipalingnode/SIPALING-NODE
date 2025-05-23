<p align="center">
  <img height="300" height="auto" src="https://github.com/sipalingnode/sipalingnode/blob/main/logo.png">
</p>

<h2 align="center"><b>Community Team</b></h2>
<p align="center">
  <a href="https://www.airdropasc.com" target="_blank"><img src="https://github.com/sipalingnode/sipalingnode/blob/main/logo.png" width="50"/></a>&nbsp;&nbsp;&nbsp;
  <a href="https://t.me/airdropasc" target="_blank"><img src="https://github.com/user-attachments/assets/56e7f6ee-18b7-4b36-becc-ec6e4de7bff9" width="50"/></a>&nbsp;&nbsp;&nbsp;
  <a href="https://x.com/Autosultan_team" target="_blank"><img src="https://github.com/user-attachments/assets/fbb43aa4-9652-4a49-b984-5cf032b6b1ac" width="50"/></a>&nbsp;&nbsp;&nbsp;
  <a href="https://www.youtube.com/@ZamzaSalim" target="_blank"><img src="https://github.com/user-attachments/assets/c15509f9-acb7-49ce-989a-5bac62e7e549" width="50"/></a>
</p>

---

# TUTORIAL GENSYN TESTNET
## SPEK VPS
|  Hardware/VPS |  Minimum |
| ------------ | ------------ |
| CPU  | 4 core  |
| RAM | 16GB of memory |
| Storage  | 100 GB free disk space |
| Network | Stable internet connection |

## Install Depenci
```
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash -
sudo apt-get install -y nodejs
```
```
sudo apt update && sudo apt install -y python3 python3-venv python3-pip curl screen git yarn && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - && echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list && sudo apt update && sudo apt install -y yarn
```
## Open Port
```
sudo ufw allow ssh
sudo ufw allow 3000
sudo ufw enable
sudo ufw status
```
## Clone Repository & Pindah Ke Folder Nodenya
```
git clone https://github.com/gensyn-ai/rl-swarm.git
cd rl-swarm
```
## Running Node use Screen
```
screen -S gensyn
```
```
python3 -m venv .venv
source .venv/bin/activate
```
```
pip install "protobuf<5.28.0"
```
```
pip install --upgrade pip
pip install hivemind
```
```
pip install --force-reinstall "protobuf<5.28.0"
``` 
```
./run_rl_swarm.sh
```
## Nanti ada pilihan hugging face pilih N (no) lalu enter
<p align="center">
  <img height="100" height="auto" src="https://github.com/sipalingnode/SIPALING-NODE/blob/main/gensyn/hg.png">
</p>

## Jika sudah sampe proses seperti dibawah ini. Keluar screen dulu dengan cara `CTRL+AD`
<p align="center">
  <img height="300" height="auto" src="https://github.com/sipalingnode/SIPALING-NODE/blob/main/gensyn/login.png">
</p>

## Lanjut Register Testnet
- Install Grok
  ```
  wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz && tar -xvzf ngrok-v3-stable-linux-amd64.tgz && sudo mv ngrok /usr/local/bin/
  ```
- Signup with email : https://ngrok.com/
- Login
- Go to Your Authtoken
- Showing Authtoken
- Copy & paste di vps kode yang ada di command line
- Jalankan ngrok dengan screen
  ```
  screen -S ngrok
  ```
  ```
  ngrok http 3000
  ```
- Pada bagian forwading
- Salin Link nya dan Paste di browser
- Lalu signup dengan email yang sama
- Done. Langsung keluar screen `CTRL+AD`

## Cek Proses apakah sudah seperti dibawah ini
- Open screen gensyn `screen -rd gensyn`
- <p align="center">
  <img height="300" height="auto" src="https://github.com/sipalingnode/SIPALING-NODE/blob/main/gensyn/done.png">
</p>

- Jika dirasa sudah langsung keluar screen saja. `CTRL+AD`
