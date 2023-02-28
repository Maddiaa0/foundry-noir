
import "./base/Noir.sol";
import "./base/GenerateVerifier.sol";
import "forge-std/console2.sol";

import "../src/Verifier.sol";

contract Test {
    NoirProver prover;
    GenerateVerifier genVerifier;
    TurboVerifier verifier;
    
    function setUp() public {
        prover = new NoirProver();
        genVerifier = new GenerateVerifier();
        // CopyVerifier();        
        verifier = new TurboVerifier();
    }

    function CopyVerifier() internal {
        genVerifier
            .with_nargo_directory("./nargo_test_dir")
            .with_output_directory("./src")
            .with_output_verifier_name("Verifier.sol")
            .generate();
    }

    function testProof() public {
        prover
            .with_nargo_project_path("./nargo_test_dir")
            .with_input(NoirProver.CircuitInput("x", 1))
            .with_public_input(NoirProver.CircuitInput("y", 2));
        bytes memory proof = prover.generate_proof(); 

        console.logBytes(proof);
        verifier.verify(proof);
    }
}