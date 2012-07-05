God.watch do |w|

	w.name = "Rivermier"
	w.group = "rivermier"
	w.dir = "/home/rivermier/app/bin"
	w.start = "./daemon.rb start"
	w.restart = "./daemon.rb restart"
	w.stop = "./daemon.rb stop"
	w.uid = 'rivermier'
	w.gid = 'rivermier'
	w.interval = 5.seconds	
	
  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 5.seconds
      c.running = false
    end
  end
  
  w.restart_if do |restart|
    restart.condition(:memory_usage) do |c|
      c.above = 200.megabytes
      c.times = [3, 5] # 3 out of 5 intervals
    end
  
    restart.condition(:cpu_usage) do |c|
      c.above = 90.percent
      c.times = 5
    end
  end
  
  w.lifecycle do |on|
    on.condition(:flapping) do |c|
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 5.minute
      c.transition = :unmonitored
      c.retry_in = 10.minutes
      c.retry_times = 5
      c.retry_within = 2.hours
    end
  end

end


3.times do |x|

	God.watch do |w|

		w.name = "Resque-#{x}"
		w.group = "resque"
		w.dir = "/home/rivermier/app"
		w.start = "QUEUE=* rake resque:work"
		w.uid = 'rivermier'
		w.gid = 'rivermier'
		w.interval = 30.seconds
	
	  w.start_if do |start|
	    start.condition(:process_running) do |c|
	      c.interval = 5.seconds
	      c.running = false
	    end
	  end
  
	  w.restart_if do |restart|
	    restart.condition(:memory_usage) do |c|
	      c.above = 200.megabytes
	      c.times = [3, 5] # 3 out of 5 intervals
	    end
  
	    restart.condition(:cpu_usage) do |c|
	      c.above = 90.percent
	      c.times = 5
	    end
	  end
  
	  w.lifecycle do |on|
	    on.condition(:flapping) do |c|
	      c.to_state = [:start, :restart]
	      c.times = 5
	      c.within = 5.minute
	      c.transition = :unmonitored
	      c.retry_in = 10.minutes
	      c.retry_times = 5
	      c.retry_within = 2.hours
	    end
	  end
	
	end
end