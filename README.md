hubot-wpgtransit
================
[![npm version](https://badge.fury.io/js/hubot-wpgtransit.svg)](https://badge.fury.io/js/hubot-wpgtransit)

Hubot plugin to get bus schedule information from the Winnipeg Transit Open Data API 

## Installation

* Run the ```npm install``` command

```
npm install hubot-wpgtransit --save
```

* Add the following code in your external-scripts.json file.

```
["hubot-wpgtransit"]
```
* You will need to [obtain an API key](https://api.winnipegtransit.com/home/users/new) here in order to use this script.
* Export your API key as an environment variable
```
export HUBOT_WPGTRANSIT_KEY=ABCDEFGHIJKLMNOPXRSTUVWXYZ
```
## Usage
* Search for a stop by name
```
hubot> hubot bus search Eastbound Portage
hubot> Search Results (limited to 25):
Stop Number 10562 | Eastbound Portage at Tylehurst (Polo Park)
Stop Number 10563 | Eastbound Portage at St. John Ambulance
Stop Number 10564 | Eastbound Portage at Raglan
Stop Number 10565 | Eastbound Portage at Craig
Stop Number 10566 | Eastbound Portage at Clifton
...
```
* Get the schedule info for a stop
```
hubot> hubot bus schedule 10562
hubot> Stop Number 10562 | Eastbound Portage at Tylehurst (Polo Park)
 Time - Route
12:49 - [11] Glenway
12:50 - [11] North Kildonan via Rothesay
12:51 - [21] City Hall
12:55 - [79] Polo Park via Kenaston
12:56 - [78] Polo Park via Kenaston
12:56 - [24] City Hall
12:59 - [11] North Kildonan via Donwood
... 
```
* Get the schedule info for the last stop you searched
```
hubot> hubot bus schedule 
hubot> Stop Number 10562 | Eastbound Portage at Tylehurst (Polo Park)
 Time - Route
12:49 - [11] Glenway
12:50 - [11] North Kildonan via Rothesay
12:51 - [21] City Hall
12:55 - [79] Polo Park via Kenaston
12:56 - [78] Polo Park via Kenaston
12:56 - [24] City Hall
12:59 - [11] North Kildonan via Donwood
...
```
## Configuration
You may set the below environment variables for further configuration options

| Environment variable | Required | Value | Notes |
| -------- | ----- | ----- | ----- |
| HUBOT_WPGTRANSIT_KEY | Required | (String) Winnipeg transit OpenData API Key | [Obtain a key here](https://api.winnipegtransit.com/home/users/new) |
| HUBOT_WPGTRANSIT_URL | Optional | (URL) Default: http://api.winnipegtransit.com/v2/ | Should not need to set this unless the API URL changes|
