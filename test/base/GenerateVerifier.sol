
import {Vm} from "forge-std/Vm.sol";

import "forge-std/console.sol";
contract GenerateVerifier {

    Vm public constant vm = Vm(address(bytes20(uint160(uint256(keccak256("hevm cheat code"))))));

    string public nargo_directory;
    string public output_directory;
    string public output_verifier_filename;

    function with_nargo_directory(string memory dir) public returns(GenerateVerifier) {
        nargo_directory = dir;
        return this;
    }

    function with_output_directory(string memory dir) public returns(GenerateVerifier) {
        output_directory = dir;
        return this;
    }

    function with_output_verifier_name(string memory filename) public returns(GenerateVerifier) {
        output_verifier_filename = filename;
        return this;
    }

    function generate() public returns (bool success) {
        
        string[] memory ffi_inputs = new string[](4);
        
        ffi_inputs[0] = "./scripts/copy_verifier.sh";
        ffi_inputs[1] = nargo_directory;
        ffi_inputs[2] = output_directory;
        ffi_inputs[3] = output_verifier_filename;

        bytes memory ffi_out = vm.ffi(ffi_inputs);
        console.log(string(ffi_out));
    }
}