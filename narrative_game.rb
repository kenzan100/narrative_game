#[TODO] replace randomly chosen opponent to the card which is winning most.
#[TODO] add "creator" mode where you have to come up with a new card which can beat the winning card.
#[TODO] add "judge" mode where you could vote either one of 2 contradicting results.
CARDS_OFFLINE = ["grandma", "cockroach"]

class NarrativeGame

  class Player
    attr_accessor :card_limit, :cards

    def initialize(hash={})
      @card_limit = hash.fetch(:card_limit,1)
      @cards ||= []
    end

    def add_card(card)
      @cards << card
    end

    def fill_hands(all_cards)
      self.card_limit.times do
        your_card = all_cards[rand(all_cards.length)]
        raise "[ERROR] not enough card available." if your_card.nil?
        add_card(your_card)
      end
    end

    def cards_str
      cards.join(", ")
    end
  end

  def initialize(cards, player=Player.new, opponent=Player.new)
    @cards = cards
    @player = player
    @opponent = opponent

    @player.fill_hands(@cards)
    cards_left= @cards - @player.cards
    @opponent.fill_hands(cards_left)

    puts "starting a new game..\n\n"
  end

  def describe
    puts "Here's what you got:"
    puts "\"#{@player.cards_str}\""
    puts "And here's your opponent:"
    puts "\"#{@opponent.cards_str}\""
  end

  def tell_narrative
    puts "Now be creative! Tell us how #{@player.cards_str} can beat #{@opponent.cards_str}."
    @input = gets.chomp
  end

  def complete_the_answer
    puts "Is your story complete with the following narrative? answer either in 'yes' or 'no'"
    puts with_story_format
    @answer = gets.chomp
  end

  def with_story_format
    <<-EOS.gsub(/^\s+/,"")
    -----------------------------------------
    When #{@player.cards_str} battles with #{@opponent.cards_str}, the winner is #{@player.cards_str}. because..
    \"#{@input}\"
    -----------------------------------------
    EOS
  end

  def with_attributes_format
    <<-EOS.gsub(/^\s+/,"")
    players: [#{@player.cards_str}, #{@opponent.cards_str}]
    winner: #{@player.cards_str}
    reason: "#{@input}"
    EOS
  end

  def confirm
    case @answer
    when "yes"
      puts "Great! your story saved."
      File.open('output.txt', 'a'){|file| file.write with_attributes_format}
    when "no"
      puts "Then, try again."
      tell_narrative
      complete_the_answer
      confirm
    else
      puts "\n\nAnswer in either 'yes' or 'no'."
      complete_the_answer
      confirm
    end
  end
end

game = NarrativeGame.new(CARDS_OFFLINE, NarrativeGame::Player.new(card_limit:1))
game.describe
game.tell_narrative
game.confirm
