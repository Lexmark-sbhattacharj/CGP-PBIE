# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'create user from omniauth azure_oauth2 provider auth_hash' do
    auth_hash = {
      'provider' => 'azure_oauth2',
      'uid' => '12345',
      'info' => {
        'email' => 'testy@lexmark.com',
        'name' => 'Testy Tester'
      }
    }
    refute User.find_by_email('testy@lexmark.com')
    User.from_omniauth(auth_hash)
    assert User.find_by_email('testy@lexmark.com')
  end

  test 'create user with uppercase email' do
    auth_hash = {
      'provider' => 'azure_oauth2',
      'uid' => '12345',
      'info' => {
        'email' => 'Testy@lexmark.com',
        'name' => 'Testy Tester'
      }
    }
    refute User.find_by_email('testy@lexmark.com')
    User.from_omniauth(auth_hash)
    assert User.find_by_email('testy@lexmark.com')
  end

  test 'create user from omniauth using claim info' do
    auth_hash = {
      uid: '123456',
      info: {
        name: 'Testy Testy'
      },
      extra: {
        raw_info: {
          id_token_claims: {
            emails: [
              'testy2@lexmark.com'
            ]
          }
        }
      }
    }
    refute User.find_by_email('testy2@lexmark.com')
    User.from_omniauth(auth_hash)
    assert User.find_by_email('testy2@lexmark.com')
  end

  test 'generating activity list for user' do
    user = User.find_by_email('test1@lexmark.com')
    assert user.all_activities.keys.sort == %w[2019-11-20 2019-11-21]
  end

  test 'records usage activity' do
    user = User.find_by_email('test1@lexmark.com')
    params = {
      'workspace_id' => '12345',
      'dataset_id' => '12345',
      'report_name' => 'report name',
      'idempotence_key' => '12345',
      'report_id' => '12345'
    }
    user.record_usage_activity(params)
    user.reload
    assert user.last_viewed_report == 'report name'
    assert user.last_viewed_workspace == '12345'
    assert user.all_activities.keys.count == 3
  end

  test 'maybe update name and uid' do
    user = User.find_by_email('test1@lexmark.com')
    assert user.uid == 'bfa37efe-b57d-4e04-80fc-b618409ff9c6'
    assert user.name == 'Test1'
    user.maybe_update_name_and_uid('Test1Update', '12345')
    user.reload
    assert user.uid == '12345'
    assert user.name == 'Test1Update'
  end

  test 'viewing workspaces as an admin' do
    user = User.find_by_email('admin@lexmark.com')
    assert user.workspaces.count == 2
  end

  test 'view workspaces as a non admin with no workspace association' do
    user = User.find_by_email('test2@lexmark.com')
    assert user.workspaces.empty?
  end
end
