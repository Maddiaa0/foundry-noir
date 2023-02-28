# Foundry x Noir

A [foundry](https://github.com/foundry-rs/foundry) library for working with [noir](https://github.com/noir-lang/noir) contracts. Take a look at our [project template](https://github.com/cheethas/noirplate) to quickly get up to speed using this library.

## Installing

First, install the [nargo](https://github.com/noir-lang/noir) by running:

```
curl -L https://raw.githubusercontent.com/noir-lang/noirup/main/install | bash
```

Then, install this library with [forge](https://github.com/foundry-rs/foundry):

```
forge install cheethas/foundry-noir
```

## Usage

The NoirProver is a Solidity library that takes a path to a noir project and generates a hex proof given a series of inputs. To use it, simply import it into your file by doing:

```js
import { NoirProver } from "foundry-huff/Noir.sol";
```

This library will not generate the verifier contract for you, however there is a sister project `noirplate` that has a script you can run after each of your circuit changes to generate a new verifier.

Here is an example deployment from the sister [template repo](https://github.com/cheethas/noirplate):

```solidity
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/NoirExample.sol";
import {NoirProver} from "foundry-noir/Noir.sol";

contract NoirExampleTest is Test {
    NoirProver public noirProver;
    NoirExample public noirExample;

    function setUp() public {
        noirExample = new NoirExample();
        noirProver = new NoirProver()
            .with_nargo_project_path("./circuits");
    }

    function testGenerateAndVerifyProof() public {
        noirProver
            .with_input(NoirProver.CircuitInput("x", 1))
            .with_public_input(NoirProver.CircuitInput("y", 2));

        bytes memory proof = noirProver.generate_proof();
        noirExample.verifyProof(proof);
    }
}
```

Above you can see that you can target multiple different nargo projects within the same test suite by creating a new NoirProver with a different `.with_nargo_project_path(<your_path_here (relative to root)>)`

_NOTE: It is highly recommended that you read the foundry book, or at least familiarize yourself with foundry, before using this library to avoid easily susceptible footguns._
