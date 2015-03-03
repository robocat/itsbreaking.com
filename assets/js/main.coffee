delay = (ms, func) -> setTimeout func, ms

# == Analytics

sendEvent = (category, action, label = "", value = undefined) ->
	ga('send', 'event', category, action, label, value) #if typeof ga != 'undefined'

# == Yosemite interface ==

ordinalSuffix = (number) ->
	switch parseInt(number)
		when 1 || 21 || 31 then "st"
		when 2 || 22 then "nd"
		when 3 || 23 then "rd"
		else "th"

updateTime = ->
	$("#time").html(moment().format("ddd h:mm"))
	delay 1000, updateTime

updateDate = ->
	today = moment()
	$("#date-weekday").html(today.format("dddd"))
	$("#date-dayofmonth").html(today.format("D"))
	$("#date-month").html(today.format("MMMM"))
	$("#date-tense").html(ordinalSuffix(today.format("DD")))

# == Animations ==

animateElement = (ele) ->
	state = ele.data 'animation-state'
	if state == 'in'
		hideElement ele
	else if state == 'out'
		presentElement ele

presentElement = (ele) ->
	ele.removeClass 'animate-out'
	ele.data 'animation-state', 'in'
	ele.addClass 'animate-in'

hideElement = (ele) ->
	ele.removeClass 'animate-in'
	ele.data 'animation-state', 'out'
	ele.addClass 'animate-out'

animateDevices = ->
	$iphone = $("#iphone_device")
	$mac = $("#mac_device")

	return if $mac.data('animation-state') == 'in'

	windowHeight = $(window).height()
	windowOffset = $(window).scrollTop()
	offset = $mac.offset().top

	if offset < (windowOffset + windowHeight)
		scrolled = Math.round(((windowOffset + windowHeight - offset) / windowHeight ) * 100)
		if scrolled > 40
			presentElement $iphone
			presentElement $mac

animateSideBar = ->
	$sidebar = $("#sidebar")

	return if $sidebar.data('animation-state') == 'in'

	windowHeight = $(window).height()
	windowOffset = $(window).scrollTop()
	offset = $sidebar.offset().top

	if offset < (windowOffset + windowHeight)
		scrolled = Math.round(((windowOffset + windowHeight - offset) / windowHeight ) * 100)
		if scrolled >= 100
			$sidebar.addClass 'appear'

animateInterface = ->
	$interface = $('.yosemite-int .interface');

	return if $interface.data('animation-state') == 'in'

	windowHeight = $(window).height()
	windowOffset = $(window).scrollTop()
	offset = $interface.offset().top

	if offset < (windowOffset + windowHeight)
		scrolled = Math.round(((windowOffset + windowHeight - offset) / windowHeight ) * 100)
		if scrolled > 40
			$interface.addClass 'animate-in'

# == Vimeo ==

vimeoReady = (pid) ->
	fp = Froogaloop(pid)
	fp.addEvent('finish', vimeoFinished)
	fp.api 'play'

	sendEvent 'video', 'started'

vimeoFinished = (pid) ->
	sendEvent 'video', 'played'

	delay 400, ->
		hideVideo()

vimeoPaused = (pid) ->
	sendEvent 'video', 'paused'

playVideo = ->
	fp = Froogaloop($("#headervid")[0])
	fp.addEvent 'ready', vimeoReady
	fp.addEvent 'pause', vimeoPaused
	fp.addEvent 'finish', vimeoFinished

showVideo = ->
	if $('#video-container iframe').data('animation-state') == 'out'
		animateElement $('#video-overlay')
		animateElement $('#header')
		animateElement $('#video-container iframe')
		delay 1200, ->
			playVideo()

hideVideo = ->
	animateElement $('#video-container iframe')
	delay 400, ->
		animateElement $('#video-overlay')
		delay 400, ->
			animateElement $('#header')

$(window).scroll ->
	animateDevices()
	animateSideBar()
	animateInterface()

$(document).ready ->
	# == Initial State ==

	updateTime()
	updateDate()
	animateDevices()
	animateSideBar()
	animateInterface()
	
	# == Click Handlers ==

	$("#curtain").click (e) ->
		e.preventDefault()
		sendEvent 'button', 'clicked', 'play'
		showVideo()

	$("#download").click (e) ->
		e.preventDefault()
		sendEvent 'button', 'clicked', 'download'
		$("html body").animate { scrollTop: $('#appstore').offset().top - 50 }, "slow"

	$("#watch").click (e) ->
		e.preventDefault()
		sendEvent 'button', 'clicked', 'download'
		$("html body").animate { scrollTop: 0 }, "slow", "swing", ->
			showVideo()