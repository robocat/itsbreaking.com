gulp = require 'gulp'
gutil = require 'gulp-util'
plumber = require 'gulp-plumber'
runSeqeuence = require 'run-sequence'
gif = require 'gulp-if'

rename = require 'gulp-rename'
fs = require 'fs'
clean = require 'gulp-clean'

mustache = require 'gulp-mustache'
htmlmin = require 'gulp-minify-html'

sass = require 'gulp-sass'

coffee = require 'gulp-coffee'
concat = require 'gulp-concat'
uglify = require 'gulp-uglify'

sourcemaps = require 'gulp-sourcemaps'

reload = require 'gulp-livereload'

reload_script = '<script src="//localhost:{{ config.port }}/livereload.js"></script>'

config = {
	port: 9091,
	production: false
}

paths = {
	mustache: "**/*.mustache",
	sass: "assets/css/**/*.{scss,sass}",
	coffee: "assets/js/**/*.coffee",
	js: "assets/js/**/*.js",
	images: "assets/images/**/*.{jpg,png}"
}

onError = (err) ->
	console.log err

isFile = (str) ->
	!str.match "\n" && fs.existsSync str

readPartial = (name) ->
	path = 'partials/' + name + '.mustache'
	val = fs.readFileSync path, 'utf8' if isFile path

	val

gulp.task 'clean', (cb) ->
	gulp.src('Build')
		.pipe(plumber { errorHandler: onError } )
		.pipe(clean { force: false, read: true } )
		

gulp.task 'scripts', ->
	gulp.src(paths.coffee)
		.pipe(sourcemaps.init())
		.pipe(coffee({bare: true}))
		.pipe(concat('app.js'))
		.pipe(gif(config.production, uglify()))
		.pipe(sourcemaps.write('./maps'))
		.pipe(gulp.dest('Build/js/'))
		.pipe(reload())

	gulp.src(paths.js)
		.pipe(sourcemaps.init())
		.pipe(concat('vendor.js'))
		.pipe(gif(config.production, uglify()))
		.pipe(sourcemaps.write('./maps'))
		.pipe(gulp.dest('Build/js/'))
		.pipe(reload())

gulp.task 'images', ->
	gulp.src(paths.images)
		.pipe(plumber({
			errorHandler: onError
		}))
		.pipe(gulp.dest('Build/images/'))
		.pipe(reload())

gulp.task 'sass', ->
	sass_paths = ['./assets/css/vendor/bourbon', './assets/css/vendor/neat']
	sass_config = { 
		includePaths:  sass_paths,
		imagePath: '/images'
	}

	if config.production
		sass_config['outputStyle'] = 'compressed'
		sass_config['sourceComments'] = false

	gulp.src(paths.sass)
		.pipe(plumber({ errorHandler: onError }))
		.pipe(sourcemaps.init())
		.pipe(sass(sass_config))
		.pipe(sourcemaps.write('./maps'))
		.pipe(gulp.dest('Build/css/'))
		.pipe(reload())

gulp.task 'html', ->
	partials = {
		header: readPartial('header'),
		footer: readPartial('footer'),
	}

	partials.reload = reload_script if !config.production

	gulp.src([paths.mustache, '!partials/*', "!node_modules/**/*"])
		.pipe(mustache({ config: config },{}, partials))
		.pipe(rename({ extname: ".html" }))
		.pipe(gif(config.production, htmlmin()))
		.pipe(gulp.dest('./Build/'))
		.pipe(reload())

gulp.task 'watch', ->
	reload.listen(config.port)

	gulp.watch paths.coffee, ['scripts']
	gulp.watch paths.js, ['scripts']
	gulp.watch paths.mustache, ['html']
	gulp.watch paths.sass, ['sass']
	gulp.watch paths.images, ['images']

gulp.task 'set-production', ->
	config.production = true

gulp.task 'cleanbuild', ->
	runSeqeuence 'clean', 'build'

gulp.task 'build', ['html', 'sass', 'scripts', 'images']
gulp.task 'release', ['set-production', 'cleanbuild']

gulp.task 'default', ['cleanbuild', 'watch']
