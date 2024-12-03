import manifest from "./manifest_mainnet.json";
import manifest_dev from "./manifest_slot.json";

const {
  VITE_PUBLIC_NODE_URL,
  VITE_PUBLIC_TORII,
  VITE_PUBLIC_MASTER_ADDRESS,
  VITE_PUBLIC_MASTER_PRIVATE_KEY,
  VITE_PUBLIC_ACCOUNT_CLASS_HASH,
  VITE_PUBLIC_FEE_TOKEN_ADDRESS,
  VITE_PUBLIC_ETH_ADDRESS,
  VITE_PUBLIC_LORDS_ADDRESS,
  VITE_PUBLIC_DEMO_NODE_URL,
  VITE_PUBLIC_DEMO_TORII
} = import.meta.env;

export const dojoConfig = {
  seasonId: 0,
  version: "0.4.6",
  rpcUrl: VITE_PUBLIC_NODE_URL,
  toriiUrl: VITE_PUBLIC_TORII,
  masterAddress: VITE_PUBLIC_MASTER_ADDRESS,
  masterPrivateKey: VITE_PUBLIC_MASTER_PRIVATE_KEY,
  accountClassHash: VITE_PUBLIC_ACCOUNT_CLASS_HASH || "0x05400e90f7e0ae78bd02c77cd75527280470e2fe19c54970dd79dc37a9d3645c",
  feeTokenAddress: VITE_PUBLIC_FEE_TOKEN_ADDRESS || "0x49d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7",
  ethAddress: VITE_PUBLIC_ETH_ADDRESS,
  lordsAddress: VITE_PUBLIC_LORDS_ADDRESS,
  demoRpcUrl: VITE_PUBLIC_DEMO_NODE_URL,
  demoTorii: VITE_PUBLIC_DEMO_TORII,
  manifest,
  manifest_dev,
};
