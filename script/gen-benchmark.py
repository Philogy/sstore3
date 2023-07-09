def main():
    lengths = [
        0x20 - 2,
        0x20,
        *range(0x40, 0x20 * 10 + 1, 0x20),
        0x20 * 15,
        0x20 * 25,
        0x20 * 50,
        0x20 * 100,
        0x20 * 250,
        0x20 * 500,
        0x20 * 768 - 1
    ]

    for l in lengths:
        print(f'''

          function test_SSTORE3_{l:04x}() public {{
        bytes memory d = randomBytes("{l:04x}", {l});
        sstore3(0, d);
    }}

              function test_SSTORE2_{l:04x}() public {{
        bytes memory d = randomBytes("{l:04x}", {l});
        SSTORE2.write(d);
    }}

              function test_SSTORE25_{l:04x}() public {{
                  bytes memory d = randomBytes("{l:04x}", {l});
        SSTORE2_5.write(0, d);
    }}

              ''')


if __name__ == '__main__':
    main()
