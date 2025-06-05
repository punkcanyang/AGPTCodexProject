// 网络配置
const NETWORKS = {
    devnet: {
        name: "Devnet",
        nodeUrl: "https://fullnode.devnet.aptoslabs.com/v1",
        contractAddress: "0xe8212f3e57916bcb45f037d6de15e56cf97107669a767d8232f4aa359e061dda",
        explorerUrl: "https://explorer.aptoslabs.com",
        faucetUrl: "https://faucet.devnet.aptoslabs.com"
    },
    testnet: {
        name: "Testnet", 
        nodeUrl: "https://fullnode.testnet.aptoslabs.com/v1",
        contractAddress: "0xe8212f3e57916bcb45f037d6de15e56cf97107669a767d8232f4aa359e061dda",
        explorerUrl: "https://explorer.aptoslabs.com",
        faucetUrl: "https://aptos.dev/network/faucet"
    }
};

// 默认网络 (可以通过URL参数 ?network=testnet 切换)
const DEFAULT_NETWORK = "devnet";

// 获取当前网络配置
function getCurrentNetwork() {
    const urlParams = new URLSearchParams(window.location.search);
    const networkParam = urlParams.get('network');
    const network = networkParam && NETWORKS[networkParam] ? networkParam : DEFAULT_NETWORK;
    return {
        key: network,
        config: NETWORKS[network]
    };
}

// 导出配置
window.APTOS_CONFIG = {
    networks: NETWORKS,
    getCurrentNetwork: getCurrentNetwork,
    MODULE_NAME: "guessing_game"
}; 