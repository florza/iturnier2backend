require 'test_helper'

class ParticipantsControllerNoUserTest < ActionDispatch::IntegrationTest
  setup do
    @contest = contests(:DemoMeisterschaft)
    @participant = participants(:DM2)
  end

  test "should not get index of contests participants without user" do
    get api_v1_contest_participants_url(@contest), as: :json
    assert_response 401
  end

  test "should not show participant without user" do
    get api_v1_contest_participant_url(@contest, @participant), as: :json
    assert_response 401
  end

  test "should not create participant without user" do
    post api_v1_contest_participants_url(@contest),
        params:   {
          data: { type: 'participants',
                  attributes: { name: 'New test participant',
                                shortname: 'New test',
                                remarks: 'Remarks'} }
        },
        as: :json
    assert_response 401
  end

  test "should not update participant without user" do
    patch api_v1_contest_participant_url(@contest, @participant),
          params: {
            data: { type: 'participants',
                    id: @participant.id,
                    attributes: { name: @participant.name,
                                  shortname: @participant.shortname,
                                  remarks: @participant.remarks} }
          },
          as: :json
    assert_response 401
  end

  test "should not destroy participant without user" do
    delete api_v1_contest_participant_url(@contest, @participant), as: :json
    assert_response 401
  end
end
