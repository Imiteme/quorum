module Quorum
  class BlastxJob < ActiveRecord::Base

    before_validation :check_blast_dbs, :if => :queue

    before_save :set_optional_params, :set_blast_dbs

    belongs_to :job
    has_many :blastx_job_reports,
      :dependent   => :destroy,
      :foreign_key => :blastx_job_id,
      :primary_key => :job_id

    validates_format_of :expectation,
      :with        => /\A[+-]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?\z/,
      :message     => " - Valid formats (12, 32.05, 43e-123)",
      :allow_blank => true
    validates_numericality_of :max_target_seqs,
      :only_integer => true,
      :allow_blank  => true
    validates_numericality_of :min_bit_score,
      :only_integer => true,
      :allow_blank  => true
    validates_numericality_of :gap_opening_penalty,
      :only_integer => true,
      :allow_blank  => true
    validates_numericality_of :gap_extension_penalty,
      :only_integer => true,
      :allow_blank  => true
    validates_presence_of :blast_dbs, :if => :queue

    #
    # Gapped alignment helper.
    #
    def gapped_alignment?
      self.gapped_alignments
    end

    #
    # Valid gap opening and extension values.
    #
    def gap_opening_extension_values
      [
        ['--Select--', ''],
        ['32767, 32767', '32767,32767'],
        ['11, 2', '11,2'],
        ['10, 2', '10,2'],
        ['9, 2', '9,2'],
        ['8, 2', '8,2'],
        ['7, 2', '7,2'],
        ['6, 2', '6,2'],
        ['13, 1', '13,1'],
        ['12, 1', '12,1'],
        ['11, 1', '11,1'],
        ['10, 1', '10,1'],
        ['9, 1', '9,1']
      ]
    end

    #
    # Virtual attribute getter.
    #
    def gap_opening_extension
      [gap_opening_penalty, gap_extension_penalty].join(',')
    end

    #
    # Virtual attribute setter.
    #
    def gap_opening_extension=(value)
      v = value.split(',')
      self.gap_opening_penalty   = v.first
      self.gap_extension_penalty = v.last
    end

    private

    def check_blast_dbs
      if self.blast_dbs.present?
        self.blast_dbs = self.blast_dbs.gsub(/[^a-zA-Z,]/, "").split(",").delete_if { |b| b.empty? }
      end
    end

    def set_blast_dbs
      if self.blast_dbs.present?
        self.blast_dbs = self.blast_dbs.gsub(/[^a-zA-Z,]/, "").join(';')
      end
    end

    def set_optional_params
      self.expectation = "5e-20" if self.expectation.blank?
      self.max_target_seqs ||= 25
      self.min_bit_score ||= 0
      self.gap_opening_penalty ||= nil
      self.gap_extension_penalty ||= nil
    end

  end
end
