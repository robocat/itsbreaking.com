delay = (ms, func) -> setTimeout func, ms

# == Yosemite interface ==

ordinalSuffix = (number) ->
	switch number
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
	$("#date-dayofmonth").html(today.format("DD"))
	$("#date-month").html(today.format("MMMM"))
	$("#date-tense").html(ordinalSuffix(today.format("DD")))

# == Animations ==

animateElement = (ele) ->
	state = ele.data 'animation-state'
	switch state
		when null || 'in'
			hideElement ele
		else
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

	return if $mac.data 'animation-state' == 'in'

	windowHeight = $(window).height()
	windowOffset = $(window).scrollTop()
	offset = $mac.offset().top

	if offset < (windowOffset + windowHeight)
		scrolled = Math.round(((windowOffset + windowHeight - offset) / windowHeight ) * 100)
		if scrolled > 40
			presentElement $iphone
			presentElement $mac

# == Vimeo ==

vimeoReady = (pid) ->
	fp = Froogaloop(pid)
	fp.addEvent('finish', vimeoFinished)
	fp.api 'play'

vimeoFinished = (pid) ->
	delay 400, ->
		hideVideo()

playVideo = ->
	fp = Froogaloop($("#headervid")[0])
	fp.addEvent 'ready', vimeoReady
	fp.addEvent 'finish', vimeoFinished

showVideo = ->
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

$(document).ready ->
	# == Initial State ==

	updateTime()
	updateDate()
	animateDevices()
	
	# == Click Handlers ==

	$("#curtain").click (e) ->
		e.preventDefault()
		showVideo()

	$("#download").click (e) ->
		e.preventDefault()
		$("html, body").animate { scrollTop: $('#appstore').offset().top - 50 }, "slow"

	$("#watch").click (e) ->
		e.preventDefault()
		$("html, body").animate { scrollTop: 0 }, "slow", "swing", ->
			showVideo()