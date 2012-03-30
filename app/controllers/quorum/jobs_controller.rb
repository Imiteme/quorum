module Quorum
  class JobsController < ApplicationController

    respond_to :html, :json
    before_filter :set_blast_dbs, :only => [:new, :create]

    def index
      redirect_to :action => "new"
    end

    def new
      @job = Job.new
      @job.build_blastn_job
      @job.build_blastx_job
      @job.build_tblastn_job
      @job.build_blastp_job
    end

    def create
      if params[:job][:sequence_file]
        file = params[:job][:sequence_file].read
        params[:job].delete(:sequence_file)
      end

      @job = Job.new(params[:job])

      if file
        @job.sequence = ""
        @job.sequence << file
      end

      unless @job.save
        @job.build_blastn_job  if @job.blastn_job.nil?
        @job.build_blastx_job  if @job.blastx_job.nil?
        @job.build_tblastn_job if @job.tblastn_job.nil?
        @job.build_blastp_job  if @job.blastp_job.nil?
        render :action => "new"
        return
      end
      redirect_to job_path(@job.id)
    end

    def show
      begin
        @jobs = Job.find(params[:id])
      rescue ActiveRecord::RecordNotFound => e
        set_flash_message(:notice, :data_not_found)
        redirect_to :action => "new"
      end
    end

    #
    # Returns Resque worker results.
    #
    def get_quorum_search_results
      empty = [{ :results => false }].to_json

      json = empty

      if Quorum::BLAST_ALGORITHMS.include?(params[:algo])
        queued = "#{params[:algo]}_job".to_sym
        report = "#{params[:algo]}_job_reports".to_sym

        begin
          job = Job.find(params[:id])
        rescue ActiveRecord::RecordNotFound => e
          json = empty
        else
          if job.method(queued).call.present?
            if job.method(report).call.present?
              if params[:query]
                json = job.method(report).call.by_query(params[:query]).default_order
              else
                json = job.method(report).call.default_order
              end
            else
              json = []
            end
          end
        end
      end

      respond_with json
    end

    #
    # Find hit sequence, queue worker and return worker meta_id
    # for lookup.
    #
    def get_quorum_blast_hit_sequence
      json = []

      if Quorum::BLAST_ALGORITHMS.include?(params[:algo])
        begin
          job = Job.find(params[:id])
        rescue ActiveRecord::RecordNotFound => e
          logger.error e.message
        else
          data = job.fetch_quorum_blast_sequence(
            params[:algo], params[:algo_id]
          )
          json = [{ :meta_id => data.meta_id }]
        end
      end

      respond_with json
    end

    #
    # Send Blast hit sequence as attached file or render
    # error message as text.
    #
    # See lib/generators/templates/blast_db.rb for more info.
    #
    def send_quorum_blast_hit_sequence
      data = Workers::System.get_meta(params[:meta_id])
      if data.succeeded?
        unless data.result.downcase.include?("error")
          send_data data.result,
            :filename    => "#{params[:meta_id]}.fa",
            :type        => "text/plain",
            :disposition => "attachment"
          return
        else
          render :text => data.result
          return
        end
      end
      render :text => ""
    end

    private

    #
    # Blast Database options for select.
    #
    def set_blast_dbs
      @blast_dbs = {
        :blastn  => Quorum.blastn,
        :blastx  => Quorum.blastx,
        :tblastn => Quorum.tblastn,
        :blastp  => Quorum.blastp
      }
    end

  end
end
