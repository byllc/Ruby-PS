##
# Author: Bill Chapman
# Name: Ruby PS
# Description: Some process management helpers for linux based systems
# Usage:
#
#  ps.initialize(:irb)  #find all processes with irb in the ps output row
#  ps.kill_if{ |row| row[:mem].to_f > 800.0} #kill all processes in the ps recordset that are greater than 800mb
#  -- OR --
#  PS.kill_if(:irb){ |row| row[:mem].to_f > 800.0 }
class PS
    attr_accessor :slug
  
    #the order sensitive headings list for the command 'ps aux'
    PS_HEADINGS =  [:user,:pid,:cpu,:mem,:vsz,:rss,:tt,:stat,:started,:time]    

    ##
    # @params a slug to grep out of a process detail string, can be a symbol or a string
    def initialize(slug)
     @slug = slug.to_s
    end
    
    def kill_if(&block)
      process_list = self.run
      
      process_list.each do |row|
        if(yield(row))
          `kill -9 #{row[:pid]}`
          puts "Killing process with pid #{row[:pid]}"
        else
          puts "Process with pid #{row[:pid]} OK. Not killed"
        end
      end
    end
    
    ##
    # Run PS and filter by the given slug
    def run
      output = `ps aux | grep #{@slug}`
      rows = output.split("\n")    
      
      rows.map do |row|
        row_array = row.split(" ")
        
        #initialize hash and reassemble the command rows
        ps_hash = {:command => row_array[10..-1].join(" ")}
        PS_HEADINGS.each_with_index do |column,index|
          puts index
          ps_hash[column] = row_array[index]
        end
        
        ps_hash
      end
    end
    
    
    def self.kill_if(slug,&block)
      ps = PS.new(slug)
      ps.kill_if(&block)
    end
  
end

