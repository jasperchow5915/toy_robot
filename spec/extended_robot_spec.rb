require 'spec_helper'
require 'toy_robot'

describe ExtendedRobot do

  let(:board) { ExtendedBoard.new }
  let(:robot) { ExtendedRobot.new(board, "R1") }

  subject { robot }

  it_should_behave_like "a robot"

  specify "model attributes" do
    should respond_to(:name)
  end

  specify "instance methods" do
    should respond_to(:block).with(0).arguments
    should respond_to(:map).with(0).arguments
  end

  describe "initial state" do
    its(:name) { should == "R1" }
    its(:blocks) do
      should_not be_nil
      should be_empty
    end
  end

  describe "#spin" do
    context "before a #place" do
      let(:expected_position) { nil }
      let(:expected_cardinal) { nil }

      before do
        allow(robot).to receive(:spin).and_return(false)
        robot.spin
      end

      it_should_behave_like "a robot at time of placement"
    end

    context "after a #place" do
      let(:direction) { robot.cardinal_direction }

      before { robot.place(2, 2, "NORTH") }

      subject { direction }

      valid_cardinals.each_with_index do |direction, index|
        context "then #spin from #{direction}" do
          let(:spins) { valid_cardinals.rotate(2) }

          before do
            robot.cardinal_direction = direction
            robot.spin
          end

          it { should == spins[index] }
        end
      end
    end
  end

  describe "#move" do
    context "when there is a block in the way" do
      # Expect no coordinate change from original placement of 2, 2
      let(:expected_position) do
        double("position", x_coordinate: 2, y_coordinate: 2)
      end

      before { robot.place(2, 2, "NORTH") }

      context "to the NORTH" do
        let(:expected_cardinal) { "NORTH" }

        before do
          robot.block
          robot.move
        end

        it_should_behave_like "a robot at time of placement"
      end

      context "to the EAST" do
        let(:expected_cardinal) { "EAST" }

        before do
          robot.right
          robot.block
          robot.move
        end

        it_should_behave_like "a robot at time of placement"
      end

      context "to the SOUTH" do
        let(:expected_cardinal) { "SOUTH" }

        before do
          2.times { robot.right }
          robot.block
          robot.move
        end

        it_should_behave_like "a robot at time of placement"
      end

      context "to the WEST" do
        let(:expected_cardinal) { "WEST" }

        before do
          robot.left
          robot.block
          robot.move
        end

        it_should_behave_like "a robot at time of placement"
      end
    end
  end

  describe "#report" do
    let(:report) { robot.report }

    subject { report.gsub(ansi_colors, '') }

    context "after a #place" do
      let(:expected_report) { extended_robot_2_2_north_report_no_name }
      before { robot.place(2, 2, "NORTH") }
      it { should == expected_report }
    end
  end

  describe "#map" do
    let(:map) { robot.map }

    subject { map.gsub(ansi_colors, '') }

    context "before a #place" do
      let(:expected_map) { false }
      before do
        allow(robot).to receive_message_chain(:map, :gsub).and_return(false)
      end
      it { should == expected_map }
    end

    context "after a #place" do
      let(:expected_map) { one_robot_r1_map }
      before { robot.place(2, 2, "NORTH") }
      it { should == expected_map }
    end
  end

  describe "#block" do
    context "before a #place" do
      before do
        allow(robot).to receive(:block).and_return(false)
        robot.block
      end

      it "is not added to the robot's blocks" do
        expect(robot.blocks.size).to eq(0)
      end
    end

    context "in a valid position" do
      before do
        robot.place(2, 2, "NORTH")
        robot.block
      end

      it "is added to the robot's blocks" do
        expect(robot.blocks.size).to eq(1)
      end

      context "in front of robot" do
        let(:block) { robot.blocks.last }

        subject { block }

        context "facing NORTH" do
          let(:expected_position) do
            double("position", x_coordinate: 2, y_coordinate: 3)
          end

          it_should_behave_like "an object at time of placement"
        end

        context "facing EAST" do
          let(:expected_position) do
            double("position", x_coordinate: 3, y_coordinate: 2)
          end

          before do
            robot.right
            robot.block
          end

          it_should_behave_like "an object at time of placement"
        end

        context "facing SOUTH" do
          let(:expected_position) do
            double("position", x_coordinate: 2, y_coordinate: 1)
          end

          before do
            2.times { robot.right }
            robot.block
          end

          it_should_behave_like "an object at time of placement"
        end

        context "facing WEST" do
          let(:expected_position) do
            double("position", x_coordinate: 1, y_coordinate: 2)
          end

          before do
            robot.left
            robot.block
          end

          it_should_behave_like "an object at time of placement"
        end
      end
    end

    context "in an invalid position" do
      context "over board boundaries" do
        before do
          robot.place(2, 4, "NORTH")
          robot.block
        end

        it "is not added to the robot's blocks" do
          expect(robot.blocks.size).to eq(0)
        end
      end

      context "where a block already exists" do
        before do
          robot.place(2, 2, "NORTH")
          2.times { robot.block }
        end

        it "is not added to the robot's blocks" do
          expect(robot.blocks.size).to eq(1)
        end
      end
    end
  end
end