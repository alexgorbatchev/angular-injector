program  = require 'commander'
fs       = require 'fs'
injector = require './angular-injector'

program
  .version require('../package.json').version
  .usage '<infile> <outfile>'
  .option '-t, --token', 'Token function to inject', 'ng'
  .parse process.argv

if program.args.length isnt 0 and program.args.length isnt 2
  console.error 'angular-injector should be called with an input and output file, or no arguments if using stdio'
  process.exit 1

if program.args.length is 2
  [infile, outfile]  = program.args

  try
    content = fs.readFileSync infile, 'utf-8'
  catch e
    console.error 'Error opening: ' + infile
    process.exit 1

  generatedCode = injector.annotate content, program

  try
    fs.writeFileSync outfile, generatedCode
  catch e
    console.error 'Error writing to: ' + outfile
    process.exit 1

else
  # else use stdio
  buffer = ''

  process.stdin.setEncoding 'utf8'
  process.stdin.resume()
  process.stdin.on 'data', (chunk) -> buffer += chunk
  process.stdin.on 'end', -> process.stdout.write injector.annotate buffer, program
