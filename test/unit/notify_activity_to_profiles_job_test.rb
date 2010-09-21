require File.dirname(__FILE__) + '/../test_helper'

class NotifyActivityToProfilesJobTest < ActiveSupport::TestCase

  should 'notify just the community in tracker with add_member_in_community verb' do
    person = fast_create(Person)
    community  = fast_create(Community)
    action_tracker = fast_create(ActionTracker::Record, :user_type => 'Profile', :user_id => person.id, :target_type => 'Profile', :target_id => community.id, :verb => 'add_member_in_community')
    assert NotifyActivityToProfilesJob::NOTIFY_ONLY_COMMUNITY.include?(action_tracker.verb)
    p1, p2, m1, m2 = fast_create(Person), fast_create(Person), fast_create(Person), fast_create(Person)
    fast_create(Friendship, :person_id => person.id, :friend_id => p1.id)
    fast_create(Friendship, :person_id => person.id, :friend_id => p2.id)
    fast_create(RoleAssignment, :accessor_id => m1.id, :role_id => 3, :resource_id => community.id)
    fast_create(RoleAssignment, :accessor_id => m2.id, :role_id => 3, :resource_id => community.id)
    ActionTrackerNotification.delete_all
    job = NotifyActivityToProfilesJob.new(action_tracker.id)
    job.perform
    process_delayed_job_queue

    assert_equal 1, ActionTrackerNotification.count
    [community].each do |profile|
      notification = ActionTrackerNotification.find_by_profile_id profile.id
      assert_equal action_tracker, notification.action_tracker
    end
  end

  should 'notify just the community in tracker with remove_member_in_community verb' do
    person = fast_create(Person)
    community  = fast_create(Community)
    action_tracker = fast_create(ActionTracker::Record, :user_type => 'Profile', :user_id => person.id, :target_type => 'Profile', :target_id => community.id, :verb => 'remove_member_in_community')
    assert NotifyActivityToProfilesJob::NOTIFY_ONLY_COMMUNITY.include?(action_tracker.verb)
    p1, p2, m1, m2 = fast_create(Person), fast_create(Person), fast_create(Person), fast_create(Person)
    fast_create(Friendship, :person_id => person.id, :friend_id => p1.id)
    fast_create(Friendship, :person_id => person.id, :friend_id => p2.id)
    fast_create(RoleAssignment, :accessor_id => m1.id, :role_id => 3, :resource_id => community.id)
    fast_create(RoleAssignment, :accessor_id => m2.id, :role_id => 3, :resource_id => community.id)
    ActionTrackerNotification.delete_all
    job = NotifyActivityToProfilesJob.new(action_tracker.id)
    job.perform
    process_delayed_job_queue

    assert_equal 1, ActionTrackerNotification.count
    [community].each do |profile|
      notification = ActionTrackerNotification.find_by_profile_id profile.id
      assert_equal action_tracker, notification.action_tracker
    end
  end

  should 'notify just the users and his friends tracking user actions' do
    person = fast_create(Person)
    community  = fast_create(Community)
    action_tracker = fast_create(ActionTracker::Record, :user_type => 'Profile', :user_id => person.id, :target_type => 'Profile', :verb => 'create_article')
    assert !NotifyActivityToProfilesJob::NOTIFY_ONLY_COMMUNITY.include?(action_tracker.verb)
    p1, p2, m1, m2 = fast_create(Person), fast_create(Person), fast_create(Person), fast_create(Person)
    fast_create(Friendship, :person_id => person.id, :friend_id => p1.id)
    fast_create(Friendship, :person_id => person.id, :friend_id => p2.id)
    fast_create(Friendship, :person_id => p1.id, :friend_id => m1.id)
    fast_create(RoleAssignment, :accessor_id => m2.id, :role_id => 3, :resource_id => community.id)
    ActionTrackerNotification.delete_all
    job = NotifyActivityToProfilesJob.new(action_tracker.id)
    job.perform
    process_delayed_job_queue

    assert_equal 3, ActionTrackerNotification.count
    [person, p1, p2].each do |profile|
      notification = ActionTrackerNotification.find_by_profile_id profile.id
      assert_equal action_tracker, notification.action_tracker
    end
  end

  should 'not notify the communities members' do
    person = fast_create(Person)
    community  = fast_create(Community)
    action_tracker = fast_create(ActionTracker::Record, :user_type => 'Profile', :user_id => person.id, :target_type => 'Profile', :target_id => community.id, :verb => 'create_article')
    assert !NotifyActivityToProfilesJob::NOTIFY_ONLY_COMMUNITY.include?(action_tracker.verb)
    m1, m2 = fast_create(Person), fast_create(Person), fast_create(Person), fast_create(Person)
    fast_create(RoleAssignment, :accessor_id => m1.id, :role_id => 3, :resource_id => community.id)
    fast_create(RoleAssignment, :accessor_id => m2.id, :role_id => 3, :resource_id => community.id)
    ActionTrackerNotification.delete_all
    job = NotifyActivityToProfilesJob.new(action_tracker.id)
    job.perform
    process_delayed_job_queue

    assert_equal 4, ActionTrackerNotification.count
    [person, community, m1, m2].each do |profile|
      notification = ActionTrackerNotification.find_by_profile_id profile.id
      assert_equal action_tracker, notification.action_tracker
    end
  end

  should 'notify users its friends, the community and its members' do
    person = fast_create(Person)
    community  = fast_create(Community)
    action_tracker = fast_create(ActionTracker::Record, :user_type => 'Profile', :user_id => person.id, :target_type => 'Profile', :target_id => community.id, :verb => 'create_article')
    assert !NotifyActivityToProfilesJob::NOTIFY_ONLY_COMMUNITY.include?(action_tracker.verb)
    p1, p2, m1, m2 = fast_create(Person), fast_create(Person), fast_create(Person), fast_create(Person)
    fast_create(Friendship, :person_id => person.id, :friend_id => p1.id)
    fast_create(Friendship, :person_id => person.id, :friend_id => p2.id)
    fast_create(RoleAssignment, :accessor_id => m1.id, :role_id => 3, :resource_id => community.id)
    fast_create(RoleAssignment, :accessor_id => m2.id, :role_id => 3, :resource_id => community.id)
    ActionTrackerNotification.delete_all
    job = NotifyActivityToProfilesJob.new(action_tracker.id)
    job.perform
    process_delayed_job_queue

    assert_equal 6, ActionTrackerNotification.count
    [person, community, p1, p2, m1, m2].each do |profile|
      notification = ActionTrackerNotification.find_by_profile_id profile.id
      assert_equal action_tracker, notification.action_tracker
    end
  end

  should 'not notify the community tracking join_community verb' do
    person = fast_create(Person)
    community  = fast_create(Community)
    action_tracker = fast_create(ActionTracker::Record, :user_type => 'Profile', :user_id => person.id, :target_type => 'Profile', :target_id => community.id, :verb => 'join_community')
    assert !NotifyActivityToProfilesJob::NOTIFY_ONLY_COMMUNITY.include?(action_tracker.verb)
    p1, p2, m1, m2 = fast_create(Person), fast_create(Person), fast_create(Person), fast_create(Person)
    fast_create(Friendship, :person_id => person.id, :friend_id => p1.id)
    fast_create(Friendship, :person_id => person.id, :friend_id => p2.id)
    fast_create(RoleAssignment, :accessor_id => m1.id, :role_id => 3, :resource_id => community.id)
    fast_create(RoleAssignment, :accessor_id => m2.id, :role_id => 3, :resource_id => community.id)
    ActionTrackerNotification.delete_all
    job = NotifyActivityToProfilesJob.new(action_tracker.id)
    job.perform
    process_delayed_job_queue

    assert_equal 5, ActionTrackerNotification.count
    [person, p1, p2, m1, m2].each do |profile|
      notification = ActionTrackerNotification.find_by_profile_id profile.id
      assert_equal action_tracker, notification.action_tracker
    end
  end

  should 'not notify the community tracking leave_community verb' do
    person = fast_create(Person)
    community  = fast_create(Community)
    action_tracker = fast_create(ActionTracker::Record, :user_type => 'Profile', :user_id => person.id, :target_type => 'Profile', :target_id => community.id, :verb => 'leave_community')
    assert !NotifyActivityToProfilesJob::NOTIFY_ONLY_COMMUNITY.include?(action_tracker.verb)
    p1, p2, m1, m2 = fast_create(Person), fast_create(Person), fast_create(Person), fast_create(Person)
    fast_create(Friendship, :person_id => person.id, :friend_id => p1.id)
    fast_create(Friendship, :person_id => person.id, :friend_id => p2.id)
    fast_create(RoleAssignment, :accessor_id => m1.id, :role_id => 3, :resource_id => community.id)
    fast_create(RoleAssignment, :accessor_id => m2.id, :role_id => 3, :resource_id => community.id)
    ActionTrackerNotification.delete_all
    job = NotifyActivityToProfilesJob.new(action_tracker.id)
    job.perform
    process_delayed_job_queue

    assert_equal 5, ActionTrackerNotification.count
    [person, p1, p2, m1, m2].each do |profile|
      notification = ActionTrackerNotification.find_by_profile_id profile.id
      assert_equal action_tracker, notification.action_tracker
    end
  end

  should "the NOTIFY_ONLY_COMMUNITY constant has all the verbs tested" do
    notify_community_verbs = ['add_member_in_community', 'remove_member_in_community']
    assert_equal [], notify_community_verbs - NotifyActivityToProfilesJob::NOTIFY_ONLY_COMMUNITY
    assert_equal [], NotifyActivityToProfilesJob::NOTIFY_ONLY_COMMUNITY - notify_community_verbs
  end

  should "the NOT_NOTIFY_COMMUNITY constant has all the verbs tested" do
    not_notify_community_verbs = ['join_community', 'leave_community']
    assert_equal [], not_notify_community_verbs - NotifyActivityToProfilesJob::NOT_NOTIFY_COMMUNITY
    assert_equal [], NotifyActivityToProfilesJob::NOT_NOTIFY_COMMUNITY - not_notify_community_verbs
  end

end
