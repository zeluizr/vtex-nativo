proxy = require('proxy-middleware')
serveStatic = require('serve-static')
httpPlease = require('connect-http-please')
url = require('url')
middlewares = require('./speed-middleware')
sass = require('node-sass')
tildeImporter = require('node-sass-tilde-importer')


module.exports = (grunt) ->
  pkg = grunt.file.readJSON('package.json')

  accountName = process.env.VTEX_ACCOUNT or pkg.accountName or 'basedevmkp'
  environment = process.env.VTEX_ENV or pkg.env or 'vtexcommercestable'
  secureUrl = process.env.VTEX_SECURE_URL or pkg.secureUrl or true
  port = process.env.PORT or pkg.port or 80

  console.log('Running on port ' + port)

  compress = grunt.option('compress')
  verbose = grunt.option('verbose')

  if secureUrl
    imgProxyOptions = url.parse("https://#{accountName}.vteximg.com.br/arquivos")
  else
    imgProxyOptions = url.parse("http://#{accountName}.vteximg.com.br/arquivos")

  imgProxyOptions.route = '/arquivos'

  # portalHost is also used by connect-http-please
  # example: basedevmkp.vtexcommercestable.com.br
  portalHost = "#{accountName}.#{environment}.com.br"
  localHost = "#{accountName}.vtexlocal.com.br"

  if port isnt 80
    localHost += ":#{port}"

  if secureUrl
    portalProxyOptions = url.parse("https://#{portalHost}/")
  else
    portalProxyOptions = url.parse("http://#{portalHost}/")

  portalProxyOptions.preserveHost = true
  portalProxyOptions.cookieRewrite = "#{accountName}.vtexlocal.com.br"

  rewriteReferer = (referer = '') ->
    if secureUrl
      referer = referer.replace('http:', 'https:')
    return referer.replace(localHost, portalHost)

  rewriteLocation = (location) ->
    return location
      .replace('https:', 'http:')
      .replace(portalHost, localHost)

  config =
    clean:
      main: ['build']

    copy:
      html:
        files: [
          expand: true
          cwd: 'src/template'
          src: ['**/*.html']
          dest: 'build/template'
        ]

    concat: 
      options: 
        separator: '\n'
      dist: 
        src: ['src/javascripts/plugins/*.js', 'src/javascripts/functions/*.js', 'src/javascripts/global.js']
        dest: 'build/arquivos/tiendatest2.js'

    coffee:
      main:
        files: [
          expand: true
          flatten: true
          cwd: 'src/javascript'
          src: ['**/*.coffee']
          dest: 'build/arquivos/'
          ext: '.js'
        ]

    sass:
      compile:
        options:
          implementation: sass
          sourceMap: false
          importer: tildeImporter
        files: [
          expand: true
          flatten: true
          cwd: 'src/styles'
          src: ['**/*.scss','**/!_*.scss']
          dest: 'build/arquivos/'
          ext: '.css'
        ]
      min:
        options:
          implementation: sass
          sourceMap: true
          importer: tildeImporter
          outputStyle: 'compressed'
          sourceMapRoot: '../src/styles'
        files: [
          expand: true
          flatten: true
          cwd: 'src/'
          src: ['**/*.scss']
          dest: 'build/arquivos/'
          ext: '.min.css'
        ]

    less:
      main:
        files: [
          expand: true
          flatten: true
          cwd: 'src/styles'
          src: ['**/*.less']
          dest: "build/arquivos/"
          ext: '.css'
        ]

    cssmin:
      main:
        expand: true
        flatten: true
        cwd: 'src/styles'
        src: ['**/*.css', '!**/*.min.css']
        dest: 'build/arquivos/'
        ext: '.min.css'

    uglify:
      options:
        sourceMap:
          root: '../../src/javascripts'
        mangle:
          reserved: [
            'jQuery'
          ]
        compress:
          drop_console: true
      main:
        files: [{
          expand: true
          flatten: true
          cwd: 'build/'
          src: ['**/*.js', '!**/*.min.js']
          dest: 'build/arquivos/'
          ext: '.min.js'
        }]

    sprite:
      all:
        src: 'src/sprite/*.png'
        dest: 'build/arquivos/spritesheet.png'
        destCss: 'build/arquivos/sprite.css'

    imagemin:
      main:
        files: [
          expand: true
          flatten: true
          cwd: 'src/images'
          src: ['**/*.{png,jpg,gif}']
          dest: 'build/arquivos/'
        ]

    connect:
      http:
        options:
          hostname: "*"
          livereload: true
          port: port
          middleware: [
            middlewares.disableCompression
            middlewares.rewriteLocationHeader(rewriteLocation)
            middlewares.replaceHost(portalHost)
            middlewares.replaceReferer(rewriteReferer)
            middlewares.replaceHtmlBody(environment, accountName, secureUrl, port)
            httpPlease(host: portalHost, verbose: verbose)
            serveStatic('./build')
            proxy(imgProxyOptions)
            proxy(portalProxyOptions)
            middlewares.errorHandler
          ]

    watch:
      options:
        livereload: true
      coffee:
        files: ['src/**/*.coffee']
        tasks: ['coffee']
      images:
        options:
          livereload: false
        files: ['src/images/**/*.{png,jpg,gif}']
        tasks: ['imagemin']
      sprite:
        options:
          livereload: false
        files: ['src/sprite/**/*.png']
        tasks: ['sprite']
      css:
        files: ['src/styles/**/*.css']
        tasks: ['copy:css']
      sass:
        files: ['src/styles/**/*.scss']
        tasks: ['sass:compile']
      less:
        files: ['src/styles/**/*.less']
        tasks: ['less']
      js:
        files: ['src/**/*.js']
        tasks: ['copy:js']
      js:
        files: ['src/**/*.js']
        tasks: ['concat']        
      grunt:
        files: ['Gruntfile.coffee']

  tasks =
    # Building block tasks
    build: ['clean', 'copy:html', 'concat', 'sprite', 'sass:compile', 'imagemin']
    min: ['uglify', 'cssmin', 'sass:min'] # minifies files
    # Deploy tasks
    dist: ['build', 'min'] # Dist - minifies files
    test: []
    # Development tasks
    default: ['build', 'connect', 'watch']

  if compress
    tasks.build.push 'min'
    config.watch.js.tasks.push 'uglify'
    config.watch.sass.tasks.push 'sass:min'

  # Project configuration.
  grunt.config.init config
  grunt.loadNpmTasks name for name of pkg.devDependencies when name[0..5] is 'grunt-'
  grunt.registerTask taskName, taskArray for taskName, taskArray of tasks
