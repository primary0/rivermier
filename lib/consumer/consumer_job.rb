class ConsumerJob < Consumer

  def before(job)
    clear_queue
  end  

  def success(job)
    clear_queue
  	add_new_job
  end

  def error(job, exception)
    clear_queue
    add_new_job
  end

  def failure
    clear_queue
    add_new_job
  end	

  def add_new_job
  	sleep 15
  	Delayed::Job.enqueue ConsumerJob.new, queue: "consumer"
  end

  def clear_queue
    Delayed::Job.where(queue: 'consumer').destroy_all
  end
end