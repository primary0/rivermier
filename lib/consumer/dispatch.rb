class Dispatch
  def self.perform(item)    
    if (item && item["retweeted_status"] && item["user"]["id_str"] != $LOGGED_IN_USER_ID && item["retweeted_status"]["user"]["id_str"] != $LOGGED_IN_USER_ID) || (item && item["text"] && item["user"]["id_str"] != $LOGGED_IN_USER_ID)
      Tweet.delay.perform(item)
    end
    if item && item["delete"] && item["delete"]["status"] && item["delete"]["status"]["id_str"]
      Delete.delay.perform(item["delete"]["status"]["id_str"])
    end
  end
end
