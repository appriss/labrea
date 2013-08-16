# labrea_spec.rb
require 'labrea'

describe Labrea do
  labrea = Labrea.new("test/source/test.tgz", "test/install", ['checksum.txt'])
  labreaZip = Labrea.new("test/source/test.zip", "test/install", ['checksum.txt'])

  describe "install", 'tgz' do
    file = "test/install/test_tgz.txt"

    labrea.install()
    it "should extract the file test/install/test_tgz.txt" do
      File.exist?(file).should be_true
    end
  end
  
  describe "verify", 'tgz' do
   it "should verify the sha1sums of installed files against the checksum.txt file" do
     labrea.verify().should eql(0)
   end
   
   it "should verify that a file has changed" do
    File.delete("test/install/test_tgz.txt")
    puts File.exists?("test/install/test_tgz.txt")
    labrea.verify().should eql(1)
   end
   
   it "should verify that a file has not been changed" do
     labrea.verify().should eql(0)
   end
   
   it "should cleanup after test" do
      Dir.glob("test/install/**/*.*") do |file|
	if File.exists?(file)
	  File.delete(file)
	end
      end
    end
  end
  
#   describe "install", 'zip' do
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
      labrea.filetype("test.tgz").should equal(:tgz)
    end
    
    it "should have the file format of tgz" do  
      labrea.filetype("test.tar.gz").should equal(:tgz)
    end
    
    it "should not have the file format of zip" do
      labrea.filetype("test.zip").should_not equal(:tgz)
    end

    it "should not have the file format of bz2" do
      labrea.filetype("test.bz2").should_not equal(:tgz)
    end  
  end

  describe "filetype", 'tar.gz' do    
    it "should have the file format of tgz" do  
      labrea.filetype("test.tgz").should equal(:tgz)
    end
    
    it "should have the file format of tgz" do  
      labrea.filetype("test.tar.gz").should equal(:tgz)
    end
    
    it "should not have the file format of zip" do
      labrea.filetype("test.zip").should_not equal(:tgz)
    end

    it "should not have the file format of bz2" do
      labrea.filetype("test.bz2").should_not equal(:tgz)
    end  
  end

  describe "filetype", 'zip' do    
    it "should have the file format of tgz" do  
      labrea.filetype("test.tgz").should_not equal(:zip)
    end
    
    it "should have the file format of tgz" do  
      labrea.filetype("test.tar.gz").should_not equal(:zip)
    end
    
    it "should not have the file format of zip" do
      labrea.filetype("test.zip").should equal(:zip)
    end

    it "should not have the file format of bz2" do
      labrea.filetype("test.bz2").should_not equal(:zip)
    end  
  end

  describe "filetype", 'bz2' do    
    it "should have the file format of tgz" do  
      labrea.filetype("test.tgz").should_not equal(:bz2)
    end
    
    it "should have the file format of tgz" do  
      labrea.filetype("test.tar.gz").should_not equal(:bz2)
    end
    
    it "should not have the file format of zip" do
      labrea.filetype("test.zip").should_not equal(:bz2)
    end

    it "should not have the file format of bz2" do
      labrea.filetype("test.bz2").should equal(:bz2)
    end  
  end
end