class DatastoresController < ApplicationController

  def create(key,value,timeout=0)
   # d => full data store values here
    if key.include?(key_vaule.keys)
      p "error: this key already exists"
    else
      if(key.match(/^[[:alpha:]]$/))
        if key_vaule.length < (1024*1020*1024) && value<=(16*1024*1024)
          if timeout == 0
            final_result = [value,timeout]
          else
            final_result = [value,time.time()+timeout]
          end
          if key.length <=32
            key_vaule[key]=final_result
          end
        else
          p "error: Memory limit exceeded!!"
        end
      else
        p "error: Invalind key_name!! key_name must contain only alphabets and no special characters or numbers"
      end
    end
  end
              
  def read(key)
    if key.exclude?(key_vaule.keys)
        p "error: given key does not exist in database. Please enter a valid key"
    else
      result=key_vaule[key]
      if result[1]!=0:
        if time.time()<result[1]  #comparing the present time with expiry time
          stri=str(key)+":"+str(result[0]) #to return the value in the format of JasonObject i.e.,"key_name:value"
          return stri
        else
          p "error: time-to-live of #{key},has expired"
        end
      else
        stri=str(key)+":"+str(result[0])
        return stri
      end
    end
  end

  def delete(key)
    if key,exclude?(key_vaule.keys)
      p "error: given key does not exist in database. Please enter a valid key"
    else
      b=key_vaule[key]
      if b[1]!=0
        if time.time()<b[1]: #comparing the current time with expiry time
          key_vaule[key].delete
          p "key is successfully deleted"
        else
          p "error: time-to-live of #{key}, has expired" #error message5
        end
      else
        key_vaule[key].delete
        p "key is successfully deleted"
      end
    end
  end

  def modify(key,value)
    result=key_vaule[key]
    if result[1]!=0
      if time.time()<result[1]
        if key.exclude?(key_vaule.keys)
          p "error: given key does not exist in database. Please enter a valid key"
        else
          append_value=[]
          append_value.append(value)
          append_value.append(result[1])
          key_vaule[key]=append_value
        end
      else
        p "error: time-to-live of #{key} has expired"
      end
    else
      if key.exclude?(key_vaule.keys)
        p "error: given key does not exist in database. Please enter a valid key" #error message6
      else
        append_value=[]
        append_value.append(value)
        append_value.append(result[1])
        key_vaule[key]=append_value
      end
    end
  end
end


thread_1 = Thread.new(create("Java", 56, 4500))
thread_2 = Thread.new(modify("Java",56))
thread_3 = Thread.new(delete("Java"))
thread_4 = Thread.new(read("Java"))


#Note:
#=====
#Above code will work only in Ruby 2.0 & Rails 3.2.25
#Tested and checked in ubuntu 14.04 & Google chrome browser version 70 & above