delay = (ms, func) -> setTimeout func, ms

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
	$("#video-overlay").removeClass 'animate-out'
	$("#video-overlay").addClass 'animate-in'
	$("#header").removeClass 'animate-out'
	$("#header").addClass 'animate-in'
	delay 600, ->
		$("#video-container iframe").addClass 'animate'
		delay 400, ->
			playVideo()

hideVideo = ->
	$("#video-overlay").removeClass 'animate-in'
	$("#video-overlay").addClass 'animate-out'
	$("#header").removeClass 'animate-in'
	$("#header").addClass 'animate-out'

$(document).ready ->
	updateTime()
	updateDate()

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