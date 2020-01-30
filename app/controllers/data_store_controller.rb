require 'fileutils'
require 'httparty'
require 'net/http'
require 'uri'
require 'json'

class Datastores
  
  def initialize(file=nil)
    if file.blank?
      file = "local_storage"
    else
      file = file
    end
    # Creating root path by calling helpers
    save_file(file)
  end

  def delete(key)
    is_key_expired?(key)
    if @content.key?(key)
      @content.delete(key)
      save_data
    else
      raise DataStore::Error, "Key '#{key}' does not exist in the data store"
    end
  end

  def read(key)
    is_key_expired?(key)
    # Check whether the key has exist or not.
    if @content.key?(key)
      p "Key is #{@content[key][0]}"
    else
      raise DataStore::Error, "Key '#{key}' does not exist in the data store"
    end
  end

  def create(key, value, time_to_live=0)
    if @file.size < (1024*1024*1024) # Checking file size never exceeds 1GB
      # Ensure the key and value are in valid format.
      if is_valid_key?(key) && is_valid_json?(value)
        is_key_expired?(key)
        raise DataStore::Error, "Time to live should be in Integer type." unless time_to_live.is_a?(Integer)
        # If Create is invoked for an existing key
        if @content.key?(key)
          raise DataStore::Error, "Key '#{key}' already exist in the data store.Please try with different name."      
        else
          # create and save the data in to the file.
          time_to_live = time_to_live.zero? ? time_to_live : (Time.now + time_to_live)
          @content[key] = [value, time_to_live]
          save_data
        end
      end
    else
      raise DataStore::Error, "File size exceeds maximum limit of 1GB"
    end
  end


  #Time-To-Live checking for a key has expired or not.
  def is_key_expired?(key)
    #calling helper method to check Time to live property
    is_key_expired?(key)
  end

  # To write and update the data in to the data store.
  def save_data
    #calling helpers to save the data
    save_data(@file_path)
  end

  # Method to check for a valid json.
  def is_valid_json?(value)
    begin
      # The value is always a JSON object - capped at 16KB.
      json_size = JSON.parse(value.to_json).to_s.bytesize
      if json_size <= 16*1024
        return true
      else
        raise DataStore::Error, "JSON size should be <= 16KB"
      end
    rescue JSON::ParserError => e
      raise DataStore::Error, "Value should be always a JSON object"
    end
  end

end

thread_1 = Thread.new(create("Java", {"authour_name"=>"Steve","published_at"=> "20-10-1993", "edition"=>"5th"}, 4500))
thread_2 = Thread.new(delete("Java"))
thread_3 = Thread.new(read("Java"))


#Note:
#=====
#Above code will work only in Ruby 2.0.0
#Tested and checked in ubuntu 14.04 & Google chrome browser version 70 & above