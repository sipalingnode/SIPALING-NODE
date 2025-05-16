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
## AUTO INSTALL & RUNNING AZTEC NODE
|  Hardware/VPS |  Recommendations |
| ------------ | ------------ |
| CPU  | 4 CORE  |
| RAM | 16GB of memory |
| Storage  | 300 GB free disk space |
| Network | Stable internet connection |

## Run Node
1. **Siapkan RPC ETH Sepolia & Sepolia Beacon : Gunakan RPC dari [Alchemy](https://www.alchemy.com/) & [DRPC](https://drpc.org/dashboard)**
2. **Siapkan Privatekey Metamask**
3. **IP VPSmu**
4. **Running Node**
   ```
   curl -o aztec-auto.sh https://raw.githubusercontent.com/sipalingnode/SIPALING-NODE/main/aztec/aztec-auto.sh && chmod +x aztec-auto.sh && ./aztec-auto.sh
   ```
## Claim Role Apprentice
1. **Join [Discord](https://discord.gg/aztec)**
2. **Go to #operator|start-here**
3. **ketik `/operator start`**
4. **Submit address , block , proof**
5. **Cara cek block & proof. copy & paste command ini**
```
PROVEN_BLOCK=$(curl -s -X POST -H 'Content-Type: application/json' \
  -d '{"jsonrpc":"2.0","method":"node_getL2Tips","params":[],"id":67}' \
  http://localhost:8080 | jq -r ".result.proven.number")

if [[ -z "$PROVEN_BLOCK" || "$PROVEN_BLOCK" == "null" ]]; then
  echo "Failed to retrieve the proven L2 block number."
else
  echo "Proven L2 Block Number: $PROVEN_BLOCK"
  echo "Fetching Sync Proof..."
  SYNC_PROOF=$(curl -s -X POST -H 'Content-Type: application/json' \
    -d "{\"jsonrpc\":\"2.0\",\"method\":\"node_getArchiveSiblingPath\",\"params\":[\"$PROVEN_BLOCK\",\"$PROVEN_BLOCK\"],\"id\":68}" \
    http://localhost:8080 | jq -r ".result")

  echo "Sync Proof:"
  echo "$SYNC_PROOF"
fi
```
## Create Validator
```
aztec add-l1-validator \
  --l1-rpc-urls sepoliarpc \
  --private-key your-private-key \
  --attester bscaddress \
  --proposer-eoa bscaddress \
  --staking-asset-handler 0xF739D03e98e23A7B65940848aBA8921fF3bAc4b2 \
  --l1-chain-id 11155111
```
## Stats
1. **Cek disini validatormu : https://aztecscan.xyz/validators**
2. **Cek Status via bot : https://t.me/aztec_seer_bot**
