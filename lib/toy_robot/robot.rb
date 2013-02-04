require 'active_model'
require 'toy_robot/block'
require 'toy_robot/position'
require 'toy_robot/map'

module ToyRobot
  # A Toy Robot that moves around a Board, without falling off it
  class Robot
    include ActiveModel::Validations
    extend ActiveModel::Callbacks

    define_model_callbacks :command, only: :before

    before_command :placed?

    attr_reader   :board
    attr_accessor :position, :cardinal_direction, :placed, :blocks

    validates :board, presence: true
    VALID_CARDINALS = %w(NORTH EAST SOUTH WEST)
    validates :cardinal_direction, inclusion: VALID_CARDINALS,
                                   allow_nil: true
    validates :placed, inclusion: [true, false]

    def initialize
      @board = Board.new
      @blocks = []
      @placed = false
    end

    def place(x_pos, y_pos, cardinal)
      position = Position.new(x_pos.to_i, y_pos.to_i)
      cardinal = cardinal.upcase
      if placeable?(position)
        @position, @cardinal_direction = position, cardinal
        @placed = true
      end
    end

    def place_block
      run_callbacks :command do
        block_position = forward_position
        if placeable?(block_position)
          @blocks << Block.new(block_position)
        end
      end
    end

    def move
      run_callbacks :command do
        new_position = forward_position
        if placeable?(new_position)
          @position = new_position
        end
      end
    end

    def left
      run_callbacks :command do
        turn("left")
      end
    end

    def right
      run_callbacks :command do
        turn("right")
      end
    end

    def report
      run_callbacks :command do
        {
          x_coordinate: @position.x_coordinate,
          y_coordinate: @position.y_coordinate,
          cardinal_direction: @cardinal_direction,
          map: Map.new(self).output
        }
      end
    end

    private

      def placed?
        @placed
      end

      def placeable?(position)
        @board.within_boundaries?(position) && space_empty?(position)
      end

      def space_empty?(position)
        @blocks.each do |block|
          if block.position == position
            return false
          end
        end
        true
      end

      def turn(direction)
        index = VALID_CARDINALS.index(@cardinal_direction)
        @cardinal_direction = case direction
          when "left" then VALID_CARDINALS.rotate(-1)[index]
          when "right" then VALID_CARDINALS.rotate[index]
        end
      end

      def forward_position
        x_coord, y_coord = @position.coordinates
        position = case @cardinal_direction
          when "NORTH" then Position.new(x_coord, y_coord + 1)
          when "EAST"  then Position.new(x_coord + 1, y_coord)
          when "SOUTH" then Position.new(x_coord, y_coord - 1)
          when "WEST"  then Position.new(x_coord - 1, y_coord)
        end
      end
  end
end