require 'thread'
require 'timeout'

class TimedQueue
  def initialize
    @que = []
    @mutex = Mutex.new
    @resource = ConditionVariable.new
  end

  def push(obj)
    @mutex.synchronize do
      @que.push obj
      @resource.signal
    end
  end
  alias << push

  def timed_pop(timeout=0.5)
    while true
      @mutex.synchronize do
        if @que.empty?
          @resource.wait(@mutex, timeout)
          raise TimeoutError if @que.empty?
        else
          retval = @que.shift
          @resource.signal
          return retval
        end
      end
    end
  end

  def empty?
    @que.empty?
  end

  def clear
    @que.clear
  end

  def length
    @que.length
  end
end
