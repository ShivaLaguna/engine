package main

import (
	"errors"
	"fmt"
	"math/big"

	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/ethclient"

	terminus_contract "github.com/bugout-dev/engine/robots/pkg/terminus"
)

func GetTerminusContractAddress(blockchain string) (*common.Address, error) {
	switch blockchain {
	case "polygon":
		if TERMINUS_CONTRACT_POLYGON_ADDRESS == "" {
			return nil, errors.New("Terminus polygon contract address should be specified")
		}
		address := common.HexToAddress(TERMINUS_CONTRACT_POLYGON_ADDRESS)
		return &address, nil
	case "mumbai":
		if TERMINUS_CONTRACT_MUMBAI_ADDRESS == "" {
			return nil, errors.New("Terminus mumbai contract address should be specified")
		}
		address := common.HexToAddress(TERMINUS_CONTRACT_MUMBAI_ADDRESS)
		return &address, nil
	case "caldera":
		if TERMINUS_CONTRACT_CALDERA_ADDRESS == "" {
			return nil, errors.New("Terminus caldera contract address should be specified")
		}
		address := common.HexToAddress(TERMINUS_CONTRACT_CALDERA_ADDRESS)
		return &address, nil
	}
	return nil, errors.New(fmt.Sprintf("Not supported blockchain by Terminus contract found: %s", blockchain))
}

// InitializeContractInstance parse contract to instance
func InitializeTerminusContractInstance(client *ethclient.Client, address common.Address) (*terminus_contract.Terminus, error) {
	contractInstance, err := terminus_contract.NewTerminus(address, client)
	if err != nil {
		return nil, err
	}

	return contractInstance, nil
}

func (ct *NetworkContractClient) FetchPoolCapacity(pool_id int64) (*big.Int, error) {
	pool_capacity, err := ct.ContractInstance.TerminusPoolCapacity(nil, big.NewInt(pool_id))
	if err != nil {
		return nil, err
	}

	return pool_capacity, nil
}

// PoolMintBatch executes PoolMintBatch for list of address with same value amount
func (ct *NetworkContractClient) PoolMintBatch(auth *bind.TransactOpts, pool_id_int int64, claimants []Claimant, value int64) (*types.Transaction, error) {
	to_addresses := []common.Address{}
	values := []*big.Int{}
	for _, claimant := range claimants {
		to_addresses = append(to_addresses, common.HexToAddress(claimant.Address))
		values = append(values, big.NewInt(value))
	}

	tx, err := ct.ContractInstance.PoolMintBatch(auth, big.NewInt(pool_id_int), to_addresses, values)
	if err != nil {
		return nil, err
	}

	return tx, nil
}

func (ct *NetworkContractClient) BalanceOfBatch(auth *bind.CallOpts, claimants []Claimant, id_int int64) ([]*big.Int, error) {
	addresses := []common.Address{}
	ids := []*big.Int{}
	for _, claimant := range claimants {
		addresses = append(addresses, common.HexToAddress(claimant.Address))
		ids = append(ids, big.NewInt(id_int))
	}
	balances, err := ct.ContractInstance.BalanceOfBatch(auth, addresses, ids)
	if err != nil {
		return nil, err
	}

	return balances, nil
}
