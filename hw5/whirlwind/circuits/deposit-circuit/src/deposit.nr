// deposit.nr - Circuit for depositing 0.1 ETH into the Whirlwind mixer
use dep::std::hash::pedersen;

// Define the depth of the Merkle tree
const TREE_DEPTH: u8 = 8;

// Define a type for all the private inputs to the circuit
struct PrivateInputs {
    id: Field,        // nullifier base (secret identifier)
    r: Field,         // random blinding factor
    old_path: [Field; TREE_DEPTH]  // The old Merkle tree path to the empty leaf
}

// Main function executing the deposit circuit constraints
fn main(
    // Private inputs
    private_inputs: PrivateInputs,
    
    // Public inputs
    old_root: pub Field,      // current root of the Merkle tree before deposit
    new_root: pub Field,      // new root of the Merkle tree after deposit
    commitment: pub Field,    // the Pedersen hash of (id, r)
    index: pub Field         // Leaf index for the deposit
) {
    // 1. Verify that commitment == PedersenHash(id, r)
    let computed_commitment = pedersen([private_inputs.id, private_inputs.r]);
    constrain commitment == computed_commitment;
    
    // 2. Verify the old Merkle path against the old root
    let mut current_hash = computed_commitment;
    let mut path_bit = 0;
    
    for i in 0..TREE_DEPTH {
        let path_element = private_inputs.old_path[i];
        
        // Get current bit of index
        path_bit = (index as u64 >> i) & 1;
        
        if path_bit == 0 {
            // If path_bit is 0, the current hash is on the left
            current_hash = pedersen([current_hash, path_element]);
        } else {
            // If path_bit is 1, the current hash is on the right
            current_hash = pedersen([path_element, current_hash]);
        }
    }
    
    // Ensure that the computed root matches the provided old root
    constrain current_hash == old_root;
    
    // 3. Verify the new Merkle root (inserting our commitment)
    let mut current_hash = computed_commitment;
    let mut path_bit = 0;
    
    for i in 0..TREE_DEPTH {
        let path_element = private_inputs.old_path[i];
        
        // Get current bit of index
        path_bit = (index as u64 >> i) & 1;
        
        if path_bit == 0 {
            // If path_bit is 0, the current hash is on the left
            current_hash = pedersen([current_hash, path_element]);
        } else {
            // If path_bit is 1, the current hash is on the right
            current_hash = pedersen([path_element, current_hash]);
        }
    }
    
    // Ensure that the computed new root matches the provided new root
    constrain current_hash == new_root;
} 