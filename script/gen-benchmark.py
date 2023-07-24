def main():
    lengths = [
        0x20 * 1,
        0x20 * 2,
        0x20 * 3,
        0x20 * 5,
        0x20 * 10,
        0x20 * 15,
        0x20 * 25,
        0x20 * 50,
        0x20 * 100,
        0x20 * 250,
        0x20 * 500,
        0x6000 - 1  # MAX
    ]

    for l in lengths:
        print(f'''

          function test_SSTORE3_S_{l:04x}() public {{
        bytes memory d = randomBytes("{l:04x}", {l});
        sstore3(0, d);
    }}

              function test_SSTORE2_{l:04x}() public {{
        bytes memory d = randomBytes("{l:04x}", {l});
        SSTORE2.write(d);
    }}

              function test_SSTORE3_L_{l:04x}() public {{
                  bytes memory d = randomBytes("{l:04x}", {l});
        SSTORE3_L.store(0, d);
    }}

              ''')


if __name__ == '__main__':
    main()
