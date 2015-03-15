gulp = require 'gulp'
shell = require 'gulp-shell'

gulp.task 'test-cov', shell.task [
  'mocha --colors --compilers coffee:coffee-script/register'
  '--reporter node_modules/mocha-reporter-cov-summary'
  '--require test/env -- test/*.test.coffee'
].join(' '), COV_TEST: 'true'

gulp.task 'test-bail', shell.task [
  'mocha --colors --compilers coffee:coffee-script/register'
  '--require test/env --bail -- test/*.test.coffee'
].join(' '), ignoreErrors: true

gulp.task 'test', ['test-cov']
