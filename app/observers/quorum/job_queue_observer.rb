module Quorum
  class JobQueueObserver < ActiveRecord::Observer

    observe Quorum::Job

    def after_create(job)
      Quorum::JobQueueService.queue_search_workers(job)
    end

  end
end
