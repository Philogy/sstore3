import re
from collections import defaultdict


def parse_result(result):
    if (m := re.match(r'\[PASS\] test_(\w+)_([a-f0-9]{4})\(\) \(gas: (\d+)\)', result)) is None:
        raise ValueError(f'Invalid result {result!r}')

    name = m.group(1)

    return {'SSTORE25': 'SSTORE2 + CREATE3'}.get(name, name), int(m.group(2), 16), int(m.group(3))


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
[PASS] test_SSTORE25_001e() (gas: 75590)
[PASS] test_SSTORE25_0020() (gas: 75991)
[PASS] test_SSTORE25_0040() (gas: 82448)
[PASS] test_SSTORE25_0060() (gas: 88840)
[PASS] test_SSTORE25_0080() (gas: 95233)
[PASS] test_SSTORE25_00a0() (gas: 101646)
[PASS] test_SSTORE25_00c0() (gas: 108105)
[PASS] test_SSTORE25_00e0() (gas: 114519)
[PASS] test_SSTORE25_0100() (gas: 120911)
[PASS] test_SSTORE25_0120() (gas: 127345)
[PASS] test_SSTORE25_0140() (gas: 133697)
[PASS] test_SSTORE25_01e0() (gas: 165808)
[PASS] test_SSTORE25_0320() (gas: 229975)
[PASS] test_SSTORE25_0640() (gas: 390264)
[PASS] test_SSTORE25_0c80() (gas: 711037)
[PASS] test_SSTORE25_1f40() (gas: 1673298)
[PASS] test_SSTORE25_3e80() (gas: 3277598)
[PASS] test_SSTORE25_5fff() (gas: 4997613)
[PASS] test_SSTORE2_001e() (gas: 41657)
[PASS] test_SSTORE2_0020() (gas: 42085)
[PASS] test_SSTORE2_0040() (gas: 48449)
[PASS] test_SSTORE2_0060() (gas: 54855)
[PASS] test_SSTORE2_0080() (gas: 61307)
[PASS] test_SSTORE2_00a0() (gas: 67694)
[PASS] test_SSTORE2_00c0() (gas: 74080)
[PASS] test_SSTORE2_00e0() (gas: 80532)
[PASS] test_SSTORE2_0100() (gas: 86897)
[PASS] test_SSTORE2_0120() (gas: 93327)
[PASS] test_SSTORE2_0140() (gas: 99733)
[PASS] test_SSTORE2_01e0() (gas: 131796)
[PASS] test_SSTORE2_0320() (gas: 195854)
[PASS] test_SSTORE2_0640() (gas: 356059)
[PASS] test_SSTORE2_0c80() (gas: 676474)
[PASS] test_SSTORE2_1f40() (gas: 1637779)
[PASS] test_SSTORE2_3e80() (gas: 3240122)
[PASS] test_SSTORE2_5fff() (gas: 4957987)
[PASS] test_SSTORE3_001e() (gas: 44685)
[PASS] test_SSTORE3_0020() (gas: 47641)
[PASS] test_SSTORE3_0040() (gas: 56646)
[PASS] test_SSTORE3_0060() (gas: 65719)
[PASS] test_SSTORE3_0080() (gas: 74658)
[PASS] test_SSTORE3_00a0() (gas: 83711)
[PASS] test_SSTORE3_00c0() (gas: 92695)
[PASS] test_SSTORE3_00e0() (gas: 101725)
[PASS] test_SSTORE3_0100() (gas: 110762)
[PASS] test_SSTORE3_0120() (gas: 119761)
[PASS] test_SSTORE3_0140() (gas: 128702)
[PASS] test_SSTORE3_01e0() (gas: 173802)
[PASS] test_SSTORE3_0320() (gas: 265127)
[PASS] test_SSTORE3_0640() (gas: 501255)
[PASS] test_SSTORE3_0c80() (gas: 973592)
[PASS] test_SSTORE3_1f40() (gas: 2390581)
[PASS] test_SSTORE3_3e80() (gas: 4752515)
[PASS] test_SSTORE3_5fff() (gas: 7284876)
    '''.strip()

    rows = [*map(parse_result, inp.splitlines())]

    table = defaultdict(dict)

    for name, byte_count, gas in rows:
        table[byte_count][name] = gas

    table_rows = sorted(table.items(), key=lambda v: v[0])

    columns = ['bytes', 'SSTORE2', 'SSTORE2 + CREATE3',
               'SSTORE3 (est. w/ EIP1153)',  'SSTORE3']

    print(build_md_row(columns))
    print(build_md_row('-' * (len(o) + 2) for o in columns))

    for byte_count, row_gas in table_rows:
        if byte_count % 32 != 0:
            byte_rep = f'{byte_count:,} byte{s(byte_count)}'
        else:
            word_count = byte_count // 32
            byte_rep = f'{word_count:,} word{s(word_count)}'

        row = [byte_rep]

        row.append(gas_rep(row_gas['SSTORE2'], byte_count))
        row.append(gas_rep(row_gas['SSTORE2 + CREATE3'], byte_count))

        # EIP1153 SSTORE (no warming slot -2000 / slot, no reset ~ -120 / slot)
        slots = byte_count // 32 + 1 + (byte_count % 32 == 31)
        sstore3_gas = row_gas['SSTORE3'] - slots * (2100 + 120)
        row.append(gas_rep(sstore3_gas, byte_count))

        row.append(gas_rep(row_gas['SSTORE3'], byte_count))

        print(build_md_row(row))


if __name__ == '__main__':
    main()
