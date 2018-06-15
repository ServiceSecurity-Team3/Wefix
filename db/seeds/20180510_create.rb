# frozen_string_literal: true

Sequel.seed(:development) do
  def run
    puts 'Seeding accounts, groups, problems'
    create_accounts
    create_owned_groups
    create_problems
    add_collaborators
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ACCOUNTS_INFO = YAML.load_file("#{DIR}/accounts_seed.yml")
OWNER_INFO = YAML.load_file("#{DIR}/owners_groups.yml")
GROUP_INFO = YAML.load_file("#{DIR}/groups_seed.yml")
PROBLEM_INFO = YAML.load_file("#{DIR}/problems_seed.yml")
CONTRIB_INFO = YAML.load_file("#{DIR}/groups_collaborators_seed.yml")

def create_accounts
  ACCOUNTS_INFO.each do |account_info|
    Wefix::EmailAccount.create(account_info)
  end
end

def create_owned_groups
  OWNER_INFO.each do |owner|
    account = Wefix::Account.first(username: owner['username'])
    owner['grp_name'].each do |group_name|
      group_data = GROUP_INFO.find { |group| group['name'] == group_name }
      Wefix::CreateGroupForOwner.call(
        owner_id: account.id, group_data: group_data
      )
    end
  end
end

def create_problems
  prob_info_each = PROBLEM_INFO.each
  groups_cycle = Wefix::Group.all.cycle
  loop do
    prob_info = prob_info_each.next
    group = groups_cycle.next
    Wefix::CreateProblemForGroup.call(
      group_id: group.id, problem_data: prob_info
    )
  end
end

def add_collaborators
  contrib_info = CONTRIB_INFO
  contrib_info.each do |contrib|
    group = Wefix::Group.first(name: contrib['grp_name'])
    contrib['collaborator_email'].each do |email|
      collaborator = Wefix::Account.first(email: email)
      group.add_collaborator(collaborator)
    end
  end
end
