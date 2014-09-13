def capistrano namespace, task, name="config/deploy"
  require 'capistrano'
  require 'capistrano/cli'

  config = Capistrano::Configuration.new
  config.logger.level = Capistrano::Logger::TRACE
  config.set(:password) { Capistrano::CLI.password_prompt }
  config.load name

  config.execute_task config.namespaces[namespace.to_sym].tasks[task.to_sym]
end
