log = (msg) -> console.log msg
trim = (text) -> $.trim(text)
stripTags = (text) ->
	tmp = document.createElement "DIV"
	tmp.innerHTML = text
	tmp.textContent || tmp.innerText || text

stripIt = (html) ->
	$('<div />').text(html).text();

class NewsStory
	constructor: (@headline, @body, @link, @date, @source, @imageUrl = null) ->
		@date = this.parseDate @date

	parseDate: (date) ->
		moment(date)

	isValid: () ->
		if @headline && @body && @link && @date && @imageUrl != placeholderPath
			true
		else
			false

class Source
	constructor: (@title, @link, @icon) ->

class FeedParser
	constructor: (@feedData, @source) ->
		@stories = []

	parse: () ->
		self = this

		tags = ["entry", "item"]
		for tag in tags
			$(@feedData).find(tag).each () ->
				story = self.parseEntry(this)
				if story.isValid()
					self.stories.push(story)
			
	parseEntry: (entry) ->
		$entry = $(entry)
		content = $entry.find("content")
		if content.length != 1
			content = $entry.find("description")
		
		headline_t = content.find("title")
		headline = headline_t.text()
		if headline_t.length != 1
			headline = trim(stripTags($entry.find("title").text()))
		
		date = $entry.find("published").text()
		if $entry.find("published").length != 1
			date = $entry.find("pubDate").text()

		link_t = $entry.find("link")
		link = link_t.text()
		if link_t.length == 1 && link.length == 0
			link = link_t.attr "href"

		if !link || link.length == 0
			link = $entry.find("id").text()

		body = stripIt(trim(stripTags(content.text())))
		imageUrl = null

		imgRegex = /(http:|https:)?\/\/[^"?]+\.(jpg|jpeg|png)(\?[^"]*)?/m
		if imgRegex.test content.text()
			matches = imgRegex.exec content.text()
			imageUrl = matches[0]
		else
			imageUrl = placeholderPath

		new NewsStory(headline, body, link, date, @source, imageUrl)

sortedDataDate = (a, b) ->
	parseInt($(a).data('date')) < parseInt($(b).data('date')) ? 1 : -1

updateWidget = (stories) ->
	$feed = $("#feed")
	stories = stories.sort(sortedDataDate)
	stories = stories[0..3]
	for story in stories
		html = $("<a style=\"display: none\" href=\""+story.link+"\" target=\"_blank\" class=\"article\" data-date=\""+story.date.format('X')+"\">
					<div class=\"article-picture\" style=\"background-image: url("+story.imageUrl+")\">&nbsp;</div>
					<img src=\""+story.source.icon+"\" class=\"feed-icon\">
					<span class=\"time\">"+story.date.format("hh:mm")+"</span>
					<p class=\"title\">"+story.headline+"</p>
					<p class=\"excerpt\">"+story.body+"</p>
					<div class=\"clear\"></div>
				</a>")
		$feed.append(html)

parseFeed = (data, source) ->
	parser = new FeedParser(data, source)
	parser.parse()
	updateWidget(parser.stories)

fetchFeeds = () ->
	feeds = [
		new Source("The Verge", "https://breaking-feeder.herokuapp.com/feed/verge", "http://cdn0.vox-cdn.com/images/verge/favicon.vc44a54f.ico")
		new Source("Engadget", "https://breaking-feeder.herokuapp.com/feed/engadget" , "http://www.blogsmithmedia.com/www.engadget.com/media/favicon-32x32.png"),
		new Source("Macstroies", "https://breaking-feeder.herokuapp.com/feed/macstories" , "http://www.macstories.net/app/themes/macstories4/images/favicon.png")
	]

	i = 0
	$(feeds).each () ->
		source = this
		console.log "Requesting " + source.title

		$.ajax
			url: source.link
			datatype: "xml"
			error: (xhr, textStatus, errorThrown) ->
				console.log "Failed to get feed for " + source.title
				console.log textStatus
				console.log errorThrown
			success: (xml) ->
				console.log "Parsing " + source.title
				parseFeed(xml, source)
		.always () ->
			i++
			if i == feeds.length
				$feed = $("#feed")
				sorted = $("#feed a").sort(sortedDataDate)
				$feed.empty('')
				sorted.each (i, a) ->
					$feed.append(a)
				$("#feed a")[0..6].each () ->
					$(this).show()
				$("#sidebar").show()

$(document).ready ->
	fetchFeeds()