// withdraw.nr - Circuit for withdrawing 0.1 ETH from the Whirlwind mixer
use dep::std::hash::pedersen_hash;
use std::merkle::compute_merkle_root;

fn main(
    // Private inputs
    r: Field,
    leaf_index: Field,
    path: [Field; 8],

    // Public inputs
    root: Field,
    id: Field
) {
    let commitment = pedersen_hash([id, r]);

    // verify commitment is in Merkle tree
    let computed_root = compute_merkle_root(commitment, leaf_index, path);
    assert(computed_root == root);
}