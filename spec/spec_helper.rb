require './init'

# Duplicated from the Heroku gem
def prepare_command(klass)
  command = klass.new
  command.stub!(:app).and_return("myapp")
  command.stub!(:ask).and_return("")
  command.stub!(:display)
  command.stub!(:hputs)
  command.stub!(:hprint)
  command.stub!(:heroku).and_return(mock('heroku client', :host => 'heroku.com'))
  command
end
