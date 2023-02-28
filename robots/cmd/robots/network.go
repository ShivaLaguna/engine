package main

import (
	"context"
	"errors"
	"fmt"
	"math/big"
	"os"

	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/ethclient"

	terminus_contract "github.com/bugout-dev/engine/robots/pkg/terminus"
)

type NetworkContractClient struct {
	Client *ethclient.Client

	GasPrice *big.Int

	ContractAddress  common.Address
	ContractInstance *terminus_contract.Terminus
}

type Network struct {
	Endpoint string
	ChainID  *big.Int
}

type Networks struct {
	Networks map[string]Network
}

func (n *Networks) InitializeNetworks() error {
	if n.Networks == nil {
		n.Networks = make(map[string]Network)
	}

	NODEBALANCER_ACCESS_ID := os.Getenv("ENGINE_NODEBALANCER_ACCESS_ID")
	if NODEBALANCER_ACCESS_ID == "" {
		return errors.New("Environment variable ENGINE_NODEBALANCER_ACCESS_ID should be specified")
	}

	MUMBAI_WEB3_PROVIDER_URI := os.Getenv("MOONSTREAM_MUMBAI_WEB3_PROVIDER_URI")
	if MUMBAI_WEB3_PROVIDER_URI == "" {
		return errors.New("Environment variable MUMBAI_WEB3_PROVIDER_URI should be specified")
	}
	POLYGON_WEB3_PROVIDER_URI := os.Getenv("MOONSTREAM_POLYGON_WEB3_PROVIDER_URI")
	if POLYGON_WEB3_PROVIDER_URI == "" {
		return errors.New("Environment variable POLYGON_WEB3_PROVIDER_URI should be specified")
	}

	n.Networks["mumbai"] = Network{
		Endpoint: fmt.Sprintf("%s?access_id=%s&data_source=blockchain", MUMBAI_WEB3_PROVIDER_URI, NODEBALANCER_ACCESS_ID),
		ChainID:  big.NewInt(80001),
	}
	n.Networks["polygon"] = Network{
		Endpoint: fmt.Sprintf("%s?access_id=%s&data_source=blockchain", POLYGON_WEB3_PROVIDER_URI, NODEBALANCER_ACCESS_ID),
		ChainID:  big.NewInt(137),
	}

	// Manual Caldera network setup
	n.Networks["caldera"] = Network{
		Endpoint: "https://wyrm.constellationchain.xyz/http",
		ChainID:  big.NewInt(322),
	}

	return nil
}

// GenDialRpcClient parse PRC endpoint to dial client
func GenDialRpcClient(rpc_endpoint_uri string) (*ethclient.Client, error) {
	client, err := ethclient.Dial(rpc_endpoint_uri)
	if err != nil {
		return nil, err
	}

	return client, nil
}

// FetchSuggestedGasPrice fetch network for suggested gas price
func (c *NetworkContractClient) FetchSuggestedGasPrice(ctx context.Context) error {
	gas_price, err := c.Client.SuggestGasPrice(ctx)
	if err != nil {
		return err
	}

	c.GasPrice = gas_price

	return nil
}
