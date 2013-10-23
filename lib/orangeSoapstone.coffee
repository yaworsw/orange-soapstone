fs   = require 'fs'
path = require 'path'

Twit = require 'twit'

# Resolve a file path for a configuration file
resolve_config_file = (file_name) ->
  path.resolve(__dirname, '..', 'config', file_name)

# Read a json config file.  No extension required
parse_config_file = (file_name) ->
  JSON.parse(fs.readFileSync(resolve_config_file(file_name + '.json'), 'utf8'))

# Wrapper to switch the arguments for setTimeout
set_timeout = (interval, callback) ->
  setTimeout(callback, interval)

# Returns a random integer between the arguments
random_between = (min, max) ->
  parseInt(Math.random() * (max - min) + min)

# Returns a random number between the interval min and max settings
interval = () ->
  random_between config.settings['interval-min'], config.settings['interval-max']

# Tweets a random one of the messages
tweet_random_message = () ->
  message = messages[random_between(0, messages.length - 1)]
  console.log ''
  console.log 'Tweeting:'
  console.log message
  twit.post 'statuses/update', { status: message }, (->)

# Tweets a random message and then schedules the next tweet
tweet_loop = () ->
  tweet_random_message()
  schedule_next_tweet()

# Schedules a tweet
schedule_next_tweet = (i) ->
  unless i?
    i = interval()
  console.log ''
  console.log "Tweeting again in: #{i / 3600000} hours" # 3600000 = # of milliseconds in an hour
  set_timeout i, tweet_loop

config   = parse_config_file 'config'
messages = parse_config_file 'all_messages'

twit = new Twit config.twitter

args = process.argv.slice(2)
next = 0
if args.length != 0
  next = parseFloat(args[0]) || next
next *= 3600000

schedule_next_tweet(next)
