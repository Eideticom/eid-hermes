from ubpf import assembler

from textwrap import wrap
from pathlib import Path

import os
import re
import logging
logging.basicConfig(level=logging.INFO)

TEST_DIR = 'tests'
BYTECODE_DIR = 'bytecode'
RESULTS_DIR = 'results'
MEMORY_DIR = 'final_memory'

BYTECODE_SUFFIX = '.bytes'
RESULT_SUFFIX = '.res'
MEMORY_SUFFIX = '.mem'

# for each .data file, create bytecode, result, and memory files


def assemble(source):
    bytecode = assembler.assemble(source)
    instructions = []
    # stupid endian flip thing
    for line in bytecode.hex(sep='\n', bytes_per_sep=8).split():
        instructions.append(
            '0x' + ''.join(wrap(line, 2)[::-1])
        )

    return '\n'.join(instructions)


def parse(filepath):
    with open(filepath, 'r') as datafile:
        # remove comment lines
        datafile_content = re.sub(r'#.*\n', '', datafile.read())
        # find content
        sections = {}
        # regex witchcraft
        for match in re.finditer(r'(?s)-- (?P<header>\w+)[ \w]*\n(?P<body>.*?(?=\n--|\Z))', datafile_content):
            header = match.group('header')
            body = match.group('body')
            sections[header] = body

        return sections


if __name__ == '__main__':
    for directory in [BYTECODE_DIR, RESULTS_DIR, MEMORY_DIR]:
        Path(directory).mkdir(exist_ok=True)
    for filename in os.listdir(TEST_DIR):
        logging.info(f'parsing {filename}...')
        bytecodeString = resultString = ''
        content = parse(os.path.join(TEST_DIR, filename))

        # create bytecode file
        if 'raw' in content:
            bytecodeString = content['raw']
        elif 'asm' in content:
            bytecodeString = assemble(content['asm'])
        if bytecodeString:
            bytecodeFilename = Path(filename).with_suffix(BYTECODE_SUFFIX)
            try:
                with open(os.path.join(BYTECODE_DIR, bytecodeFilename), 'x') as bytecodeFile:
                    bytecodeFile.write(bytecodeString)
            except FileExistsError:
                logging.warning(f'{bytecodeFilename} already exists, skipping...')

        # create result file
        if 'result' in content:
            resultString = content['result']
        elif 'error' in content:
            resultString = content['error']
        if resultString:
            resultFilename = Path(filename).with_suffix(RESULT_SUFFIX)
            try:
                with open(os.path.join(RESULTS_DIR, resultFilename), 'x') as resultFile:
                    resultFile.write(resultString)
            except FileExistsError:
                logging.warning(f'{resultFilename} already exists, skipping...')

        # create final memory file
        if 'mem' in content:
            memoryFilename = Path(filename).with_suffix(MEMORY_SUFFIX)
            try:
                with open(os.path.join(MEMORY_DIR, memoryFilename), 'x') as memoryFile:
                    memoryFile.write(content['mem'])
            except FileExistsError:
                logging.warning(f'{memoryFilename} already exists, skipping...')
