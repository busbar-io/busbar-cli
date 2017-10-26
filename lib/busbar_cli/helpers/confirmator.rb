class Confirmator
  class << self
    def confirm(question:, exit_message: 'Exiting without destroying the resource')
      puts question + "\n(Y/N)"

      input = STDIN.gets.chomp

      return if input.downcase[0] == 'y'

      puts exit_message
      exit 0
    end
  end
end
