gulp = require 'gulp'
shell = require 'gulp-shell'

gulp.task 'test', shell.task [
  'mocha --colors --compilers coffee:coffee-script/register'
  '--require test/env -- test/*.test.coffee'
].join ' '

gulp.task 'test-bail', shell.task [
  'mocha --colors --compilers coffee:coffee-script/register'
  '--require test/env --bail -- test/*.test.coffee'
].join(' '), ignoreErrors: true
