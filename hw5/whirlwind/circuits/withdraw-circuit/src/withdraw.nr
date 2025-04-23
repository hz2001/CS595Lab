// withdraw.nr - Circuit for withdrawing 0.1 ETH from the Whirlwind mixer
use dep::std::hash::pedersen;

// Define the depth of the Merkle tree
const TREE_DEPTH: u8 = 8;

// Define a type for all the private inputs to the circuit
struct PrivateInputs {
    r: Field,              // blinding factor used in the commitment
    index: Field,          // leaf index in the Merkle tree
    path: [Field; TREE_DEPTH]  // Merkle path to the commitment
}

// Main function executing the withdraw circuit constraints
fn main(
    // Private inputs
    private_inputs: PrivateInputs,
    
    // Public inputs
    root: pub Field,     // current root of the Merkle tree
    id: pub Field        // the nullifier (public to prevent double spending)
) {
    // 1. Calculate the commitment from the nullifier and blinding factor
    let commitment = pedersen([id, private_inputs.r]);
    
    // 2. Verify that the commitment exists in the Merkle tree at the given index
    // by checking that the provided Merkle path leads to the current root
    let mut current_hash = commitment;
    let mut path_bit = 0;
    
    for i in 0..TREE_DEPTH {
        let path_element = private_inputs.path[i];
        
        // Get current bit of index
        path_bit = (private_inputs.index as u64 >> i) & 1;
        
        if path_bit == 0 {
            // If path_bit is 0, the current hash is on the left
            current_hash = pedersen([current_hash, path_element]);
        } else {
            // If path_bit is 1, the current hash is on the right
            current_hash = pedersen([path_element, current_hash]);
        }
    }
    
    // 3. Verify the computed root matches the provided root
    constrain current_hash == root;
    
    // Note: The nullifier 'id' is made public but we don't need to add any 
    // additional constraints here since it's already included in the commitment
    // which is verified against the Merkle tree. Making it public allows the 
    // contract to track which commitments have been withdrawn to prevent double spending.
} 