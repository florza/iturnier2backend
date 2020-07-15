require 'test_helper'

class RefreshControllerTest < ActionDispatch::IntegrationTest

  def setup
    register_testuser
  end

  test "should refresh a timed out token" do
    get api_v1_contests_url, headers: @headers, as: :json
    assert_response :success    # New token after register/login is ok

    travel 61.minutes do        # Roll forwards in time...
      get api_v1_contests_url, headers: @headers, as: :json
      assert_response 401       # Token has timed out after 1 hour

      post refresh_path, headers: @headers
      assert_response :success  # Token was refreshed
      @headers['X-CSRF-TOKEN'] = JSON.parse(@response.body)['csrf']

      get api_v1_contests_url, headers: @headers, as: :json
      assert_response :success  # New token works
    end
  end

end
