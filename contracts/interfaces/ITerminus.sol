// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.9;

// Interface generated by solface: https://github.com/bugout-dev/solface
// solface version: 0.0.4
interface ITerminus {
    // structs

    // events
    event ApprovalForAll(address account, address operator, bool approved);
    event PoolMintBatch(
        uint256 id,
        address operator,
        address from,
        address[] toAddresses,
        uint256[] amounts
    );
    event TransferBatch(
        address operator,
        address from,
        address to,
        uint256[] ids,
        uint256[] values
    );
    event TransferSingle(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 value
    );
    event URI(string value, uint256 id);

    // functions
    function approveForPool(uint256 poolID, address operator) external;

    function balanceOf(
        address account,
        uint256 id
    ) external view returns (uint256);

    function balanceOfBatch(
        address[] memory accounts,
        uint256[] memory ids
    ) external view returns (uint256[] memory);

    function burn(address from, uint256 poolID, uint256 amount) external;

    function contractURI() external view returns (string memory);

    function createPoolV1(
        uint256 _capacity,
        bool _transferable,
        bool _burnable
    ) external returns (uint256);

    function createSimplePool(uint256 _capacity) external returns (uint256);

    function isApprovedForAll(
        address account,
        address operator
    ) external view returns (bool);

    function isApprovedForPool(
        uint256 poolID,
        address operator
    ) external view returns (bool);

    function mint(
        address to,
        uint256 poolID,
        uint256 amount,
        bytes memory data
    ) external;

    function mintBatch(
        address to,
        uint256[] memory poolIDs,
        uint256[] memory amounts,
        bytes memory data
    ) external;

    function paymentToken() external view returns (address);

    function poolBasePrice() external view returns (uint256);

    function poolMintBatch(
        uint256 id,
        address[] memory toAddresses,
        uint256[] memory amounts
    ) external;

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external;

    function setApprovalForAll(address operator, bool approved) external;

    function setContractURI(string memory _contractURI) external;

    function setController(address newController) external;

    function setPaymentToken(address newPaymentToken) external;

    function setPoolBasePrice(uint256 newBasePrice) external;

    function setPoolController(uint256 poolID, address newController) external;

    function setURI(uint256 poolID, string memory poolURI) external;

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    function terminusController() external view returns (address);

    function terminusPoolCapacity(
        uint256 poolID
    ) external view returns (uint256);

    function terminusPoolController(
        uint256 poolID
    ) external view returns (address);

    function terminusPoolSupply(uint256 poolID) external view returns (uint256);

    function totalPools() external view returns (uint256);

    function uri(uint256 poolID) external view returns (string memory);

    function withdrawPayments(address toAddress, uint256 amount) external;

    // errors
}