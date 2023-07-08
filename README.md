# 🪡 SSTORE3 🪡

Inspired by `SSTORE2`[^1][^2], the `SSTORE3` library enables a new way of using the "code-as-storage"
to efficiently store and retrieve large amounts of data programmatically. The core advantage of `SSTORE3`
is that it allows for **smaller pointer sizes**, allowing you to more easily pack the data pointer with
other storage variables, saving more gas.

## The Code-as-Storage Pattern

The _Code-as-Storage_ (CaS) pattern leverages the relative cost of loading bytecode vs. the cost of loading
storage:

- 32-byte Storage Read (Cold, first slot access within tx): `2100` gas
- n-byte Code Read (Cold, first address access within tx): `2600 + ceil(n / 32) * 3` gas[^3]

From the points above we can see that loading just 2 EVM words (64 bytes) is already cheaper to do
from bytecode (2606 gas) vs. from storage (4200 gas). The problem is smart contract code is
immutable[^4], unlike storage it cannot easily be modified. To work around this you need to store
& update a "pointer", some information that lets you know what contract stores the current data. To
"mutate" the data you then simply initialize a new store (deploy contract which holds new data) and
update the pointer:

```solidity
contract MyContract is SSTORE3  {
    uint40 internal pointer;

    // ...

    function updateData(bytes memory data) internal {
        sstore3(pointer++, data);
    }
}
```

In practice this will increase the cost of employing CaS as it require an additional storage read
to first get the pointer. This can be minimized by packing the pointer together with other
variables. This is also where the benefit of `SSTORE3` comes in, because the pointer can be
arbitrary (only requirement is all pointers are single use) you can use a much smaller type for the
pointer, allowing you to pack it with other values in more situations.

## When to use SSTORE2 over SSTORE3

Standalone, SSTORE2-based storage is slightly cheaper to read from than SSTORE3, however SSTORE2
requires you to update & store a full address as the data pointer. If you're able to store a full
address in stoage alongside your other variables **without** increasing the amount of unique storage
slots to be read in your function(s) it'll be net-cheaper to use SSTORE2.

**Reducing SSTORE2 Pointer Size**

The pointer size for SSTORE2 can practically be reduced from a full 20-byte address by up to 6 bytes down to
a 14-byte pointer by leveraging deterministic SSTORE2 deployment via CREATE2, however this will
require you to mine a salt for every update that results in an address with X-leading zeros (where
`X` is the amount of bytes you're shrinking the pointer by).


[^1]: [Solady `SSTORE2` implementation](https://github.com/Vectorized/solady/blob/main/src/utils/SSTORE2.sol)
[^2]: [Solmate `SSTORE2` implementation](https://github.com/transmissions11/solmate/blob/main/src/utils/SSTORE2.sol)
[^3]: Code is read using the `EXTCODECOPY` opcode which copies bytes to memory, if copying to fresh
memory sections this will incur an additional [memory expansion cost](https://ethereum.github.io/execution-specs/autoapi/ethereum/shanghai/vm/gas/index.html#calculate-memory-gas-cost), [`previous_cost - new_cost`](https://ethereum.github.io/execution-specs/autoapi/ethereum/shanghai/vm/gas/index.html#calculate-gas-extend-memory)
[^4]: Proxy patterns do not mutate actual bytecode but what implementation address the proxy points
  to in storage. As of the Shanghai upgrade bytecode is still mutable via the `SELFDESTRUCT` + `CREATE2`
  enabled metamorphic contract pattern, but this will [be deprecated by EIP-6780](https://eips.ethereum.org/EIPS/eip-6780) which is [likely to be included in the upcoming Cancun hardfork](https://github.com/ethereum/execution-specs/blob/master/network-upgrades/mainnet-upgrades/cancun.md).

