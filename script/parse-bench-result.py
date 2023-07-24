import re
from collections import defaultdict


def parse_result(result):
    if (m := re.match(r'\[PASS\] test_(\w+)_([a-f0-9]{4})\(\) \(gas: (\d+)\)', result)) is None:
        raise ValueError(f'Invalid result {result!r}')

    return m.group(1), int(m.group(2), 16), int(m.group(3))


def s(x: int) -> str:
    if x == 1:
        return ''
    return 's'


def build_md_row(values):
    return '|' + '|'.join(values) + '|'


def gas_rep(gas, byte_count):
    return f'{gas / 1000:,.1f}k ({gas / byte_count:,.1f} g/b)'


def main():
    inp = '''
[PASS] test_SSTORE2_0020() (gas: 42128)
[PASS] test_SSTORE2_0040() (gas: 48449)
[PASS] test_SSTORE2_0060() (gas: 54921)
[PASS] test_SSTORE2_00a0() (gas: 67649)
[PASS] test_SSTORE2_0140() (gas: 99777)
[PASS] test_SSTORE2_01e0() (gas: 131795)
[PASS] test_SSTORE2_0320() (gas: 195920)
[PASS] test_SSTORE2_0640() (gas: 356059)
[PASS] test_SSTORE2_0c80() (gas: 676540)
[PASS] test_SSTORE2_1f40() (gas: 1637734)
[PASS] test_SSTORE2_3e80() (gas: 3240144)
[PASS] test_SSTORE2_5fff() (gas: 4957987)
[PASS] test_SSTORE3_L_0020() (gas: 76061)
[PASS] test_SSTORE3_L_0040() (gas: 82452)
[PASS] test_SSTORE3_L_0060() (gas: 88889)
[PASS] test_SSTORE3_L_00a0() (gas: 101718)
[PASS] test_SSTORE3_L_0140() (gas: 133787)
[PASS] test_SSTORE3_L_01e0() (gas: 165880)
[PASS] test_SSTORE3_L_0320() (gas: 229998)
[PASS] test_SSTORE3_L_0640() (gas: 390291)
[PASS] test_SSTORE3_L_0c80() (gas: 711094)
[PASS] test_SSTORE3_L_1f40() (gas: 1673349)
[PASS] test_SSTORE3_L_3e80() (gas: 3277671)
[PASS] test_SSTORE3_L_5fff() (gas: 4997655)
[PASS] test_SSTORE3_S_0020() (gas: 47961)
[PASS] test_SSTORE3_S_0040() (gas: 56875)
[PASS] test_SSTORE3_S_0060() (gas: 65884)
[PASS] test_SSTORE3_S_00a0() (gas: 83897)
[PASS] test_SSTORE3_S_0140() (gas: 128999)
[PASS] test_SSTORE3_S_01e0() (gas: 173989)
[PASS] test_SSTORE3_S_0320() (gas: 265277)
[PASS] test_SSTORE3_S_0640() (gas: 501406)
[PASS] test_SSTORE3_S_0c80() (gas: 973725)
[PASS] test_SSTORE3_S_1f40() (gas: 2390768)
[PASS] test_SSTORE3_S_3e80() (gas: 4752718)
[PASS] test_SSTORE3_S_5fff() (gas: 7285040)
[PASS] test_read_SSTORE2() (gas: 3299)
[PASS] test_read_SSTORE3_L() (gas: 3557)
[PASS] test_read_SSTORE3_S() (gas: 3330)
    '''.strip()

    rows = [
        parse_result(line)
        for line in inp.splitlines()
        if not line.startswith('[PASS] test_read')
    ]

    table = defaultdict(dict)

    for name, byte_count, gas in rows:
        table[byte_count][name] = gas

    table_rows = sorted(table.items(), key=lambda v: v[0])

    columns = ['Data Size (1 word = 32 bytes)', 'SSTORE2', 'SSTORE3_S',
               'SSTORE3_M (est. w/ EIP1153)',  'SSTORE3_L']

    print(build_md_row(columns))
    print(build_md_row('-' * (len(o) + 2) for o in columns))

    for byte_count, row_gas in table_rows:
        if byte_count == 24_575:
            byte_rep = f'24,575 bytes (maximum)'
        elif byte_count % 32 != 0:
            byte_rep = f'{byte_count:,} byte{s(byte_count)}'
        else:
            word_count = byte_count // 32
            byte_rep = f'{word_count:,} word{s(word_count)}'

        row = [byte_rep]

        row.append(gas_rep(row_gas['SSTORE2'], byte_count))
        row.append(gas_rep(row_gas['SSTORE3_S'], byte_count))

        # EIP1153 SSTORE (no warming slot -2000 / slot, no reset ~ -120 / slot)
        slots = byte_count // 32 + 1 + (byte_count % 32 == 31)
        sstore3_gas = row_gas['SSTORE3_S'] - slots * (2100 + 120)
        row.append(gas_rep(sstore3_gas, byte_count))

        row.append(gas_rep(row_gas['SSTORE3_L'], byte_count))

        print(build_md_row(row))


if __name__ == '__main__':
    main()
