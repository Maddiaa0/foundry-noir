import {Vm} from "forge-std/Vm.sol";
import {strings} from "stringutils/strings.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract NoirProver {
    using strings for *;
    using Strings for uint256;
    
    Vm public constant vm = Vm(address(bytes20(uint160(uint256(keccak256("hevm cheat code"))))));
    
    struct CircuitInput {
        string name;
        uint256 value;
    }

    constructor() {}

    /// @notice the proofs public inputs
    CircuitInput[] public inputs;

    /// @notice the proofs public inputs
    CircuitInput[] public public_inputs;

    /// @notice the path to the nargo project
    string public nargo_project_path = "./circuits";

    function with_input(CircuitInput memory input) public returns (NoirProver) {
        inputs.push(input);
        return this;
    }

    function with_public_input(CircuitInput memory input) public returns (NoirProver) {
        public_inputs.push(input);
        return this;
    }

    function with_nargo_project_path(string memory path) public returns (NoirProver) {
        nargo_project_path = path;
        return this;
    }

    // Encode inputs as a comma seperated string for the ffi call
    function get_inputs() internal view returns (string[] memory input_params) {
        input_params = new string[](inputs.length * 2 + public_inputs.length  * 2);
        for (uint256 i = 0; i < inputs.length; i++) {
            uint256 base = i * 2;
            input_params[base] = "-i";
            input_params[base+1] = string.concat(inputs[i].name, "=", inputs[i].value.toString());
        }

        for (uint256 i; i < public_inputs.length; i++) {
            uint256 base = inputs.length + 1 + i * 2;
            input_params[base] = "-i";
            input_params[base+1] = string.concat(public_inputs[i].name, "=", public_inputs[i].value.toString());
        }
    }

    function generate_proof() public returns (bytes memory) {
        // Craft an ffi call to the prover binary
        string memory project_root = vm.projectRoot();
        string[] memory input_params = get_inputs();
        
        // Execute the c++ prover binary
        string[] memory ffi_cmds = new string[](4 +  input_params.length);
        ffi_cmds[0] = "nargo";
        ffi_cmds[1] = "--program-dir";
        ffi_cmds[2] = nargo_project_path;
        ffi_cmds[3] = "prove";
        for (uint256 i; i < input_params.length; i++) {
            ffi_cmds[i+4] = input_params[i];
        }

        bytes memory pub_inputs = encode_public_inputs();
        bytes memory proof = vm.ffi(ffi_cmds);
        return bytes.concat(pub_inputs, proof);
    }

    function encode_public_inputs() internal returns (bytes memory) {
        if (public_inputs.length == 0 ) return bytes("");
        uint256[] memory output = new uint256[](public_inputs.length);

        for (uint256 i; i < public_inputs.length; i++ ) {
            output[i] = uint256(public_inputs[i].value);
        }

        return abi.encodePacked(output);
    }
}