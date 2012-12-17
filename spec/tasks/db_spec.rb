require 'spec_helper'
require 'tasks/build/db'

describe "db rake tasks" do
  describe "rake quorum:blastdb:build" do
    before(:each) do
      # Set args as though we executed the rake task.
      @args = {
        :dir         => File.expand_path("../../data/tmp",  __FILE__),
        :empty       => false,
        :type        => "both",
        :prot_file   => "peptides.fa",
        :nucl_file   => "contigs.fa",
        :rebuild_db  => true,
        :blastdb_dir => File.expand_path(
          "../../dummy/quorum/blastdb", __FILE__
        ),
        :gff_dir     => File.expand_path(
          "../../dummy/quorum/gff3", __FILE__
        ),
        :log_dir     => File.expand_path(
          "../../dummy/quorum/log", __FILE__
        )
      }
    end

    it "raises exception without DIR argument" do
      expect {
        Quorum::Db::Blast.new({}).build_blast_db_data
      }.to raise_error(
        RuntimeError,
        'DIR must be set to continue. Execute `rake -D` for more information.'
      )
    end

    it "raises exception with unknown TYPE" do
      @args[:type] = "unknown"
      expect {
        Quorum::Db::Blast.new(@args).build_blast_db_data
      }.to raise_error(
        RuntimeError,
        "Unknown type: #{@args[:type]}. Please provide one: both, nucl or prot."
      )
    end

    it "raise exception with unknown directory" do
      @args[:dir] = "foo_bar_baz"
      @build = Quorum::Db::Blast.new(@args)
      expect {
        @build.build_blast_db_data
        @build.stub(:check_dependencies)
        @build.stub(:make_directories)
      }.to raise_error(
        RuntimeError,
        "Directory not found: foo_bar_baz"
      )
    end

    it "raise exception without correct data directory" do
      @args[:dir] = File.dirname( __FILE__)
      @build = Quorum::Db::Blast.new(@args)
      expect {
        @build.build_blast_db_data
        @build.stub(:check_dependencies)
        @build.stub(:make_directories)
      }.to raise_error(
        RuntimeError,
        "Data not found. Please check your directory and try again.\n" <<
        "Directory Entered: #{File.dirname(__FILE__)}"
      )
    end

    it "creates directories and ignores makeblastdb if empty is true" do
      # Suppress printing to STDOUT.
      output = double("IO")
      output.stub(:puts)
      output.stub(:print)

      @args[:empty] = true
      @build = Quorum::Db::Blast.new(@args, output)

      expect {
        @build.build_blast_db_data
      }.to_not raise_error

      File.directory?(@args[:blastdb_dir]).should be_true
      File.directory?(@args[:gff_dir]).should be_true
    end

    it "builds Blast database with valid arguments" do
      # Suppress printing to STDOUT.
      output = double("IO")
      output.stub(:puts)
      output.stub(:print)

      @args[:empty] = false
      @build = Quorum::Db::Blast.new(@args, output)

      expect {
        @build.build_blast_db_data
      }.to_not raise_error

      ## Make sure build_blast_db_data created files and directories ##

      Dir.glob(@args[:blastdb_dir]).length.should be > 0

      File.exists?(
        File.join(@args[:blastdb_dir], "test", "contigs.fa")
      ).should be_true

      File.exists?(
        File.join(@args[:blastdb_dir], "test", "peptides.fa")
      ).should be_true

      File.directory?(@args[:gff_dir]).should be_true
    end
  end

  describe "rake quorum:gmapdb:build" do
    before(:each) do
      # Set args as though we executed the rake task.
      @args = {
        :dir         => File.expand_path("../../data/tmp",  __FILE__),
        :empty       => false,
        :rebuild_db  => true,
        :gmapdb_dir  => File.expand_path(
          "../../dummy/quorum/gmapdb", __FILE__
        ),
        :log_dir     => File.expand_path(
          "../../dummy/quorum/log", __FILE__
        )
      }
    end

    it "raises exception without DIR argumenta" do
      expect {
        Quorum::Db::Gmap.new({}).build_gmap_db_data
      }.to raise_error(
        RuntimeError,
        'DIR must be set to continue. Execute `rake -D` for more information.'
      )
    end

    it "raise exception with unknown directory" do
      @args[:dir] = "foo_bar_baz"
      @build = Quorum::Db::Gmap.new(@args)
      expect {
        @build.build_gmap_db_data
        @build.stub(:check_dependencies)
        @build.stub(:make_directories)
      }.to raise_error(
        RuntimeError,
        "Directory not found: foo_bar_baz"
      )
    end

    it "raise exception without correct data directory" do
      @args[:dir] = File.dirname( __FILE__)
      @build = Quorum::Db::Gmap.new(@args)
      expect {
        @build.build_gmap_db_data
        @build.stub(:check_dependencies)
        @build.stub(:make_directories)
      }.to raise_error(
        RuntimeError,
        "Data not found. Please check your directory and try again.\n" <<
        "Directory Entered: #{File.dirname(__FILE__)}"
      )
    end

    it "creates directories and ignores gmap_build if empty is true" do
      # Suppress printing to STDOUT.
      output = double("IO")
      output.stub(:puts)
      output.stub(:print)

      @args[:empty] = true
      @build = Quorum::Db::Gmap.new(@args, output)

      expect {
        @build.build_gmap_db_data
      }.to_not raise_error

      File.directory?(@args[:gmapdb_dir]).should be_true
    end

    it "builds Gmap database with valid arguments" do
      # Suppress printing to STDOUT.
      output = double("IO")
      output.stub(:puts)
      output.stub(:print)

      @args[:empty] = false
      @build = Quorum::Db::Gmap.new(@args, output)
      @build.stub(:check_dependencies)

      sys = "gmap_build -D #{@args[:gmapdb_dir]} -d test " <<
        "-T #{@args[:gmapdb_dir]} -g #{@args[:dir]}/test.fa.gz " <<
        ">> #{@args[:log_dir]}/gmap_build.log 2>&1"

      @build.should_receive("system").with(sys)

      expect {
        @build.build_gmap_db_data
      }.to_not raise_error
    end
  end
end
