require 'spec_helper'

describe Quorum::TblastnJob do

  before(:each) do
    @tblastn_job = Quorum::TblastnJob.new()
  end

  it "fails validation with poorly formatted expectation (using error_on)" do
    @tblastn_job.expectation = "this is bad"
    @tblastn_job.should have(1).error_on(:expectation)
  end

  it "passes validation with valid expectation values (using error_on)" do
    @tblastn_job.expectation = 12
    @tblastn_job.should have(0).errors_on(:expectation)
    @tblastn_job.expectation = 12.1201
    @tblastn_job.should have(0).errors_on(:expectation)
    @tblastn_job.expectation = "12e-10"
    @tblastn_job.should have(0).errors_on(:expectation)
    @tblastn_job.expectation = "2e+10"
    @tblastn_job.should have(0).errors_on(:expectation)
  end

  it "fails validation with poorly formatted max_score (using error_on)" do
    @tblastn_job.max_score = 12.34
    @tblastn_job.should have(1).error_on(:max_score)
    @tblastn_job.max_score = "not a number"
    @tblastn_job.should have(1).error_on(:max_score)
  end

  it "passed validation with valid max_score (using error_on)" do
    @tblastn_job.max_score = 1235
    @tblastn_job.should have(0).errors_on(:max_score)
  end

  it "fails validation with poorly formatted gap_opening_penalty (using error_on)" do
    @tblastn_job.gap_opening_penalty = "not a number"
    @tblastn_job.should have(1).error_on(:gap_opening_penalty)
    @tblastn_job.gap_opening_penalty = 100.10
    @tblastn_job.should have(1).error_on(:gap_opening_penalty)
  end

  it "passed validation with valid gap_opening_penalty (using error_on)" do
    @tblastn_job.max_score = 13
    @tblastn_job.should have(0).errors_on(:gap_opening_penalty)
  end

  it "fails validation with poorly formatted gap_extension_penalty (using error_on)" do
    @tblastn_job.gap_extension_penalty = "who are you?"
    @tblastn_job.should have(1).error_on(:gap_extension_penalty)
    @tblastn_job.gap_extension_penalty = 0.3
    @tblastn_job.should have(1).error_on(:gap_extension_penalty)
  end

  it "passed validation with valid gap_extension_penalty (using error_on)" do
    @tblastn_job.max_score = 456
    @tblastn_job.should have(0).errors_on(:gap_extension_penalty)
  end

  it "fails validation without selecting gap_opening_extension with gapped_alignment (using error_on)" do
    @tblastn_job.gapped_alignments = true
    @tblastn_job.gap_opening_extension = ""
    @tblastn_job.should have(1).error_on(:gap_opening_extension)
  end

  it "fails validation without selecting gap_opening_extension with gapped_alignment (using error_on)" do
    @tblastn_job.gapped_alignments = true
    @tblastn_job.gap_opening_extension = "11, 2"
    @tblastn_job.should have(0).errors_on(:gap_opening_extension)
  end

  it "gapped_alignment? returns true if gapped_alignments is set" do
    @tblastn_job.gapped_alignments = true
    @tblastn_job.gapped_alignment?.should be_true
  end

  it "gapped_alignment? returns false if gapped_alignments is not set" do
    @tblastn_job.gapped_alignments = false
    @tblastn_job.gapped_alignment?.should be_false
  end

  it "gap_opening_extension values should return an Array of Arrays" do
    @tblastn_job.gap_opening_extension_values.should eq(
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
    )
  end

end