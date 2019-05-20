class InMemory
  # these 10 lines of code implements singleton pattern to create instance with filename property
  # Ruby's inbuilt singleton doesn't support passing parameters to the instance so we used our own implementation
  @@singleton__instance__ = nil
  @@singleton__mutex__ = Mutex.new
  def self.instance file_name
    return @@singleton__instance__ if @@singleton__instance__
    @@singleton__mutex__.synchronize {
      return @@singleton__instance__ if @@singleton__instance__
      @@singleton__instance__ = new(file_name)
    }
    @@singleton__instance__
  end

  # instance method to start reading the file
  # infinite loop with sleep time 30 seconds
  # read file if the file modified otherwise return from memory
  def read
    while true
      if !@file_content.nil?
        if file_notmodified?
          puts('file not modified')
          puts(@file_content)
          sleep(30)
        end
        synchronized { calc { File.read(@file_name) } }
        sleep(30)
      end
      synchronized { calc { File.read(@file_name) } }
      sleep(30)
    end
  end

  # write file to cache
  def write
    synchronized do
      @file_content = File.read(@file_name)
    end
  end

  #check if the file content exists in cache
  # if hash
  def exists?
    if !@file_content.nil?
      true
    elsif !file_notmodified?
      @file_content = nil
      false
    else
      false
    end
  end

  private
  def initialize file_name
    @file_content = nil
    @file_name = file_name
    @sync = true
    @start_time = Time.now
    @mutex = Mutex.new
  end

  # update @file_content in case the file is modified
  def calc
    @file_content = yield
    puts('file modified')
    puts(@file_content)
  end

  def file_notmodified?
    @file_content == File.read(@file_name)
  end

  def synchronized
    @mutex.synchronize do
      sleep 0.00001
      yield
    end
  end
  private_class_method :new
end

# create instance with filename and read file example_1.json
inst = InMemory.instance 'example_1.json'
inst.read