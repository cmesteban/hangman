require_relative "serialize"

class Game
  include Serialize
  attr_reader :secret_word, :guessed_word, :guesses_left, :guessed_letters

  def initialize
    @secret_word = get_secret_word
    @guessed_word = get_blank_word
    @guesses_left = 12
    @guessed_letters = []
  end

  def get_secret_word
    dictionary = File.readlines('5desk.txt', chomp: true)
    dictionary.select! do |word| #changes the dictionary to only inclue words in that size
      word.length.between?(5,12)
    end
    dictionary.sample.upcase.chars #randomly chooses one of the words and capitalizes it and turns it into an array 
  end

  def get_blank_word
    secret_word.map { |char| "_"}
  end

  def won?
    guessed_word == secret_word
  end

  def over?
    won? || guesses_left == 0
  end

  def start
    check_if_load
    game_loop
    check_result
  end

  def game_loop
    until over?
      display
      print "\nGuess a letter or enter 'save' to save game: "
      guess = gets.chomp.upcase
      check_save(guess)
      next if invalid?(guess)#starts loop over if its invalid
      update(guess)
    end
  end

  def display
    puts "\n---------------------------------------------"
    puts "Number of guesses left: #{guesses_left}"
    puts "The letters you have guessed are: #{guessed_letters.join}"
    puts "#{guessed_word.join(" ")}"
  end

  def invalid?(guess)
    if guess.length >1 || ("A".."Z").to_a.none?{|char| char == guess}
      puts "\n*Invalid Entry, Please Try Again*"
      true
    elsif guessed_letters.include?(guess)
      puts "\n*This letter has already been guessed! Try Again!*"
      true
    end
  end

  def update(guess)
    correct = false
    secret_word.each_with_index do |letter, index|
      if letter == guess
        @guessed_word[index] = letter
        correct = true
      end
    end
    if correct == false
      @guesses_left -= 1
    end
    guessed_letters << guess #adds guess to list of guessed letters
  end

  def save_game
    Dir.mkdir("saved_games") unless Dir.exists?("saved_games")

    saved_game = "saved_games/saved_game"

    File.open(saved_game, "w"){ |file| file.puts self.serialize}

    puts "\n Game Saved! Come Back!"

    exit 
  end

  def check_save(input)
    save_game if input == "SAVE"
  end

  def check_result
    display

    if won?
      puts "\n***Congratulations, you correctly found the secret word: #{secret_word.join} ***"
    else  
      puts "\n***Sorry, not today buddy. The secret word was: #{secret_word.join} ***"
    end
  end

  def load_game
    saved_game = "saved_games/saved_game"
    data = File.read(saved_game)

    self.unserialize(data)

    puts "\nHello! Good to see you back!"
  end

  def check_if_load
    if File.exists?("saved_games/saved_game")
      print "Do you want to load a saved game? (Y/N): "
      input = gets.chomp.upcase
      load_game if input == "Y"
    end
  end


end

newgame = Game.new
newgame.start