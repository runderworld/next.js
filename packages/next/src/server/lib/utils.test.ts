import {
  getFormattedNodeOptionsWithoutInspect,
  getParsedDebugAddress,
  formatNodeOptions,
  tokenizeArgs,
  getParsedNodeOptions,
  NodeOptions,
} from './utils'

const originalNodeOptions = process.env.NODE_OPTIONS

afterAll(() => {
  process.env.NODE_OPTIONS = originalNodeOptions
})

describe('tokenizeArgs', () => {
  it('splits arguments by spaces', () => {
    const result = tokenizeArgs('--spaces "thing with spaces" --normal 1234')

    expect(result).toEqual([
      '--spaces',
      'thing with spaces',
      '--normal',
      '1234',
    ])
  })

  it('supports quoted values', () => {
    const result = tokenizeArgs(
      '--spaces "thing with spaces" --spacesAndQuotes "thing with \\"spaces\\"" --normal 1234'
    )

    expect(result).toEqual([
      '--spaces',
      'thing with spaces',
      '--spacesAndQuotes',
      'thing with "spaces"',
      '--normal',
      '1234',
    ])
  })
})

describe('formatNodeOptions', () => {
  it('wraps values with spaces in quotes', () => {
    const opts = new NodeOptions({
      '--spaces': ['thing with spaces'],
      '--spacesAndQuotes': ['thing with "spaces"'],
      '--normal': ['1234'],
    })
    const result = formatNodeOptions(opts)

    expect(result).toEqual({
      execArgv: [],
      nodeOptions:
        '--spaces="thing with spaces" --spacesAndQuotes="thing with \\"spaces\\"" --normal=1234',
    })
    expect(result.execArgv).toEqual([])
  })

  it('separates exec-argv-only options from NODE_OPTIONS', () => {
    const opts = new NodeOptions({
      '--enable-source-maps': [true],
      '--experimental-network-inspection': [true],
      '--experimental-storage-inspection': [true],
      '--experimental-worker-inspection': [true],
      '--experimental-inspector-network-resource': [true],
      '--max-old-space-size': ['4096'],
    })
    const result = formatNodeOptions(opts)

    expect(result).toEqual({
      nodeOptions: '--enable-source-maps --max-old-space-size=4096',
      execArgv: [
        '--experimental-network-inspection',
        '--experimental-storage-inspection',
        '--experimental-worker-inspection',
        '--experimental-inspector-network-resource',
      ],
    })
  })

  it('handles repeated short options (e.g. -r file1 -r file2)', () => {
    const opts = new NodeOptions({
      '-r': ['./setup1.js', './setup2.js'],
    })
    const result = formatNodeOptions(opts)

    expect(result).toEqual({
      nodeOptions: '-r ./setup1.js -r ./setup2.js',
      execArgv: [],
    })
  })

  it('handles repeated long options (e.g. --require)', () => {
    const opts = new NodeOptions({
      '--require': ['./a.js', './b.js'],
    })
    const result = formatNodeOptions(opts)

    expect(result).toEqual({
      nodeOptions: '--require=./a.js --require=./b.js',
      execArgv: [],
    })
  })

  it('formats short boolean options correctly', () => {
    const opts = new NodeOptions({
      '-r': ['./file.js'],
      '--inspect': [true],
    })
    const result = formatNodeOptions(opts)

    expect(result).toEqual({
      nodeOptions: '-r ./file.js --inspect',
      execArgv: [],
    })
  })
})

describe('getParsedDebugAddress', () => {
  it('supports the flag with an equal sign', () => {
    process.env.NODE_OPTIONS = '--inspect=1234'
    const nodeOptions = getParsedNodeOptions()
    const result = getParsedDebugAddress(nodeOptions.get('inspect'))
    expect(result).toEqual({ host: undefined, port: 1234 })
  })

  it('supports the flag without an equal sign', () => {
    process.env.NODE_OPTIONS = '--inspect 1234'
    const nodeOptions = getParsedNodeOptions()
    const result = getParsedDebugAddress(nodeOptions.get('inspect'))
    expect(result).toEqual({ host: undefined, port: 1234 })
  })
})

describe('getFormattedNodeOptionsWithoutInspect', () => {
  it('removes --inspect option', () => {
    process.env.NODE_OPTIONS = '--other --inspect --additional'
    const result = getFormattedNodeOptionsWithoutInspect()

    expect(result).toBe('--other --additional')
  })

  it('removes --inspect option at end of line', () => {
    process.env.NODE_OPTIONS = '--other --inspect'
    const result = getFormattedNodeOptionsWithoutInspect()

    expect(result).toBe('--other')
  })

  it('handles options with spaces', () => {
    process.env.NODE_OPTIONS =
      '--other --inspect --additional --spaces "/some/path with spaces"'
    const result = getFormattedNodeOptionsWithoutInspect()

    expect(result).toBe(
      '--other --additional --spaces="/some/path with spaces"'
    )
  })

  it('handles options with quotes', () => {
    process.env.NODE_OPTIONS =
      '--require "./file with spaces to-require-with-node-require-option.js"'
    const result = getFormattedNodeOptionsWithoutInspect()

    expect(result).toBe(
      '--require="./file with spaces to-require-with-node-require-option.js"'
    )
  })

  it('removes --inspect option with parameters', () => {
    process.env.NODE_OPTIONS = '--other --inspect=0.0.0.0:1234 --additional'
    const result = getFormattedNodeOptionsWithoutInspect()

    expect(result).toBe('--other --additional')
  })

  it('removes --inspect-brk option', () => {
    process.env.NODE_OPTIONS = '--other --inspect-brk --additional'
    const result = getFormattedNodeOptionsWithoutInspect()

    expect(result).toBe('--other --additional')
  })

  it('removes --inspect-brk option with parameters', () => {
    process.env.NODE_OPTIONS = '--other --inspect-brk=0.0.0.0:1234 --additional'
    const result = getFormattedNodeOptionsWithoutInspect()

    expect(result).toBe('--other --additional')
  })

  it('ignores unrelated options starting with --inspect-', () => {
    process.env.NODE_OPTIONS =
      '--other --inspect-port=0.0.0.0:1234 --additional'
    const result = getFormattedNodeOptionsWithoutInspect()

    expect(result).toBe('--other --inspect-port=0.0.0.0:1234 --additional')
  })
})
