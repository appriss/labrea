# labrea_spec.rb
require 'labrea'
require 'fileutils'

describe Labrea do
  before(:all) do
    @labrea = Labrea.new("test/source/test.tgz", "test/install", :exclude => ['checksum.json', 'dir1/test_tgz.txt'])
    @labrea2 = Labrea.new("test/source/test.zip", "test/install", :exclude => ['checksum.json', 'dir1/test_tgz.txt', 'dir2/test_tgz.txt'])
    @labrea3 = Labrea.new("test/source/test.tgz", "test/install", :checksum_file => 'checkmate.json', :exclude => ['checksum.json', 'dir1/test_tgz.txt'])
    @changeset = nil
    @file1 = "test/install/test_tgz.txt"
    @file2 = "test/install/dir1/test_tgz.txt"
    @file3 = "test/install/dir2/test_tgz.txt"
  end

  after(:all) do
    Dir.glob("test/install/**/*.*") do |file|
      if File.exists?(file)
	File.delete(file)
      end
    end
  end

  describe "install, tgz" do
    FileUtils.rm_rf("test/install")
    Dir.mkdir("test/install") unless File.exists?("test/install")

    context "dry-run" do
      it "should not install the package" do
	@labrea.install(true)
	File.exist?(@file1).should be_false
	File.exist?(@file2).should be_false
	File.exist?(@file3).should be_false
	File.exist?('test/install/checksum.json').should be_true
      end
    end

    context "install", 'tgz' do
      it "should extract the files [#{@file1},#{@file2},#{@file3}] and have a valid changeset" do
	@changeset = @labrea.install()
	@changeset.should_not == nil
	File.exist?(@file1).should be_true
	File.exist?(@file2).should be_true
	File.exist?(@file3).should be_true
	File.exist?('test/install/checksum.json').should be_true
      end
    end

    context "custom checksum_file" do
      it "should use the custom checksum file" do
	@changeset = @labrea3.install()
	@changeset.should_not == nil
	File.exist?(@file1).should be_true
	File.exist?(@file2).should be_true
	File.exist?(@file3).should be_true
	File.exist?('test/install/checkmate.json').should be_true
      end
    end
  end

  describe "verify", 'tgz' do
    context "dry-run" do
      it "should not update any files" do
	changeset = @labrea.verify(true)
	changeset.should_not == nil
	changeset.length.should eql(0)
      end

      it "should see the change for test_tgz.txt" do
	File.delete("test/install/test_tgz.txt")
	changeset = @labrea.verify(true)
	changeset[0].should eql("test_tgz.txt")
	changeset.length.should eql(1)
	File.exists?("test/install/test_tgz.txt").should be_false
      end

      it "should not see the change for dir1/test_tgz.txt" do
	File.delete("test/install/dir1/test_tgz.txt") if File.exists?("test/install/dir1/test_tgz.txt")
	changeset = @labrea.verify(true)
	changeset[0].should eql("test_tgz.txt")
	changeset.length.should eql(1)
	File.exists?("test/install/dir1/test_tgz.txt").should be_false
      end
    end

    context "verify" do
      it "should verify that a file has changed" do
	File.delete("test/install/test_tgz.txt") if File.exists?("test/install/test_tgz.txt")
	changeset = @labrea.verify()
	changeset[0].should eql("test_tgz.txt")
	changeset.length.should eql(1)
      end

      it "should not verify that a file has changed" do
	File.delete("test/install/dir1/test_tgz.txt") if File.exists?("test/install/dir1/test_tgz.txt")
	changeset = @labrea.verify()
	changeset.length.should eql(0)
      end

      it "should verify that a file has not been changed" do
	changeset = @labrea.verify()
	changeset.length.should eql(0)
      end

      it "should not verify the new file added to the exclude list" do
	File.delete("test/install/dir2/test_tgz.txt") if File.exists?("test/install/dir2/test_tgz.txt")
	changeset = @labrea2.verify()
	changeset.length.should eql(0)
      end
    end
  end

#   describe "install", 'zip' do
#     FileUtils.rm_rf("test/install")
#     Dir.mkdir("test/install")
#     file = "test/install/test_zip.txt"
#
#     labreaZip.install()
#     it "should extract the file test/install/test_zip.txt" do
#       File.exist?(file).should be_true
#     end
#   end
#
#   describe "verify", 'zip' do
#    it "should verify the sha1sums of installed files against the checksum.txt file" do
#      labreaZip.verify().should eql(0)
#    end
#
#    it "should verify that a file has changed" do
#     File.delete("test/install/test_zip.txt")
#     puts File.exists?("test/install/test_zip.txt")
#     labreaZip.verify().should eql(1)
#    end
#
#    it "should verify that a file has not been changed" do
#      labreaZip.verify().should eql(0)
#    end
#
#    it "should cleanup after test" do
#       Dir.glob("test/install/**/*.*") do |file|
# 	if File.exists?(file)
# 	  File.delete(file)
# 	end
#       end
#     end
#   end

  describe "filetype", 'tgz' do
    it "should have the file format of tgz" do
      @labrea.filetype("test.tgz").should equal(:tgz)
    end

    it "should have the file format of tgz" do
      @labrea.filetype("test.tar.gz").should equal(:tgz)
    end

    it "should not have the file format of zip" do
      @labrea.filetype("test.zip").should_not equal(:tgz)
    end

    it "should not have the file format of bz2" do
      @labrea.filetype("test.bz2").should_not equal(:tgz)
    end
  end

  describe "filetype", 'tar.gz' do
    it "should have the file format of tgz" do
      @labrea.filetype("test.tgz").should equal(:tgz)
    end

    it "should have the file format of tgz" do
      @labrea.filetype("test.tar.gz").should equal(:tgz)
    end

    it "should not have the file format of zip" do
      @labrea.filetype("test.zip").should_not equal(:tgz)
    end

    it "should not have the file format of bz2" do
      @labrea.filetype("test.bz2").should_not equal(:tgz)
    end
  end

  describe "filetype", 'zip' do
    it "should have the file format of tgz" do
      @labrea.filetype("test.tgz").should_not equal(:zip)
    end

    it "should have the file format of tgz" do
      @labrea.filetype("test.tar.gz").should_not equal(:zip)
    end

    it "should not have the file format of zip" do
      @labrea.filetype("test.zip").should equal(:zip)
    end

    it "should not have the file format of bz2" do
      @labrea.filetype("test.bz2").should_not equal(:zip)
    end
  end

  describe "filetype", 'bz2' do
    it "should have the file format of tgz" do
      @labrea.filetype("test.tgz").should_not equal(:bz2)
    end

    it "should have the file format of tgz" do
      @labrea.filetype("test.tar.gz").should_not equal(:bz2)
    end

    it "should not have the file format of zip" do
      @labrea.filetype("test.zip").should_not equal(:bz2)
    end

    it "should not have the file format of bz2" do
      @labrea.filetype("test.bz2").should equal(:bz2)
    end
  end
end
