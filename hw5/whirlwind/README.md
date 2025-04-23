# Whirlwind: Privacy Preserving Asset Transfer Mechanism

This project implements a privacy-preserving asset transfer mechanism ("Whirlwind") using zero-knowledge proofs with Noir and Solidity. Users can deposit and withdraw 0.1 ETH anonymously through a smart contract that utilizes Merkle trees and ZK proofs to ensure privacy.

## Project Structure

```
/whirlwind/
│
├── circuits/
│   ├── deposit-circuit/        # Noir project for deposit
│   │   ├── src/deposit.nr      # Circuit for deposit operations
│   │   ├── Nargo.toml          # Project configuration
│   │   └── Prover.toml         # Generated test inputs
│   └── withdraw-circuit/       # Noir project for withdraw
│       ├── src/withdraw.nr     # Circuit for withdraw operations
│       ├── Nargo.toml          # Project configuration
│       └── Prover.toml         # Generated test inputs
│
├── contracts/
│   ├── whirlwind.sol           # Main contract
│   ├── DepositVerifier.sol     # Generated verifier for deposit proofs
│   └── WithdrawVerifier.sol    # Generated verifier for withdraw proofs
│
└── README.md                   # This file
```

## How it Works

### Deposit Process
1. User selects a random `id` and blinding factor `r`
2. The circuit creates a commitment `PedersenHash(id, r)`
3. The commitment is inserted into a Merkle tree
4. A ZK proof verifies correct computation of the commitment and Merkle tree update

### Withdraw Process
1. User proves knowledge of an `id` and `r` that hash to a commitment in the Merkle tree
2. The `id` serves as a public nullifier to prevent double spending
3. Upon verification, the user receives 0.1 ETH

## Getting Started

### Prerequisites
- Noir installed with `noirup`
- Barretenberg installed with `bbup`
- Node.js for running the TOML generators

### Building and Testing
1. Generate the test inputs using the provided TOML generator
2. Compile the deposit circuit:
   ```bash
   cd circuits/deposit-circuit
   nargo compile
   ```
3. Compile the withdraw circuit:
   ```bash
   cd circuits/withdraw-circuit
   nargo compile
   ```
4. Generate proofs for testing:
   ```bash
   nargo prove
   ```
5. Generate Solidity verifiers:
   ```bash
   bb write_solidity_verifier --scheme ultra_honk -k ./target/vk -o ./target/DepositVerifier.sol
   bb write_solidity_verifier --scheme ultra_honk -k ./target/vk -o ./target/WithdrawVerifier.sol
   ```
6. Deploy the contracts using Remix or another deployment tool

## Circuit Details

### Deposit Circuit (`deposit.nr`)
- **Private Inputs**: `id`, `r`, and the old Merkle path to the empty leaf
- **Public Inputs**: `oldRoot`, `newRoot`, `commitment`, and leaf `index`
- **Constraints**: Verifies commitment calculation and correct Merkle tree update

### Withdraw Circuit (`withdraw.nr`)
- **Private Inputs**: `r`, leaf `index`, and Merkle `path`
- **Public Inputs**: `root` and `id` (the nullifier)
- **Constraints**: Verifies the commitment exists in the tree and exposes the nullifier

## Generating Test Inputs

Use the provided `demo.ts` script to generate the TOML files needed for testing:

```bash
cd hw5/gen_toml/src
npx ts-node demo.ts
```

The output can be copied into `Prover.toml` files for both circuits. 