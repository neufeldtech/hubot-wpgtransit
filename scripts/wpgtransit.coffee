# Description:
#   Gets Bus Schedule Information via the Winnipeg Transit Open Data api
#
# Configuration:
#   HUBOT_WPGTRANSIT_KEY=ABCDEFGHIJKLMNOPXRSTUVWXYZ (Required)
#   HUBOT_WPGTRANSIT_URL=http://api.winnipegtransit.com/v2/ (Optional) 
#
# Dependencies:
#   "moment": "^2.15.1"
#   "moment-timezone": "^0.5.6"
#
# Notes:
#   You can get an API key here: https://api.winnipegtransit.com/home/users/new
#
# Commands:
#   hubot bus search <query> - Search for a stop number
#   hubot bus schedule - Display current bus schedule for the last bus stop that you viewed
#   hubot bus schedule <stop number> - Display current bus schedule for specified stop
#
# Author:
#   Jordan Neufeld <myjc.niv@gmail.com>
#
moment = require('moment-timezone')
stopsJSON = require('../data/bus_stops.json')
api_url = process.env.WPG_OPENDATA_URL || "http://api.winnipegtransit.com/v2/"
api_key = process.env.HUBOT_WPGTRANSIT_KEY 

module.exports = (robot) ->
  getSchedule = (msg, cb) ->
    now = new moment().tz("America/Winnipeg")
    #futureTime is how far in advance we want to display schedule for
    futureTime = now.add('1.25','hours').format('HH:mm')
    robot.logger.debug("#{api_url}stops/#{msg}/schedule.json?end=#{futureTime}&usage=long&max-results-per-route=4&api-key=#{api_key}")
    httprequest = robot.http("#{api_url}stops/#{msg}/schedule.json?end=#{futureTime}&usage=long&max-results-per-route=4&api-key=#{api_key}")
    httprequest.get() (err, res, body) ->
      if err or res.statusCode != 200
        cb "An Error occurred: " + body
      else
        cb null, body

  #Retrieve schedule by stop number
  robot.respond /bus schedules? ?(\d{5}|)$/i, (msg) ->
    preferredStop = robot.brain.get("preferred_stop_#{msg.message.user.id}")
    #If user left the stop number field blank, perform some logic
    if !msg.match[1]
      #if we find a preferred route in hubot's brain
      if preferredStop
        msg.match[1] = preferredStop
      else
        #did not find a preferred route and we were not given a stop number
        msg.send "I couldn't find any bus stop history for you #{msg.message.user.name}, please provide a 5 digit stop number."
        return

    getSchedule msg.match[1], (err, body) ->
      if err
        msg.send err
      else
        #Got successful result; remember this preferred route in hubot's brain
        robot.brain.set "preferred_stop_#{msg.message.user.id}", msg.match[1]
        bodyJSON = JSON.parse(body)
        stopName = bodyJSON['stop-schedule']['stop']['name']
        stopNumber = bodyJSON['stop-schedule']['stop']['number']
        routeSchedulesArray = bodyJSON['stop-schedule']['route-schedules']
        sortedRoutesArray = []
        i = 0
        while i < routeSchedulesArray.length
          routeScheduleObj = routeSchedulesArray[i]
          scheduledStopsArray = routeScheduleObj['scheduled-stops']
          s = 0
          while s < scheduledStopsArray.length
            scheduledStop = scheduledStopsArray[s]
            estimatedArrival = new moment(scheduledStop.times.arrival.estimated)
            sortedRoutesArray.push({estimatedArrival: estimatedArrival, routeNumber: routeScheduleObj.route.number, routeName: scheduledStop.variant.name})
            s++
          i++
        #Sort the array by date
        sortedRoutesArray.sort (a, b) ->
          new Date(a.estimatedArrival) - (new Date(b.estimatedArrival))
        scheduleData = ""
        d = 0
        while d < sortedRoutesArray.length
          scheduleData += "#{sortedRoutesArray[d].estimatedArrival.format('hh:mm')} - [#{sortedRoutesArray[d].routeNumber}] #{sortedRoutesArray[d].routeName}\n"
          d++
        msg.send "```Stop Number #{stopNumber} | #{stopName}\n Time - Route\n#{scheduleData.substring(0,2000)}```"

  #Search for stop number
  robot.respond /bus search (.*)/i, (msg) ->
    searchTerm = msg.match[1].toLowerCase().replace(".","").replace("’","'")
    resultsData = ""
    resultsCount = 0
    searchLimit = 25
    s = 0
    while s < stopsJSON.length
      for key of stopsJSON[s]
        # `key = key`
        if stopsJSON[s][key].toLowerCase().replace(".","").indexOf(searchTerm) != -1 and resultsCount < searchLimit
          resultsData += "Stop Number #{key} | #{stopsJSON[s][key]}\n"
          resultsCount++
      s++
    msg.send "```Search Results (limited to 25):\n#{resultsData}```"
