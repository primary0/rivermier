# Requirements

* Redis
* Mongodb
* Ruby
* Rubygems
* God
* Bundler gem

# Setup

* Run bundle install.
* Fill in Twitter auth details in config/config.rb
* Setup God to initialize with the configuration file config/config.god

# Executables

**bin/daemon.rb** : Daemon script for launching Twitter streaming API listener. Run by God.

**bin/analytics.rb** : Trending topics analyzer script. Run by cron.

**bin/collect_users.rb** : Synchronize Twitter followings. Run by cron.

**bin/restart_script.sh** : Daemon restarter bash script, triggered by Event Machine’s on connection error event. Run by cron.

**bin/today_crawler.rb** : DailyDigest curator script. Run by cron.

**bin/indexer.rb** : Mongo indexer. Run by cron.

**bin/db_clean.rb** : Database clean up. Run by cron.

# Website

Sinatra app in website/config.ru