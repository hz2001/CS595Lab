// deposit.nr - Circuit for depositing 0.1 ETH into the Whirlwind mixer
use dep::std::hash::pedersen_hash;
use std::merkle::compute_merkle_root;

// Main function executing the deposit circuit constraints
fn main(
    // Private inputs
    id: Field,
    r: Field,
    old_path: [Field; 8],
    
    // Public inputs
    old_root: pub Field,      // current root of the Merkle tree before deposit
    new_root: pub Field,      // new root of the Merkle tree after deposit
    commitment: pub Field,    // the Pedersen hash of (id, r)
    leaf_index: pub Field         // Leaf index for the deposit
) {
     let computed_commitment = pedersen_hash([id, r]);
    assert(computed_commitment == commitment);

    // insert commitment to get new_root
    let computed_new_root = compute_merkle_root(commitment, leaf_index, old_path);
    assert(computed_new_root == new_root);

    let old_leaf = 0x18d85f3de6dcd78b6ffbf5d8374433a5528d8e3bf2100df0b7bb43a4c59ebd63;
    assert(compute_merkle_root(old_leaf, leaf_index, old_path) == old_root);
} 