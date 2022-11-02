"use strict";
/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
Object.defineProperty(exports, "__esModule", { value: true });
exports.ReserveLogicFactory = void 0;
const contracts_1 = require("@ethersproject/contracts");
class ReserveLogicFactory extends contracts_1.ContractFactory {
    constructor(signer) {
        super(_abi, _bytecode, signer);
    }
    deploy(overrides) {
        return super.deploy(overrides || {});
    }
    getDeployTransaction(overrides) {
        return super.getDeployTransaction(overrides || {});
    }
    attach(address) {
        return super.attach(address);
    }
    connect(signer) {
        return super.connect(signer);
    }
    static connect(address, signerOrProvider) {
        return new contracts_1.Contract(address, _abi, signerOrProvider);
    }
}
exports.ReserveLogicFactory = ReserveLogicFactory;
const _abi = [
    {
        anonymous: false,
        inputs: [
            {
                indexed: true,
                internalType: "address",
                name: "asset",
                type: "address",
            },
            {
                indexed: false,
                internalType: "uint256",
                name: "liquidityRate",
                type: "uint256",
            },
            {
                indexed: false,
                internalType: "uint256",
                name: "stableBorrowRate",
                type: "uint256",
            },
            {
                indexed: false,
                internalType: "uint256",
                name: "variableBorrowRate",
                type: "uint256",
            },
            {
                indexed: false,
                internalType: "uint256",
                name: "liquidityIndex",
                type: "uint256",
            },
            {
                indexed: false,
                internalType: "uint256",
                name: "variableBorrowIndex",
                type: "uint256",
            },
        ],
        name: "ReserveDataUpdated",
        type: "event",
    },
];
const _bytecode = "0x6105e761003a600b82828239805160001a60731461002d57634e487b7160e01b600052600060045260246000fd5b30600052607381538281f3fe73000000000000000000000000000000000000000030146080604052600436106100355760003560e01c80638b339fb01461003a575b600080fd5b81801561004657600080fd5b5061005a610055366004610293565b61005c565b005b6004860154604080518082019091526002815261199960f11b6020820152906001600160a01b0316156100ab5760405162461bcd60e51b81526004016100a2919061051e565b60405180910390fd5b506100b46101c3565b6001870180546fffffffffffffffffffffffffffffffff19166001600160801b03929092169190911790556100e76101c3565b6001870180546001600160801b03908116600160801b93909116929092029190911790556004860180546001600160a01b03199081166001600160a01b0397881617909155600587018054821695871695909517909455600686018054851693861693909317909255608081015160078601805490941694169390931767ffffffffffffffff60a81b1916600160a81b67ffffffffffffffff90921691909102179055610220810151600883015561024081015160098301805461ff001916610100921515929092029190911790556102600151600a90910155565b6b033b2e3c9fd0803ce800000090565b80356001600160a01b03811681146101ea57600080fd5b919050565b803580151581146101ea57600080fd5b600082601f83011261020f578081fd5b813567ffffffffffffffff8111156102295761022961059b565b61023c601f8201601f1916602001610571565b818152846020838601011115610250578283fd5b816020850160208301379081016020019190915292915050565b803567ffffffffffffffff811681146101ea57600080fd5b803560ff811681146101ea57600080fd5b60008060008060008060c087890312156102ab578182fd5b863595506102bb602088016101d3565b94506102c9604088016101d3565b93506102d7606088016101d3565b9250608087013567ffffffffffffffff808211156102f3578384fd5b818901915061028080838c031215610309578485fd5b61031281610571565b905061031d836101d3565b815261032b602084016101d3565b602082015261033c604084016101d3565b604082015261034d60608401610282565b606082015261035e608084016101d3565b608082015261036f60a084016101d3565b60a082015261038060c084016101d3565b60c082015261039160e084016101d3565b60e082015261010080840135838111156103a9578687fd5b6103b58d8287016101ff565b82840152505061012080840135838111156103ce578687fd5b6103da8d8287016101ff565b82840152505061014080840135838111156103f3578687fd5b6103ff8d8287016101ff565b8284015250506101608084013583811115610418578687fd5b6104248d8287016101ff565b828401525050610180808401358381111561043d578687fd5b6104498d8287016101ff565b8284015250506101a08084013583811115610462578687fd5b61046e8d8287016101ff565b8284015250506101c08084013583811115610487578687fd5b6104938d8287016101ff565b8284015250506101e080840135838111156104ac578687fd5b6104b88d8287016101ff565b82840152505061020091506104ce828401610282565b828201526102209150818301358282015261024091506104ef8284016101ef565b828201526102609150818301358282015280945050505061051260a0880161026a565b90509295509295509295565b6000602080835283518082850152825b8181101561054a5785810183015185820160400152820161052e565b8181111561055b5783604083870101525b50601f01601f1916929092016040019392505050565b60405181810167ffffffffffffffff811182821017156105935761059361059b565b604052919050565b634e487b7160e01b600052604160045260246000fdfea264697066735822122095549636be95c9206305405b9c1ec271a1e401ae0ddaf17973a388fcaba62e2664736f6c63430008000033";
//# sourceMappingURL=ReserveLogicFactory.js.map