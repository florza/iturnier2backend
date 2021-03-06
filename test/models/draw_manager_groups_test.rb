require 'test_helper'

class DrawManagerGroupsTest < ActiveSupport::TestCase

  def setup
    @contest = contests(:DemoGruppen)
    @full_params = {
      contest_id: @contest.id,  # simulates the id coming from the url
      data: { type: 'contests',
              id: @contest.id,
              attributes: { draw_tableau: [ [ participants(:Roger).id,
                                              participants(:Martina).id,
                                              participants(:Pete).id ],
                                            [ participants(:Rod).id,
                                              participants(:Raffa).id,
                                              participants(:Stan).id,
                                              participants(:Steffi).id ] ] } }
    }
  end

  ##
  # Test tableau validity

  test "empty tableau is valid" do
    draw_params = @full_params
    draw_params[:data][:attributes] = { draw_tableau: [[]] }
    mgr = DrawManagerGroups.new(draw_params)
    assert mgr.valid?
  end

  test "all participants set is valid" do
    draw_params = @full_params
    mgr = DrawManagerGroups.new(draw_params)
    assert mgr.valid?
  end

  test "some participants set is valid" do
    draw_params = @full_params
    draw_params[:data][:attributes][:draw_tableau][0][2] = 0
    draw_params[:data][:attributes][:draw_tableau][1][3] = 0
    mgr = DrawManagerGroups.new(draw_params)
    assert mgr.valid?
  end

  test "no tableau gets corrected to valid" do
    draw_params = @full_params
    draw_params[:data][:attributes] = { draw_tableau: nil }
    mgr = DrawManagerGroups.new(draw_params)
    assert mgr.valid?
    assert mgr.draw_structure[0].is_a?(Array)
  end

  test "one-level tableau gets corrected to valid" do
    draw_params = @full_params
    draw_params[:data][:attributes] = { draw_tableau: [] }
    mgr = DrawManagerGroups.new(draw_params)
    assert mgr.valid?
    assert mgr.draw_structure[0].is_a?(Array)
  end

  test "tableau with empty groups is valid" do
    draw_params = @full_params
    draw_params[:data][:attributes] = { draw_tableau: [ [], [], [] ] }
    mgr = DrawManagerGroups.new(draw_params)
    assert mgr.valid?
  end

  test "tableau with more than half of n groups is invalid" do
    draw_params = @full_params
    draw_params[:data][:attributes] = { draw_tableau: [ [], [], [], [] ] }
    mgr = DrawManagerGroups.new(draw_params)
    assert_not mgr.valid?
  end

  test "tableau with group of 1 is invalid" do
    draw_params = @full_params
    draw_params[:data][:attributes] =
      { draw_tableau: [
          @full_params[:data][:attributes][:draw_tableau][0],       # group of 3
          @full_params[:data][:attributes][:draw_tableau][1][0, 1], # group of 1
          @full_params[:data][:attributes][:draw_tableau][1][1, 3]  # group of 3
        ]
      }
    mgr = DrawManagerGroups.new(draw_params)
    assert_not mgr.valid?
  end

  test "invalid participant is invalid" do
    draw_params = @full_params
    draw_params[:data][:attributes][:draw_tableau][0][2] = 123456
    mgr = DrawManagerGroups.new(draw_params)
    assert_not mgr.valid?
  end

  test "tableau must not contain the same participant twice" do
    draw_params = @full_params
    draw_params[:data][:attributes][:draw_tableau][1][2] =
      draw_params[:data][:attributes][:draw_tableau][0][1]
    mgr = DrawManagerGroups.new(draw_params)
    assert_not mgr.valid?
  end

  test "draw with same tableau as before is unchanged" do
    draw_params = @full_params
    mgr = DrawManagerGroups.new(draw_params)
    mgr.draw
    @contest = Contest.find(contests(:DemoGruppen).id)
    assert_equal @full_params[:data][:attributes][:draw_tableau],
      @contest.ctype_params['draw_tableau']
  end

  ##
  # Test seeds validity

  test "empty seeds is valid" do
    draw_params = @full_params
    draw_params[:data][:attributes] =
      { draw_tableau: [[]], draw_seeds: [] }
    mgr = DrawManagerGroups.new(draw_params)
    assert mgr.valid?
  end

  test "seed sizes 1 to 4 give expected results" do
    testcases = [[:Roger, false], [:Rod, true], [:Raffa, true], [:Pete, false]]
    draw_params = @full_params
    draw_params[:data][:attributes] =
      { draw_tableau: [[0,0],[0,0,0],[0,0]], draw_seeds: [] }
    testcases.each do |ppant, result|
      draw_params[:data][:attributes][:draw_seeds] << participants(ppant).id
      mgr = DrawManagerGroups.new(draw_params)
      assert_equal result, mgr.valid?,
        "testcase #{ppant.to_s} gives unexpected result #{mgr.valid?.to_s}"
    end
  end

  test "invalid participant in seeds is invalid" do
    draw_params = @full_params
    draw_params[:data][:attributes][:draw_seeds] =
     [participants(:Roger).id, 1234]
    mgr = DrawManagerGroups.new(draw_params)
    assert_not mgr.valid?
  end

  ##
  # Test draw logic
  test "empty draw is filled up randomly" do
    draw_params = @full_params
    draw_params[:data][:attributes] =
      { draw_tableau: [ [0, 0, 0], [0, 0, 0, 0] ] }
    last_draw = []
    [0..2].each do |draw|
      mgr = DrawManagerGroups.new(draw_params)
      mgr.draw
      @contest = Contest.find(contests(:DemoGruppen).id)
      new_draw = @contest.ctype_params['draw_tableau']
      assert_equal 7, new_draw.flatten.uniq.size
      assert_not_equal last_draw, new_draw
      last_draw = new_draw.dup
    end
  end

  test "draw with empty slots is filled up" do
    draw_params = @full_params
    draw_params[:data][:attributes][:draw_tableau][0][1] = 0
    draw_params[:data][:attributes][:draw_tableau][1][2] = 0
    mgr = DrawManagerGroups.new(draw_params)
    mgr.draw
    @contest = Contest.find(contests(:DemoGruppen).id)
    new_draw = @contest.ctype_params['draw_tableau']
    [ [0, 0], [0, 2], [1, 0], [1, 1], [1, 3] ].each do |g, p|
      assert_equal @full_params[:data][:attributes][:draw_tableau][g][p],
        new_draw[g][p]
    end
    assert_includes [new_draw[0][1],new_draw[1][2]],
        @full_params[:data][:attributes][:draw_tableau][0][1]
    assert_includes [new_draw[0][1],new_draw[1][2]],
        @full_params[:data][:attributes][:draw_tableau][1][2]
  end

  test "changed group sizes in new tableau are accepted" do
    draw_params = @full_params
    draw_params[:data][:attributes][:draw_tableau][0].push(0)
    draw_params[:data][:attributes][:draw_tableau][0].push(0)
    draw_params[:data][:attributes][:draw_tableau][1].pop
    draw_params[:data][:attributes][:draw_tableau][1].pop
    mgr = DrawManagerGroups.new(draw_params)
    mgr.draw
    @contest = Contest.find(contests(:DemoGruppen).id)
    new_draw = @contest.ctype_params['draw_tableau']
    [ [0, 0], [0, 1], [1, 0], [1, 1] ].each do |g, p|
      assert_equal @full_params[:data][:attributes][:draw_tableau][g][p],
        new_draw[g][p]
    end
    redrawn_pps = [ @full_params[:data][:attributes][:draw_tableau][0][2],
                    @full_params[:data][:attributes][:draw_tableau][1][2],
                    @full_params[:data][:attributes][:draw_tableau][1][3] ]
    assert_includes redrawn_pps, new_draw[0][2]
    assert_includes redrawn_pps, new_draw[1][2]
    assert_includes redrawn_pps, new_draw[1][3]
  end

  test "draw must not be created if a match has been played" do
    create_draw_and_result

    # Try to create a new draw
    draw_params = @full_params
    draw_mgr = DrawManagerGroups.new(draw_params)
    draw_mgr.draw
    assert_not draw_mgr.valid?
    assert_includes draw_mgr.errors.messages[:draw],
      'must not be changed if matches were already played'
  end

  test "draw must not be deleted if a match has been played" do
    create_draw_and_result

    # Try to delete the draw
    draw_params = @full_params
    draw_mgr = DrawManagerGroups.new(draw_params)
    draw_mgr.delete_draw(@contest)
    assert_not draw_mgr.valid?
    assert_includes draw_mgr.errors.messages[:draw],
      'must not be changed if matches were already played'
  end

end
